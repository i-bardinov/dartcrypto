library dartcrypto.ciphers.otp;

import 'dart:math' as math show Random;

class OTPCipher {
  List key = null;
  int modulo;

  OTPCipher(this.modulo, [this.key]);

  void checkKey([int mess_length = 0]) {
    if (key == null || key.isEmpty) throw new Exception("Key is empty");
    if (key.length != mess_length) throw new Exception('Key size is less than message!');
  }

  void generateKey(int length) {
    math.Random rand = new math.Random();
    key = new List();
    for (int i = 0; i < length; i++) key.add(rand.nextInt(modulo));
  }

  List encrypt(List message) {
    checkKey(message.length);
    if (message == null) throw new Exception('Message is null!');
    for (int i = 0; i < message.length; i++) message[i] = message[i] ^ key[i];
    return message;
  }

  List decrypt(List message) {
    checkKey(message.length);
    if (message == null) throw new Exception('Message is null!');
    for (int i = 0; i < message.length; i++) message[i] = message[i] ^ key[i];
    return message;
  }
}
