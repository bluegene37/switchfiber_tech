import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/sync_error_logs_dao.dart';
import '../../../core/network/request_snapshot.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';

/// What the server said when it refused a push, kept on the phone that hit it.
///
/// The app is offline-first on purpose: a refused edit stays saved locally and
/// retries. This screen is the other half of that bargain, so a job sitting on
/// "needs to sync" can be explained instead of guessed at.
class SyncErrorLogScreen extends StatefulWidget {
  final SyncErrorLogsDao dao;

  const SyncErrorLogScreen({super.key, required this.dao});

  @override
  State<SyncErrorLogScreen> createState() => _SyncErrorLogScreenState();
}

class _SyncErrorLogScreenState extends State<SyncErrorLogScreen> {
  bool _onlyUnresolved = false;

  /// Bytes are the point of this log, so they are shown at the scale a
  /// technician can act on rather than as a raw count.
  static String formatSize(int bytes) {
    if (bytes <= 0) return '-';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String formatWhen(DateTime at) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${at.year}-${two(at.month)}-${two(at.day)} '
        '${two(at.hour)}:${two(at.minute)}';
  }

  /// The whole log as plain text, so a technician in the field can paste it
  /// into a message to the office rather than reading it aloud.
  static String asReport(List<SyncErrorLog> logs) => logs
      .map((e) => '${formatWhen(e.occurredAt)}  ${e.reference}  '
          '${e.operation}  HTTP ${e.statusCode ?? "no response"}  '
          '${formatSize(e.payloadBytes)}\n'
          '${e.requestMethod} ${e.requestUrl}\n${e.message}')
      .join('\n\n');

  /// One entry with the request that was sent and the answer that came
  /// back, ready to hand to the backend team.
  static String asRequestReport(SyncErrorLog e) => RequestSnapshot.report(
        method: e.requestMethod.isEmpty ? 'PUT' : e.requestMethod,
        url: e.requestUrl,
        statusCode: e.statusCode,
        message: e.message,
        requestBody: e.requestBody,
        responseBody: e.responseBody,
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Errors'),
        actions: [
          IconButton(
            tooltip: _onlyUnresolved ? 'Show all' : 'Show unresolved only',
            icon: Icon(
                _onlyUnresolved
                    ? Icons.filter_alt_rounded
                    : Icons.filter_alt_outlined,
                size: 24),
            onPressed: () => setState(() => _onlyUnresolved = !_onlyUnresolved),
          ),
        ],
      ),
      body: StreamBuilder<List<SyncErrorLog>>(
        stream: widget.dao.watchAll(onlyUnresolved: _onlyUnresolved),
        builder: (context, snapshot) {
          final logs = snapshot.data;
          if (logs == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (logs.isEmpty) {
            return _EmptyState(onlyUnresolved: _onlyUnresolved);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                      16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _LogTile(log: logs[i], isDark: isDark),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: asReport(logs)));
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sync error log copied.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(CupertinoIcons.doc_on_clipboard,
                              size: 24),
                          label: const Text('Copy log'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmClear(context),
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 24),
                          label: const Text('Clear'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.dangerInkOf(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Clear sync errors?'),
        content: const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
              'This only clears the log. Jobs waiting to sync stay saved and '
              'will keep retrying.'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true) await widget.dao.clearAll();
  }
}

class _LogTile extends StatefulWidget {
  final SyncErrorLog log;
  final bool isDark;

  const _LogTile({required this.log, required this.isDark});

  @override
  State<_LogTile> createState() => _LogTileState();
}

class _LogTileState extends State<_LogTile> {
  /// The request body is long; it opens on demand so the list stays a list.
  bool _showRequest = false;

  Future<void> _copyRequest(BuildContext context) async {
    await Clipboard.setData(ClipboardData(
        text: _SyncErrorLogScreenState.asRequestReport(widget.log)));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request and response copied.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    final isDark = widget.isDark;
    final mono = context.text.bodySmall!.copyWith(
      fontFamily: 'monospace',
      color: AppTheme.secondaryInkOf(context),
    );
    final hasRequest = log.requestBody != null || log.requestUrl.isNotEmpty;
    // A refusal that has since gone through is history, not a live problem,
    // so it reads back rather than shouting.
    final accent = log.resolved
        ? AppTheme.successInkOf(context)
        : AppTheme.dangerInkOf(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  log.resolved
                      ? Icons.check_circle_outline_rounded
                      : Icons.error_outline_rounded,
                  size: 20,
                  color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  log.reference.isEmpty ? '#${log.entityId}' : log.reference,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall!.copyWith(color: accent),
                ),
              ),
              Text(
                log.statusCode == null
                    ? 'no response'
                    : 'HTTP ${log.statusCode}',
                style: context.text.labelMedium!.copyWith(color: accent),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${_SyncErrorLogScreenState.formatWhen(log.occurredAt)}  ·  '
            '${log.operation}  ·  '
            'sent ${_SyncErrorLogScreenState.formatSize(log.payloadBytes)}',
            style: context.text.bodySmall!
                .copyWith(color: AppTheme.secondaryInkOf(context)),
          ),
          if (log.requestUrl.isNotEmpty) ...[
            const SizedBox(height: 6),
            SelectableText(
              '${log.requestMethod} ${log.requestUrl}',
              style: mono,
            ),
          ],
          const SizedBox(height: 8),
          SelectableText(log.message, style: mono),
          if (hasRequest) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _showRequest = !_showRequest),
                  icon: Icon(
                      _showRequest
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      size: 20),
                  label: Text(_showRequest ? 'Hide request' : 'Show request'),
                ),
                TextButton.icon(
                  onPressed: () => _copyRequest(context),
                  icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 20),
                  label: const Text('Copy request'),
                ),
              ],
            ),
            if (_showRequest) ...[
              const SizedBox(height: 4),
              SelectableText(
                _SyncErrorLogScreenState.asRequestReport(log),
                style: mono,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool onlyUnresolved;

  const _EmptyState({required this.onlyUnresolved});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_done_outlined,
                size: 48, color: AppTheme.successInkOf(context)),
            const SizedBox(height: 12),
            Text(
              onlyUnresolved
                  ? 'Nothing is waiting on the server.'
                  : 'No sync errors recorded.',
              textAlign: TextAlign.center,
              style: context.text.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Anything the office refuses is recorded here, with what was '
              'sent and what came back.',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium!
                  .copyWith(color: AppTheme.secondaryInkOf(context)),
            ),
          ],
        ),
      ),
    );
  }
}
