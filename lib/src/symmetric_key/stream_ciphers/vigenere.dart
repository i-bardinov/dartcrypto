library dartcrypto.vigenere;

import "dart:math";
import '../../exceptions.dart';

class VigenereCipher {
  int modulo;
  List key = null;

  VigenereCipher(this.modulo, [this.key]);

  void checkKey() {
    if (key.isEmpty) throw new PopUpError("Key is empty");
    key.forEach((f) => f %= modulo);
  }

  void generateKey(int length) {
    Random rand = new Random();
    key.clear();
    for (int i = 0; i < length; i++) key.add(rand.nextInt(modulo));
  }

  List encrypt(List message) {
    checkKey();
    int keySize = key.length;
    for (int i = 0;
        i < message.length;
        i++) message[i] = (message[i] + key[i % keySize]) % modulo;
    return message;
  }

  List decrypt(List message) {
    checkKey();
    int keySize = key.length;
    for (int i = 0;
        i < message.length;
        i++) message[i] = (message[i] - key[i % keySize] + modulo) % modulo;
    return message;
  }
}
