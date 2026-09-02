import 'package:flutter/material.dart';

/// Interactive Field Troubleshooting Decision Node for ISP Technicians.
class TroubleshootingGuideItem {
  final String id;
  final String title;
  final String symptom;
  final IconData icon;
  final Color badgeColor;
  final List<String> probableCauses;
  final List<TroubleshootingStep> actionSteps;

  const TroubleshootingGuideItem({
    required this.id,
    required this.title,
    required this.symptom,
    required this.icon,
    required this.badgeColor,
    required this.probableCauses,
    required this.actionSteps,
  });

  static const List<TroubleshootingGuideItem> fieldGuides = [
    TroubleshootingGuideItem(
      id: 'red_los',
      title: 'Red LOS Light (Loss of Signal)',
      symptom:
          'ONT LOS LED is solid or blinking RED; no optical power received.',
      icon: Icons.highlight_off_rounded,
      badgeColor: Color(0xFFEF4444),
      probableCauses: [
        'Broken or severed drop wire along utility pole spans.',
        'Drop cable bent below minimum bend radius (macro-bending).',
        'Disconnected or unseated SC/APC connector at NAP box or ONT.',
        'Improper cleave angle or shattered fiber core inside Fast Connector.',
        'Feeder cable cut between LCP cabinet and NAP box.',
      ],
      actionSteps: [
        TroubleshootingStep(
          stepNumber: 1,
          title: 'Measure OPM at NAP Box',
          action:
              'Plug Optical Power Meter directly into assigned NAP port. If optical power is normal (-15 to -22 dBm), the NAP feeder link is good and the issue is downstream in the drop cable.',
        ),
        TroubleshootingStep(
          stepNumber: 2,
          title: 'Inspect with VFL (Visual Fault Locator)',
          action:
              'Connect red laser VFL to the drop cable at the NAP. Walk the drop line looking for glowing red light indicating a break, sharp kink, or clamp pinch point.',
        ),
        TroubleshootingStep(
          stepNumber: 3,
          title: 'Re-terminate SC/APC Fast Connector',
          action:
              'Re-strip (250µm coating), clean fiber with 99% isopropyl alcohol wipe, cleave at exact 10mm length using precision cleaver, and re-seat inside fast connector.',
        ),
        TroubleshootingStep(
          stepNumber: 4,
          title: 'Measure ONT Power Level',
          action:
              'Re-test with OPM at the subscriber end. Target reading must be between -12.0 dBm and -24.0 dBm before connecting to the ONT.',
        ),
      ],
    ),
    TroubleshootingGuideItem(
      id: 'high_loss',
      title: 'High Optical Attenuation (< -27.0 dBm)',
      symptom: 'Intermittent drops, high packet loss, marginal Rx power level.',
      icon: Icons.speed_rounded,
      badgeColor: Color(0xFFF59E0B),
      probableCauses: [
        'Dirty SC/APC connector end-face (dust, oil, moisture).',
        'Tight radius cable bends in subscriber conduit or corners.',
        'Bad fusion splice or misaligned mechanical splice in closure.',
        'Splitter port overload or cascaded high split ratio.',
      ],
      actionSteps: [
        TroubleshootingStep(
          stepNumber: 1,
          title: 'Clean Connector End-Faces',
          action:
              'Use one-click 2.5mm cassette cleaner on SC/APC ferrule. Avoid touching ceramic tip. Re-measure power.',
        ),
        TroubleshootingStep(
          stepNumber: 2,
          title: 'Check Indoor Bend Radius',
          action:
              'Ensure fiber maintains minimum 30mm bend radius. Release any zip-ties that are over-cinched and crushing the buffer tube.',
        ),
        TroubleshootingStep(
          stepNumber: 3,
          title: 'Compare NAP vs ONT Drop Loss',
          action:
              'Drop loss should not exceed 0.5 to 1.0 dB total. If power drops by >3 dB between NAP and ONT, replace the drop cable run.',
        ),
      ],
    ),
    TroubleshootingGuideItem(
      id: 'flashing_pon',
      title: 'Flashing PON Light (OMCI Registration Pending)',
      symptom:
          'Optical power is good (-18 dBm) but PON LED blinks GREEN; ONT not synchronized.',
      icon: Icons.sync_problem_rounded,
      badgeColor: Color(0xFF0EA5E9),
      probableCauses: [
        'Modem ONT Serial Number (SN) mismatch in OLT/RADIUS database.',
        'Assigned to incorrect PON port or VLAN configuration.',
        'ONT firmware incompatible or profile unprovisioned.',
      ],
      actionSteps: [
        TroubleshootingStep(
          stepNumber: 1,
          title: 'Verify Serial Number Barcode',
          action:
              'Check that ONT Serial Number matches the Job Order assignment exactly (e.g. HWTC / ZTE prefix).',
        ),
        TroubleshootingStep(
          stepNumber: 2,
          title: 'Verify VLAN ID Assignment',
          action:
              'Ensure subscriber VLAN tag is assigned to the matching LCP distribution port in the Switch Fiber portal.',
        ),
        TroubleshootingStep(
          stepNumber: 3,
          title: 'Contact Network Dispatch NOC',
          action:
              'Provide Tech ID and Ticket # to NOC to force OMCI re-synchronization.',
        ),
      ],
    ),
    TroubleshootingGuideItem(
      id: 'ip_config',
      title: 'No Internet / IP & DHCP Issues',
      symptom:
          'PON is steady GREEN, but no IP assigned or captive portal loop.',
      icon: Icons.router_rounded,
      badgeColor: Color(0xFF8B5CF6),
      probableCauses: [
        'PPPoE username/password credentials incorrect in ONT.',
        'DHCP pool exhausted on CGNAT gateway (100.64.0.0/10).',
        'Subscriber port disabled in billing / pending activation.',
      ],
      actionSteps: [
        TroubleshootingStep(
          stepNumber: 1,
          title: 'Check WAN Status in ONT Admin',
          action:
              'Login to ONT web UI (192.168.100.1 / 192.168.1.1). Check WAN Status -> IPv4 Connection State.',
        ),
        TroubleshootingStep(
          stepNumber: 2,
          title: 'Verify PPPoE / IPoE Setup',
          action:
              'Confirm credentials match the subscriber account number in the Switch Fiber database.',
        ),
        TroubleshootingStep(
          stepNumber: 3,
          title: 'Run Diagnostic Ping',
          action:
              'Use the Tech Toolkit Ping test to verify connectivity to Gateway and Google DNS (8.8.8.8).',
        ),
      ],
    ),
  ];
}

class TroubleshootingStep {
  final int stepNumber;
  final String title;
  final String action;

  const TroubleshootingStep({
    required this.stepNumber,
    required this.title,
    required this.action,
  });
}
