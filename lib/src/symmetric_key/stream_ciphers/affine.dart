library dartcrypto.ciphers.affine;

import 'dart:math';
import 'package:dartcrypto/src/exceptions.dart';

class AffineCipher {
  int key_A = 1;
  int key_B = 0;
  int modulo = 0;

  AffineCipher(this.modulo, {this.key_A: 1, this.key_B: 0});

  String checkKey() {
    if (modulo <
        1) return "Alphabet size is $modulo! It should be > 0!";
    int gcd = key_A.gcd(modulo);
    if (gcd != 1) return
        "Key[1] = $key_A should be prime!";
    return '';
  }

  void generateKey() {
    Random rand = new Random();
    key_A = rand.nextInt(modulo);
    key_B = rand.nextInt(modulo);
    if (key_A.gcd(modulo) != 1) generateKey();
  }

  List encrypt(List message) {
    String error = checkKey();
    if (error != '') throw new PopUpError(error);
    return message.map((f) => (key_A * f + key_B) % modulo).toList();
  }

  List decrypt(List message) {
    String error = checkKey();
    if (error != '') throw new PopUpError(error);
    int invKey_A = key_A.modInverse(modulo);
    return message.map((f) => (invKey_A * (f - key_B)) % modulo).toList();
  }
}
