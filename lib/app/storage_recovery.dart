import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/local/app_db.dart';

bool isBadDecrypt(Object e) {
  if (e is PlatformException) {
    final msg = '${e.message ?? ''} ${e.details ?? ''}'.toLowerCase();
    return msg.contains('bad_decrypt') ||
        msg.contains('badpaddingexception') ||
        msg.contains('bad decrypt') ||
        msg.contains('error:1e000065') ||
        msg.contains('cipher functions') ||
        msg.contains('openssl_internal');
  }
  return false;
}

Future<void> wipeAllLocalState(Ref ref) async {
  // Secure storage can hold tokens and sync metadata; a key mismatch breaks reads.
  await const FlutterSecureStorage().deleteAll();

  // Wipe local Drift tables (bookings + scan events) so legacy local data can't
  // appear inconsistent after auth resets.
  await ref.read(appDbProvider).wipeAll();
}

