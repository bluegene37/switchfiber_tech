import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/catalogs/models/catalog_model.dart';
import 'package:swithfiber_tech/features/catalogs/services/catalog_service.dart';

void main() {
  group('Port API Model & Catalog', () {
    test('PortDto parses API json with id, name, description', () {
      final json = {
        'id': 4,
        'name': 'PORT 004',
        'description': 'PORT 004 Description',
        'createdByUserId': 1,
        'createdDate': '2026-06-01T00:00:00',
      };
      final dto = PortDto.fromJson(json);
      expect(dto.id, 4);
      expect(dto.name, 'PORT 004');
      expect(dto.description, 'PORT 004 Description');
      expect(dto.createdByUserId, 1);
      expect(dto.createdDate, DateTime.parse('2026-06-01T00:00:00'));

      final out = dto.toJson();
      expect(out['id'], 4);
      expect(out['name'], 'PORT 004');
      expect(out['description'], 'PORT 004 Description');
    });

    test('CatalogService provides fallback Ports matching live API (PORT 001..PORT 016)', () async {
      final catalog = CatalogService();
      final ports = await catalog.getPorts();
      expect(ports.length, 16);
      expect(ports.first.name, 'PORT 001');
      expect(ports.last.name, 'PORT 016');
      expect(ports.any((p) => p.name == 'PORT 004'), true);
      expect(ports.any((p) => p.name == 'PORT 013'), true);
    });
  });
}
