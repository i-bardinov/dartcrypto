library dartcrypto.ciphers.vigenere;

import "dart:math";
import 'package:dartcrypto/src/exceptions.dart';

class VigenereCipher {
  int modulo;
  List key = [0];

  VigenereCipher(this.modulo, [this.key]);

  void checkKey([int key_length = 0]) {
    if (key.isEmpty) throw new Exception("Key is incorrect");
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
        i++) message[i] = (message[i] - key[i % keySize]) % modulo;
    return message;
  }
}
