import 'dart:convert';

import '../utils/data_url.dart';

/// Renders a request or response as text a technician can paste into a
/// message to the backend team.
class RequestSnapshot {
  RequestSnapshot._();

  static const JsonEncoder _pretty = JsonEncoder.withIndent('  ');

  /// Inline images up to this size are kept verbatim so the copied request
  /// replays exactly. A signature is a few kilobytes and belongs in the
  /// reproduction; a camera photo is hundreds of kilobytes and does not.
  static const int maxInlineImageBytes = 32 * 1024;

  /// The JSON body as sent, with every inline image over
  /// [maxInlineImageBytes] replaced by a marker carrying its size:
  /// `data:image/jpeg;base64,… (312 KB omitted)`.
  ///
  /// A completion carries megabytes of Base64 that no clipboard or chat
  /// message can take. Everything a validation error refers to, the field
  /// names and their values, is kept verbatim.
  static String body(Map<String, dynamic> body) {
    final shown = <String, dynamic>{};
    body.forEach((key, value) {
      if (value is String &&
          DataUrl.isDataUrl(value) &&
          DataUrl.approxBytes(value) > maxInlineImageBytes) {
        final mime = DataUrl.mimeTypeOf(value) ?? 'image';
        final size = DataUrl.formatBytes(DataUrl.approxBytes(value));
        shown[key] = 'data:$mime;base64,… ($size omitted)';
      } else {
        shown[key] = value;
      }
    });
    return _pretty.convert(shown);
  }

  /// A response body as text: JSON pretty-printed, anything else as is.
  static String? response(dynamic data) {
    if (data == null) return null;
    if (data is String) return data.isEmpty ? null : data;
    try {
      return _pretty.convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  /// One block with the call, what was sent and what came back, in the order
  /// someone reproducing it with curl would need.
  static String report({
    required String method,
    required String url,
    int? statusCode,
    required String message,
    String? requestBody,
    String? responseBody,
  }) {
    final b = StringBuffer()
      ..writeln('$method $url')
      ..writeln('Content-Type: application/json')
      ..writeln('Authorization: Bearer <token>')
      ..writeln()
      ..writeln('--- Request body ---')
      ..writeln(requestBody ?? '(not captured)')
      ..writeln()
      ..writeln('--- Response: HTTP ${statusCode ?? "no response"} ---')
      ..writeln(responseBody ?? message);
    return b.toString();
  }
}
