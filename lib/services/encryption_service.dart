import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:archive/archive.dart';
import '../models/app_user_data.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  // Encryption keys provided by the client
  static const String _encryptionKey = 'A7c8Fj29LpqRkTgYe4Vs6DbwM9zQ1uXi'; // 32 chars for AES-256
  static const String _ivKey = 'Nf2Xq4Lm7UvZp1Bd'; // 16 chars for IV

  late final Encrypter _encrypter;
  late final IV _iv;
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return; // Prevent re-initialization

    final key = Key.fromUtf8(_encryptionKey);
    _iv = IV.fromUtf8(_ivKey);
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    _isInitialized = true;
  }

  /// Decrypt base64 encrypted string from API response
  String decryptBase64String(String encryptedBase64) {
    if (!_isInitialized) initialize(); // Ensure initialization
    try {
      // Decode base64 to get encrypted bytes
      final encryptedBytes = base64.decode(encryptedBase64);

      // Create Encrypted object from bytes
      final encrypted = Encrypted(encryptedBytes);

      // Decrypt using AES
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);

      return decrypted;
    } catch (e) {
      throw Exception('Failed to decrypt data: $e');
    }
  }

  /// Encrypt string to base64 for API requests
  String encryptToBase64String(String plainText) {
    if (!_isInitialized) initialize(); // Ensure initialization
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return base64.encode(encrypted.bytes);
    } catch (e) {
      throw Exception('Failed to encrypt data: $e');
    }
  }

  /// Decrypt JSON response from API
  Map<String, dynamic> decryptJsonResponse(String encryptedBase64) {
    if (!_isInitialized) initialize(); // Ensure initialization
    try {
      final decryptedString = decryptBase64String(encryptedBase64);
      return json.decode(decryptedString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to decrypt JSON response: $e');
    }
  }

  /// Generate MD5 hash (if needed for API)
  String generateMD5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  /// Generate SHA256 hash (if needed for API)
  String generateSHA256(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  /// Validate if string is valid base64
  bool isValidBase64(String str) {
    try {
      base64.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Decrypt, decompress and deserialize API response to AppUserData
  AppUserData decryptAndDecompressAndDeserialize(String base64Encrypted) {
    final key = Key.fromUtf8('A7c8Fj29LpqRkTgYe4Vs6DbwM9zQ1uXi');
    final iv = IV.fromUtf8('Nf2Xq4Lm7UvZp1Bd');
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    // Base64 decode, decrypt, and decompress
    final encryptedBytes = base64.decode(base64Encrypted);
    final decryptedBytes = encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);
    final decompressedBytes = GZipDecoder().decodeBytes(decryptedBytes);

    // Decode JSON and deserialize into Dart object
    final jsonString = utf8.decode(decompressedBytes);
    final jsonMap = json.decode(jsonString);

    return AppUserData.fromJson(jsonMap);
  }
}
