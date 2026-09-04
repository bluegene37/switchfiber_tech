import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/server_display.dart';
import '../services/auth_service.dart';
import '../signals/auth_signals.dart';

/// Technician Login Screen with official Switch Fiber branding.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  final _obscurePassword = signal<bool>(true);

  final authSignals = AuthSignals.instance;
  String _baseUrl = AppConstants.defaultBaseUrl;

  @override
  void initState() {
    super.initState();
    _loadEndpoint();
  }

  Future<void> _loadEndpoint() async {
    final url = await SecureStorageService.instance.getBaseUrl();
    if (mounted) setState(() => _baseUrl = url);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await authSignals.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (!success && authSignals.authError.value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  authSignals.authError.value!,
                  style: context.text.bodySmall!.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showHelpModal() {
    final usernameController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Padding(
        // viewInsets covers the keyboard. padding.bottom covers the system
        // navigation bar or home indicator, which otherwise sits on top of the
        // hotline row at the end of the sheet. It collapses to zero while the
        // keyboard is up, so the two never double up.
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: MediaQuery.of(ctx).viewInsets.bottom +
              MediaQuery.of(ctx).padding.bottom +
              24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // iOS Grabber Pill
              Center(
                child: Container(
                  width: 36,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF38383A)
                        : const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(CupertinoIcons.question_circle_fill,
                          color: AppTheme.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Dispatch & Terminal Help',
                        style: ctx.text.titleSmall,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkInput : AppTheme.fillLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.xmark,
                        size: 24,
                        color: isDark ? Colors.white : AppTheme.darkSlate,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Forgot technician password or having connectivity issues? Enter your username to get a reset link by email, or contact Dispatch Operations.',
                style: ctx.text.bodyMedium!
                    .copyWith(color: AppTheme.secondaryInkOf(ctx)),
              ),
              const SizedBox(height: 16),

              // Password reset request
              Text(
                'Request Password Reset Link',
                style: ctx.text.labelMedium,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: usernameController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'tech_username',
                        prefixIcon: Icon(CupertinoIcons.person, size: 18),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final username = usernameController.text.trim();
                      if (username.isEmpty) return;
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await AuthService().requestPasswordReset(username);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Password reset request sent! Check your email.'),
                            backgroundColor: AppTheme.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        if (!ctx.mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                                'Failed: ${e.toString().replaceAll('Exception: ', '')}'),
                            backgroundColor: AppTheme.danger,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    child: const Text('Send'),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Dispatch Hotline
              Text(
                'Operations Dispatch Hotline',
                style: ctx.text.labelMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkInput : AppTheme.fillLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          isDark ? AppTheme.borderDark : AppTheme.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_in_talk_rounded,
                        color: AppTheme.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Switch Fiber Operations',
                              style: ctx.text.labelMedium),
                          Text('+63 2 8888 3423 • Toll-Free 1800-SWITCH',
                              style: ctx.text.bodySmall),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 20),
                      tooltip: 'Copy Hotline',
                      onPressed: () {
                        Clipboard.setData(
                            const ClipboardData(text: '+63288883423'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Hotline number copied to clipboard!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppTheme.darkSlate,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo & Brand Header
                    _buildBrandHeader(isDark),
                    const SizedBox(height: 28),

                    // Error Alert Banner (Reactive)
                    SignalBuilder(
                      builder: (context) {
                        final err = authSignals.authError.value;
                        if (err == null || err.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.dangerSubtle,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppTheme.danger, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  err,
                                  style: context.text.bodySmall!.copyWith(
                                    color: AppTheme.dangerInkOf(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Form Container
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Technician Sign In',
                                style: context.text.titleLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Enter your field credentials to access assigned work orders.',
                                style: context.text.bodyMedium!.copyWith(
                                    color: AppTheme.secondaryInkOf(context)),
                              ),
                              const SizedBox(height: 20),

                              // Username Field
                              TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon:
                                      Icon(CupertinoIcons.person, size: 20),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              SignalBuilder(
                                builder: (context) {
                                  final obscure = _obscurePassword.value;
                                  return TextFormField(
                                    controller: _passwordController,
                                    obscureText: obscure,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _handleLogin(),
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(
                                          CupertinoIcons.lock,
                                          size: 20),
                                      suffixIcon: IconButton(
                                        tooltip: obscure
                                            ? 'Show password'
                                            : 'Hide password',
                                        icon: Icon(
                                          obscure
                                              ? CupertinoIcons.eye_slash
                                              : CupertinoIcons.eye,
                                          size: 20,
                                          color:
                                              AppTheme.secondaryInkOf(context),
                                        ),
                                        onPressed: () {
                                          _obscurePassword.value = !obscure;
                                        },
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 14),

                              // Remember Me
                              SignalBuilder(
                                builder: (context) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value:
                                              authSignals.rememberMe.value,
                                          activeColor: AppTheme.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          onChanged: (val) {
                                            authSignals.rememberMe.value =
                                                val ?? true;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Remember me',
                                        style: context.text.bodySmall,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 22),

                              // Submit Button
                              SignalBuilder(
                                builder: (context) {
                                  final loading = authSignals.authLoading.value;
                                  return ElevatedButton(
                                    onPressed: loading ? null : _handleLogin,
                                    child: loading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.login_rounded,
                                                  size: 18),
                                              SizedBox(width: 8),
                                              Text('Sign In to Terminal'),
                                            ],
                                          ),
                                  );
                                },
                              ),
                              const SizedBox(height: 14),

                              // Need help / Contact Dispatch Link
                              Center(
                                child: TextButton(
                                  onPressed: _showHelpModal,
                                  child: Text(
                                    'Need help or forgot password?',
                                    style: context.text.bodySmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Backend Connection Status Indicator Pill
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppTheme.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Server: ${ServerDisplay.mask(_baseUrl)}',
                              style: context.text.labelSmall!
                                  .copyWith(fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Footer
                    Center(
                      child: Text(
                        'Switch Fiber Network Operations • 2026',
                        style: context.text.labelSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : AppTheme.primarySubtleBg,
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isDark ? AppTheme.borderDark : AppTheme.primarySubtleBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo.png',
            errorBuilder: (_, __, ___) => const Icon(
              Icons.wifi_tethering_rounded,
              size: 38,
              color: AppTheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Switch Fiber',
          textAlign: TextAlign.center,
          style: context.text.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Field Technician Terminal',
          textAlign: TextAlign.center,
          style: context.text.bodySmall,
        ),
      ],
    );
  }
}
