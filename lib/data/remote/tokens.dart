import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Tokens {
  const Tokens({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
}

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final tokensProvider =
    NotifierProvider<TokensController, Tokens?>(TokensController.new);

class TokensController extends Notifier<Tokens?> {
  @override
  Tokens? build() => null;

  void setTokens(Tokens tokens) => state = tokens;
  void clear() => state = null;
}

class TokenStore {
  static const _accessKey = 'accessToken';
  static const _refreshKey = 'refreshToken';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> save(Tokens tokens) async {
    await _storage.write(key: _accessKey, value: tokens.accessToken);
    await _storage.write(key: _refreshKey, value: tokens.refreshToken);
  }

  Future<Tokens?> read() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    if (access == null || refresh == null) return null;
    return Tokens(accessToken: access, refreshToken: refresh);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

