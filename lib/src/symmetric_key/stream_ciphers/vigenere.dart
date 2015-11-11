library dartcrypto.ciphers.vigenere;

import "dart:math" as math show Random;

class VigenereCipher {
  int modulo;
  List key = null;

  VigenereCipher(this.modulo, [this.key]);

  void checkKey([int key_length = 0]) {
    if (key == null || key.isEmpty) throw new Exception("Key is empty");
  }

  void generateKey([int length = 32]) {
    math.Random rand = new math.Random();
    key = new List.generate(length, (i) => rand.nextInt(modulo));
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
