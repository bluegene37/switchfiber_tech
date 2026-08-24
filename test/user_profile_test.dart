import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/auth/models/user_model.dart';

/// Exactly what GET /api/Users/{id} returns on the live server.
Map<String, dynamic> liveUserRecord() => {
      'fname': 'Gene',
      'mname': 'M',
      'lname': 'Medel',
      'contactnumber': '09438289599',
      'address': 'Binangona',
      'email': 'bluegene37@gmail.com',
      'username': 'bluegene37',
      'password': '1234',
      'active': true,
      'accesslevel_id': 1,
      'id': 1,
      'rowVersion': 0,
    };

void main() {
  group('technician profile', () {
    test('reads the full record the user endpoint returns', () {
      final u = UserModel.fromJson(liveUserRecord());
      expect(u.id, 1);
      expect(u.username, 'bluegene37');
      expect(u.fullName, 'Gene Medel');
      expect(u.email, 'bluegene37@gmail.com');
      expect(u.contactNumber, '09438289599');
      expect(u.address, 'Binangona');
      expect(u.accessLevelId, 1);
      expect(u.active, isTrue);
    });

    test('still reads the leaner shape the login endpoint returns', () {
      final u = UserModel.fromJson({
        'id': 1,
        'username': 'bluegene37',
        'firstName': 'Gene',
        'lastName': 'Medel',
        'accessLevelId': 1,
      });
      expect(u.fullName, 'Gene Medel');
      expect(u.contactNumber, isEmpty);
      expect(u.address, isEmpty);
    });

    test('never keeps the password the API hands back', () {
      final u = UserModel.fromJson(liveUserRecord());
      final serialised = u.toRawJson();
      expect(serialised.toLowerCase(), isNot(contains('password')));
      expect(serialised, isNot(contains('1234')));
      expect(jsonDecode(serialised) as Map<String, dynamic>,
          isNot(contains('password')));
    });

    test('initials come from the name, for the avatar', () {
      expect(UserModel.fromJson(liveUserRecord()).initials, 'GM');
    });

    test('initials fall back to the username when no name is set', () {
      final u = UserModel.fromJson({'id': 2, 'username': 'tech_marcos'});
      expect(u.initials, 'T');
    });

    test('a single name still yields one initial', () {
      final u = UserModel.fromJson(
          {'id': 3, 'username': 'x', 'fname': 'Gene', 'lname': ''});
      expect(u.initials, 'G');
    });
  });
}
