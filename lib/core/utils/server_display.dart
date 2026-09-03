/// Formats the configured API endpoint for on-screen display without
/// revealing the full address. The real value stays in secure storage and in
/// the HTTP client; only a masked form ever reaches a widget.
class ServerDisplay {
  ServerDisplay._();

  static final RegExp _ipv4 = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$');

  /// `https://103.249.198.50:8090/api` → `103.***.***.***:8090`
  /// `https://api.switchfiber.ph/api`  → `ap***.ph`
  static String mask(String url) {
    final uri = Uri.tryParse(url.trim());
    final host = uri?.host ?? '';
    if (host.isEmpty) return url.replaceAll(RegExp(r'\d'), '*');

    final String maskedHost;
    if (_ipv4.hasMatch(host)) {
      maskedHost = '${host.split('.').first}.***.***.***';
    } else {
      final labels = host.split('.');
      final first = labels.first;
      final head = first.length > 2 ? first.substring(0, 2) : first;
      maskedHost =
          labels.length > 1 ? '$head***.${labels.last}' : '$head***';
    }

    final port = uri!.hasPort ? ':${uri.port}' : '';
    return '$maskedHost$port';
  }
}
