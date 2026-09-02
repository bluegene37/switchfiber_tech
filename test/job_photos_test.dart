import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/utils/data_url.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/reports/signals/report_signals.dart';

final _photo = DataUrl.encode(Uint8List.fromList(List.filled(64, 7)));
final _signature = DataUrl.encode(Uint8List.fromList(List.filled(32, 3)),
    mimeType: 'image/png');

Map<String, dynamic> _serverRecord() => {
      'id': 813,
      'status': 'Scheduled',
      for (final p in JobPhoto.values)
        p.jsonKey: 'uploads/813/${p.jsonKey}.jpg',
      'clientSignature': 'uploads/813/signature.png',
      'itemName3': 'original-itemName3',
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('photo fields on the job order', () {
    test('every JobPhoto maps to a distinct API field', () {
      final keys = JobPhoto.values.map((p) => p.jsonKey).toSet();
      expect(keys.length, JobPhoto.values.length);
      expect(
          keys, containsAll(['boxReadingImage', 'houseFront', 'setupImage']));
    });

    test('reads all image fields from the API record', () {
      final dto = JobOrderDto.fromJson(_serverRecord());
      for (final p in JobPhoto.values) {
        expect(dto.imageFor(p), 'uploads/813/${p.jsonKey}.jpg', reason: p.name);
        expect(dto.hasImage(p), isTrue);
      }
      expect(dto.hasSignature, isTrue);
    });

    test('survives the Drift round trip', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final dto = JobOrderDto.fromJson({
        ..._serverRecord(),
        'houseFront': _photo,
        'clientSignature': _signature,
      });
      await db.jobOrdersDao.insertOrUpdateJob(dto.toCompanion());
      final back =
          JobOrderDto.fromDrift((await db.jobOrdersDao.getJobById(813))!);
      expect(back.houseFront, _photo);
      expect(back.clientSignature, _signature);
      expect(back.speedtestImage, 'uploads/813/speedtestImage.jpg');
    });

    test('a captured photo reaches the PUT body, untouched ones round-trip',
        () {
      final dto = JobOrderDto.fromJson(_serverRecord());
      final edited = JobOrderDto.fromJson({
        ...jsonDecode(dto.rawJson!) as Map<String, dynamic>,
        'setupImage': _photo,
        'portLabelImage': '',
      });
      final payload = edited.toApiJson();
      expect(payload['setupImage'], _photo);
      expect(payload['portLabelImage'], '',
          reason: 'an explicit clear is sent');
      expect(payload['boxReadingImage'], 'uploads/813/boxReadingImage.jpg');
      expect(payload['itemName3'], 'original-itemName3');
    });

    test('a column the cache does not hold never blanks the server value', () {
      // Simulates a row cached before the photo columns existed: rawJson has
      // the server's value, the modelled field is null.
      final dto = JobOrderDto.fromJson(_serverRecord());
      final stale = JobOrderDto(
        id: dto.id,
        ticketNumber: dto.ticketNumber,
        customerName: dto.customerName,
        address: dto.address,
        status: 'Activated',
        rawJson: dto.rawJson,
      );
      final payload = stale.toApiJson();
      for (final p in JobPhoto.values) {
        expect(payload[p.jsonKey], 'uploads/813/${p.jsonKey}.jpg',
            reason: p.name);
      }
      expect(payload['clientSignature'], 'uploads/813/signature.png');
    });
  });

  group('completion report photos', () {
    late AppDatabase db;
    late JobRepository repository;
    late JobsSignals signals;

    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 100));

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = JobRepository(db.jobOrdersDao);
      signals = JobsSignals(repository);
      await db.jobOrdersDao.insertOrUpdateJob(
          JobOrderDto.fromJson(_serverRecord()).toCompanion());
      await settle();
    });

    tearDown(() async {
      await signals.dispose();
      await db.close();
    });

    test('starts from the photos the job already carries', () {
      final report = ReportSignals()..setJobOrder(signals.allJobs.value.single);
      expect(report.photoFor(JobPhoto.boxReading),
          'uploads/813/boxReadingImage.jpg');
      expect(report.signature.value, 'uploads/813/signature.png');
      expect(report.hasSignature.value, isFalse,
          reason: 'a server path is not something the app can vouch for');
      expect(report.attachedPhotoCount.value, 0);
    });

    test('a captured photo replaces the field, a removal clears it', () {
      final report = ReportSignals()..setJobOrder(signals.allJobs.value.single);
      report.setPhoto(JobPhoto.setup, _photo);
      expect(report.photoFor(JobPhoto.setup), _photo);
      expect(report.attachedPhotoCount.value, 1);

      report.setPhoto(JobPhoto.setup, null);
      expect(report.photoFor(JobPhoto.setup), isNull);
      expect(report.attachedPhotoCount.value, 0);
    });

    test('a drawn signature is required and paths do not count', () {
      final report = ReportSignals()..setJobOrder(signals.allJobs.value.single);
      report.routerSerial.value = 'SN1';
      expect(report.isFormValid.value, isFalse);

      report.setSignature(_signature);
      expect(report.hasSignature.value, isTrue);
      expect(report.isFormValid.value, isTrue);
    });

    test('submitting saves captures, clears removals and keeps the rest',
        () async {
      final report = ReportSignals()..setJobOrder(signals.allJobs.value.single);
      report
        ..setPhoto(JobPhoto.houseFront, _photo)
        ..setPhoto(JobPhoto.speedtest, null)
        ..setSignature(_signature);

      expect(await report.submitReport(repository), isTrue);
      await settle();

      final saved = signals.allJobs.value.single;
      expect(saved.houseFront, _photo);
      expect(saved.speedtestImage, '');
      expect(saved.boxReadingImage, 'uploads/813/boxReadingImage.jpg');
      expect(saved.clientSignature, _signature);
      expect(saved.isActivated, isTrue);

      final payload = saved.toApiJson();
      expect(payload['houseFront'], _photo);
      expect(payload['speedtestImage'], '');
      expect(payload['portLabelImage'], 'uploads/813/portLabelImage.jpg');
      expect(payload['clientSignature'], _signature);
    });
  });
}
