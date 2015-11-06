library dartcrypto.ciphers.beaufort;

import "dart:math" as math;

class BeaufortCipher {
  int modulo;
  List key = [0];

  BeaufortCipher(this.modulo, [this.key]);

  void checkKey([int key_length = 0]) {
    if (key.isEmpty) throw new Exception("Key is incorrect");
  }

  void generateKey(int length) {
    math.Random rand = new math.Random();
    key.clear();
    for (int i = 0; i < length; i++) key.add(rand.nextInt(modulo));
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
