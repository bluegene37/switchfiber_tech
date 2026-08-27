/// User-facing copy for the failures `POST /api/Auth/google` can return.
///
/// The backend rejects a Google identity with `{message, code}`. The code is
/// what we key on: server wording may change, but these three outcomes each
/// need a specific instruction for the technician standing in the field.
const String _notProvisioned =
    "This Google account isn't linked to a technician profile. "
    'Contact Dispatch.';

const String _inactive =
    'Your technician account is inactive. Please contact Dispatch.';

const String _mismatch =
    "This Google account doesn't match the one linked to your profile. "
    'Contact Dispatch.';

const String _generic = 'Google sign-in failed. Please try again.';

/// Map a server error [code] to technician-facing copy.
///
/// Unknown codes defer to [serverMessage], so a new backend rejection reaches
/// the technician in the server's own words rather than being swallowed.
String googleAuthMessage({String? code, String? serverMessage}) {
  switch (code?.trim().toUpperCase()) {
    case 'ACCOUNT_NOT_PROVISIONED':
      return _notProvisioned;
    case 'ACCOUNT_INACTIVE':
      return _inactive;
    case 'ACCOUNT_MISMATCH':
      return _mismatch;
  }

  final fallback = serverMessage?.trim() ?? '';
  return fallback.isNotEmpty ? fallback : _generic;
}
