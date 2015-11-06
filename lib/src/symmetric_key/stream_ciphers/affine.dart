library dartcrypto.ciphers.affine;

import 'dart:math' as math;

class AffineCipher {
  int key_A = 1;
  int key_B = 0;
  int modulo = 0;

  AffineCipher(this.modulo, {this.key_A: 1, this.key_B: 0});

  void checkKey() {
    if (key_A == null) throw new  Exception("Key 1 is incorrect!");
    if (key_B == null) throw new  Exception("Key 2 is incorrect!");
    if (modulo < 1) throw new  Exception("Alphabet size is $modulo! It should be > 0!");
    int gcd = key_A.gcd(modulo);
    if (gcd != 1) throw new  Exception("Key 1 should be coprime with $modulo!");
  }

  void generateKey() {
    math.Random rand = new math.Random();
    key_A = rand.nextInt(modulo);
    key_B = rand.nextInt(modulo);
    if (key_A.gcd(modulo) != 1) generateKey();
  }

  List encrypt(List message) {
    checkKey();
    if (message == null) return null;
    return message.map((f) => (key_A * f + key_B) % modulo).toList();
  }

  List decrypt(List message) {
    checkKey();
    if (message == null) return null;
    int invKey_A = key_A.modInverse(modulo);
    return message.map((f) => (invKey_A * (f - key_B)) % modulo).toList();
  }
}
