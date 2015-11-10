library dartcrypto.ciphers.beaufort;

import "dart:math" as math show Random;

class BeaufortCipher {
  int modulo;
  List key = null;
  static int KEY_MAX_SIZE_BEAUFORT = 100;

  BeaufortCipher(this.modulo, [this.key]);

  void checkKey([int key_length = 0]) {
    if (key == null || key.isEmpty) throw new Exception("Key is empty");
  }

  void generateKey([int length = 32]) {
    math.Random rand = new math.Random();
    if (length == null) length = rand.nextInt(KEY_MAX_SIZE_BEAUFORT)+1;
    key = new List.generate(length, (i) => rand.nextInt(modulo));
  }

  List encrypt(List message) {
    checkKey();
    if (message == null) throw new Exception('Message is null!');
    int keySize = key.length;
    for (int i = 0;
        i < message.length;
        i++) message[i] = key[i % keySize] ^ message[i];
    return message;
  }

  List decrypt(List message) {
    checkKey();
    if (message == null) throw new Exception('Message is null!');
    int keySize = key.length;
    for (int i = 0;
        i < message.length;
        i++) message[i] = key[i % keySize] ^ message[i];
    return message;
  }
}
