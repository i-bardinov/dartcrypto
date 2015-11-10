library dartcrypto.ciphers.rc4;

import 'dart:math' as math show pow;

class RC4 {
  List key = null;
  List s_box = null;

  int n = 256;

  RC4([int blockSize = 8, this.key]) {
    this.n = math.pow(2, blockSize);
  }

  void init() {
    for (int i = 0; i < n; i++) s_box.add(i);
    int j = 0, keySize = key.length;
    for (int i = 0; i < n; i++) {
      j = (j + s_box[i] + key[i % keySize]) % n;
      int temp = s_box[i];
      s_box[i] = s_box[j];
      s_box[j] = temp;
    }
  }

  void generateRandomByte() {
    int i = 0, j = 0;
    i = (i + 1) % n;
    j = (j + s_box[i]) % n;
    int temp = s_box[i];
    s_box[i] = s_box[j];
    s_box[j] = temp;
    return s_box[(s_box[i] + s_box[j]) % n];
  }

  List encrypt(List message) {
    init();
    int messageSize = message.length;
    for (int i = 0;
        i < messageSize;
        i++) message[i] = message[i] ^ generateRandomByte;
    return message;
  }

  List decrypt(List message) {
    init();
    int messageSize = message.length;
    for (int i = 0;
        i < messageSize;
        i++) message[i] = message[i] ^ generateRandomByte;
    return message;
  }
}
