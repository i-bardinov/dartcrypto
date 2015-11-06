library dartcrypto.ciphers.vigenere;

import "dart:math" as math show Random;

class VigenereCipher {
  int modulo;
  List key = null;
  static int KEY_MAX_SIZE_VIGENERE = 100;

  VigenereCipher(this.modulo, [this.key]);

  void checkKey([int key_length = 0]) {
    if (key == null || key.isEmpty) throw new Exception("Key is empty");
  }

  void generateKey([int length]) {
    math.Random rand = new math.Random();
    if (length == null) length = rand.nextInt(KEY_MAX_SIZE_VIGENERE);
    key = new List();
    for (int i = 0; i < length; i++) key.add(rand.nextInt(modulo));
  }

  List encrypt(List message) {
    checkKey();
    if (message == null) throw new Exception('Message is null!');
    int keySize = key.length;
    for (int i = 0;
        i < message.length;
        i++) message[i] = (message[i] + key[i % keySize]) % modulo;
    return message;
  }

  List decrypt(List message) {
    checkKey();
    if (message == null) throw new Exception('Message is null!');
    int keySize = key.length;
    for (int i = 0;
        i < message.length;
        i++) message[i] = (message[i] - key[i % keySize]) % modulo;
    return message;
  }
}
