import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/utils/server_display.dart';

void main() {
  test('masks all but the first octet of an IPv4 endpoint, keeps the port', () {
    expect(ServerDisplay.mask('https://103.249.198.50:8090/api'),
        '103.***.***.***:8090');
  });

  test('omits the port when the URL has none', () {
    expect(ServerDisplay.mask('https://103.249.198.50/api'), '103.***.***.***');
  });

  test('masks a hostname down to a two-letter hint and its TLD', () {
    expect(ServerDisplay.mask('https://api.switchfiber.ph/api'), 'ap***.ph');
  });

  test('never echoes the full address back', () {
    const url = 'https://103.249.198.50:8090/api';
    expect(ServerDisplay.mask(url), isNot(contains('249')));
    expect(ServerDisplay.mask(url), isNot(contains('198')));
  });

  test('falls back to masking digits when the value is not a URL', () {
    expect(ServerDisplay.mask('10.0.0.1 stuff'), '**.*.*.* stuff');
  });
}
