import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';

/// The API's image columns hold 255 characters, so a completion that carries
/// a real signature or photo inline is refused with HTTP 500 and the job sits
/// on "needs to sync" forever. Until the backend takes uploads, captured
/// images go out as the placeholder URLs the owner chose.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final signature = 'data:image/png;base64,${'A' * 6000}';
  final photo = 'data:image/jpeg;base64,${'B' * 200000}';

  JobOrderDto job() => JobOrderDto(
        id: 3975,
        ticketNumber: 'SF-3975',
        customerName: 'test test',
        address: 'Batingan',
        status: 'Completed',
        onsiteStatus: 'Done',
        clientSignature: signature,
        setupImage: photo,
        houseFront: 'houseFrontPicture',
        boxReadingImage: '',
        isSynced: false,
        updatedAt: DateTime.now(),
      );

  test('a captured signature and photo are sent as the placeholder URLs',
      () async {
    final body = await job().toApiJsonAsync();

    expect(body['clientSignature'], 'https://picsum.photos/200/300?grayscale');
    expect(body['setupImage'], 'https://picsum.photos/200');
    for (final key in JobOrderDto.imageFields) {
      expect((body[key] as String).length, lessThanOrEqualTo(255),
          reason: '$key must fit the server column');
      expect(body[key], isNot(contains('base64')));
    }
  });

  test('a name the server already holds is echoed back untouched', () async {
    final body = await job().toApiJsonAsync();
    expect(body['houseFront'], 'houseFrontPicture');
    expect(body['boxReadingImage'], '',
        reason: 'a job with no photo must not claim one');
  });

  test('the inline form is still available for when the backend is ready',
      () async {
    final body = await job().toApiJsonWithInlineImages();
    expect(body['clientSignature'], signature);
  });
}
