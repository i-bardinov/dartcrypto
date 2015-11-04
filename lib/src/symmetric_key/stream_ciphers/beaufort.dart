library dartcrypto.ciphers.beaufort;

import "dart:math";
import 'package:dartcrypto/src/exceptions.dart';

class BeaufortCipher {
  int modulo;
  List key = [0];

  BeaufortCipher(this.modulo, [this.key]);

  String checkKey([int key_length = 0]) {
    if (key.isEmpty) return "Key is incorrect";
    return '';
  }

  void generateKey(int length) {
    Random rand = new Random();
    key.clear();
    for (int i = 0; i < length; i++) key.add(rand.nextInt(modulo));
  }

  List encrypt(List message) {
    String error = checkKey();
    if (error != '') throw new PopUpError(error);
    int keySize = key.length;
    for (int i = 0;
        i < message.length;
        i++) message[i] = key[i % keySize] ^ message[i];
    return message;
  }

  List decrypt(List message) {
    String error = checkKey();
    if (error != '') throw new PopUpError(error);
    int keySize = key.length;
    for (int i = 0;
        i < message.length;
        i++) message[i] = key[i % keySize] ^ message[i];
    return message;
  }
}
