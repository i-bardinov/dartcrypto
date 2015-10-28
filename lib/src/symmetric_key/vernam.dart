library dartcrypto.vernam;

import 'dart:math';
import 'package:dartcrypto/src/exceptions.dart';

class VernamCipher {
  List key = null;
  int modulo;

  VernamCipher(this.modulo, [this.key]);

  void checkKey(int key_length) {
    if (key.isEmpty) throw new PopUpError("Key is empty");
    if (key.length != key_length) throw new PopUpError(
        "Key size is not equival to message size");
  }

  void generateKey(int length) {
    Random rand = new Random();
    key.clear();
    for (int i = 0; i < length; i++) key.add(rand.nextInt(modulo));
  }

  List encrypt(List message) {
    checkKey(message.length);
    for (int i = 0;
        i < message.length;
        i++) message[i] = (message[i] + key[i]) % modulo;
    return message;
  }

  List decrypt(List message) {
    checkKey(message.length);
    for (int i = 0;
        i < message.length;
        i++) message[i] = (message[i] - key[i]) % modulo;
    return message;
  }
}
