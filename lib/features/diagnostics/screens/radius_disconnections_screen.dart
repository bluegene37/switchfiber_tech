import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/radius_user_model.dart';
import '../services/radius_user_service.dart';

/// Screen mirroring `https://switchfiber.genexis.dev/disconnection` for reviewing
/// RADIUS subscriber accounts and toggling live connection/disconnection states.
class RadiusDisconnectionsScreen extends StatefulWidget {
  const RadiusDisconnectionsScreen({super.key});

  @override
  State<RadiusDisconnectionsScreen> createState() => _RadiusDisconnectionsScreenState();
}

class _RadiusDisconnectionsScreenState extends State<RadiusDisconnectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<RadiusUserDto> _allUsers = [];
  bool _isLoading = true;
  String? _error;

  String _filter = ''; // '' = all, 'connected', 'disconnected'
  final Set<String> _pendingAccounts = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await RadiusUserService.instance.fetchRadiusUsers();
      if (!mounted) return;
      setState(() {
        _allUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load RADIUS users: $e';
      });
    }
  }

  Future<void> _toggleUser(RadiusUserDto user, bool desired) async {
    final name = user.name;
    if (_pendingAccounts.contains(name)) return;

    setState(() {
      _pendingAccounts.add(name);
      // Optimistic in-memory update
      final idx = _allUsers.indexWhere((u) => u.name == name);
      if (idx != -1) {
        _allUsers[idx] = RadiusUserDto(
          id: user.id,
          name: user.name,
          group: desired ? 'SwitchLite' : 'Disconnected',
          disabled: !desired,
          password: user.password,
          sharedUsers: user.sharedUsers,
        );
      }
    });

    try {
      final ok = await RadiusUserService.instance.toggleConnection(name, desired);
      if (!ok) throw Exception('API rejected connection change');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            desired
                ? 'Account $name connected.'
                : 'Account $name disconnected.',
          ),
          backgroundColor: desired ? AppTheme.success : AppTheme.darkSlate,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Revert in-memory update on error
      final idx = _allUsers.indexWhere((u) => u.name == name);
      if (idx != -1) {
        _allUsers[idx] = user;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update $name: $e'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _pendingAccounts.remove(name));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Counts
    final total = _allUsers.length;
    final connectedCount = _allUsers.where((u) => u.isConnected).length;
    final disconnectedCount = total - connectedCount;

    // Filtered
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _allUsers.where((u) {
      if (_filter == 'connected' && !u.isConnected) return false;
      if (_filter == 'disconnected' && u.isConnected) return false;
      if (query.isNotEmpty) {
        return u.name.toLowerCase().contains(query) || u.group.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disconnections & RADIUS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadUsers,
            icon: const Icon(CupertinoIcons.arrow_2_circlepath),
            tooltip: 'Refresh accounts',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips & Search Bar Header
          Container(
            color: isDark ? AppTheme.darkCard : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // iOS Capsule Search Bar
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkInput : AppTheme.fillLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.search, size: 16, color: AppTheme.textMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppTheme.darkSlate),
                          decoration: const InputDecoration(
                            hintText: 'Search account name, plan group...',
                            hintStyle: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          child: const Icon(CupertinoIcons.clear_thick_circled, size: 16, color: AppTheme.textMuted),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Filter Tabs: All, Connected, Disconnected
                Row(
                  children: [
                    _buildFilterChip('All', '', total, isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('Connected', 'connected', connectedCount, isDark, color: AppTheme.success),
                    const SizedBox(width: 8),
                    _buildFilterChip('Disconnected', 'disconnected', disconnectedCount, isDark, color: AppTheme.primary),
                  ],
                ),
              ],
            ),
          ),

          // User Accounts List
          Expanded(
            child: _isLoading
                ? const Center(child: CupertinoActivityIndicator(radius: 12))
                : _error != null
                    ? Center(child: Text(_error!))
                    : filtered.isEmpty
                        ? const Center(child: Text('No RADIUS accounts found.'))
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            color: AppTheme.primary,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final user = filtered[index];
                                final isPending = _pendingAccounts.contains(user.name);
                                final isConnected = user.isConnected;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                      width: 0.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(
                                    children: [
                                      // Status Dot
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isConnected ? AppTheme.success : AppTheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Account Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.name,
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Group: ${user.group.isEmpty ? "None" : user.group}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark ? Colors.white60 : AppTheme.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Status Pill
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isConnected
                                              ? (isDark ? const Color(0xFF143823) : const Color(0xFFE8F5E9))
                                              : (isDark ? AppTheme.primarySubtleBgDark : AppTheme.primarySubtleBg),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isConnected ? 'Connected' : 'Disconnected',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isConnected ? AppTheme.success : AppTheme.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Toggle
                                      if (isPending)
                                        const SizedBox(
                                          width: 40,
                                          child: Center(child: CupertinoActivityIndicator(radius: 8)),
                                        )
                                      else
                                        CupertinoSwitch(
                                          value: isConnected,
                                          activeTrackColor: AppTheme.success,
                                          onChanged: (val) => _toggleUser(user, val),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count, bool isDark, {Color? color}) {
    final isSelected = _filter == value;
    final primaryColor = color ?? AppTheme.primary;

    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (color != null ? primaryColor.withValues(alpha: 0.15) : (isDark ? AppTheme.primarySubtleBgDark : AppTheme.primarySubtleBg))
              : (isDark ? AppTheme.darkInput : AppTheme.fillLight),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? primaryColor : (isDark ? Colors.white70 : AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}
