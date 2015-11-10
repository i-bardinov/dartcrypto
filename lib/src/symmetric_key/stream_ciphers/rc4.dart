library dartcrypto.ciphers.rc4;

import 'dart:math' as math show pow, Random;

class RC4Cipher {
  List key = null;
  List s_box = null;

  int n = 256;

  static int KEY_MAX_SIZE = 256;

  RC4Cipher([int blockSize = 8, this.key]) {
    this.n = math.pow(2, blockSize);
  }

  void init() {
    if (key == null) throw new Exception("Key is null!");
    s_box = new List.generate(n, (int k) => k);
    print(s_box.toString());
    int j = 0, keySize = key.length;
    for (int i = 0; i < n; i++) {
      j = (j + s_box[i] + key[i % keySize]) % n;
      int temp = s_box[i];
      s_box[i] = s_box[j];
      s_box[j] = temp;
    }
  }

  int generateRandomByte() {
    int i = 0, j = 0;
    i = (i + 1) % n;
    j = (j + s_box[i]) % n;
    int temp = s_box[i];
    s_box[i] = s_box[j];
    s_box[j] = temp;
    return s_box[(s_box[i] + s_box[j]) % n];
  }

  void generateKey([int length = 32]) {
    math.Random rand = new math.Random();
    if (length == null) length = rand.nextInt(KEY_MAX_SIZE)+1;
    key = new List.generate(length, (i) => rand.nextInt(256));
  }

  List encrypt(List message) {
    if (message == null) throw new Exception("Message is null!");
    init();
    for (int i = 0;
        i < message.length;
        i++) message[i] = message[i] ^ generateRandomByte();
    return message;
  }

  List decrypt(List message) {
    if (message == null) throw new Exception("Message is null!");
    init();
    for (int i = 0;
        i < message.length;
        i++) message[i] = message[i] ^ generateRandomByte();
    return message;
  }
}
