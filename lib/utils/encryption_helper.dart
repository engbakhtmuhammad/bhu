import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  static final String keyString = 'A7c8Fj29LpqRkTgYe4Vs6DbwM9zQ1uXi'; // 32 bytes
  static final String ivString = 'Nf2Xq4Lm7UvZp1Bd'; // 16 bytes

  static String encryptText(String plainText) {
    // Step 1: Compress with GZip
    final inputBytes = utf8.encode(plainText);
    final compressed = GZipEncoder().encode(inputBytes)!;

    // Step 2: Encrypt with AES
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.fromUtf8(ivString);
    final aes = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
    final encrypted = aes.encryptBytes(compressed, iv: iv);

    // Step 3: Return as base64
    return encrypted.base64;
  }
}