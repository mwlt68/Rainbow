import 'package:encrypt/encrypt.dart';

class AESEncryption {
    static final _key = Key.fromUtf8('dolor sit amet consectetur elits');
    static final _iv = IV.fromLength(16);

  static String getEncryptedMessage(String plainText) {
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }
  static String getDecryptedMessage(String cipherText) {
    final encrypter = Encrypter(AES(_key));
    final decrypted = encrypter.decrypt(Encrypted.from64(cipherText), iv: _iv);
    return decrypted;
  }
}

