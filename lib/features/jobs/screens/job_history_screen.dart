import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/signals/auth_signals.dart';
import '../signals/jobs_signals.dart';
import '../widgets/job_history_view.dart';

/// The signed-in technician's activated job orders, newest first.
///
/// Strictly a record: tiles open the details in view-only mode, and the
/// screen offers date, area and text filters but no way to change a job.
class JobHistoryScreen extends StatelessWidget {
  final JobsSignals jobsSignals;
  final AuthSignals authSignals;

  const JobHistoryScreen({
    super.key,
    required this.jobsSignals,
    required this.authSignals,
  });

  @override
  Widget build(BuildContext context) {
    final signals = jobsSignals;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Job History',
              style: context.text.titleMedium,
            ),
            SignalBuilder(
              builder: (context) {
                final email = signals.technicianEmail.value?.trim() ?? '';
                if (email.isEmpty) return const SizedBox.shrink();
                return Text(
                  'Activated jobs for $email',
                  style: context.text.bodySmall,
                );
              },
            ),
          ],
        ),
        actions: [
          SignalBuilder(
            builder: (context) {
              final refreshing = signals.isRefreshing.value;
              return IconButton(
                tooltip: 'Refresh from server',
                onPressed: refreshing ? null : () => signals.fetchRemote(),
                icon: refreshing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      )
                    : const Icon(CupertinoIcons.arrow_2_circlepath),
              );
            },
          ),
        ],
      ),
      body: JobHistoryView(
        jobsSignals: jobsSignals,
        authSignals: authSignals,
      ),
    );
  }
}
