library dartcrypto.ciphers.otp;

import 'dart:math';
import 'package:dartcrypto/src/exceptions.dart';

class OTPCipher {
  List key = [0];
  int modulo;

  OTPCipher(this.modulo, [this.key]);

  String checkKey([int key_length = 0]) {
    if (key.isEmpty) return 'Key is incorrect!';
    if (key_length != 0 && key.length < key_length) {
      Random rand = new Random();
      List list = new List();
      key.forEach( (f) => list.add(f));
      for (int i = 0; i < key_length-key.length; i++) list.add(rand.nextInt(modulo));
      key = list;
    }
    return '';
  }

  void generateKey(int length) {
    Random rand = new Random();
    key = new List();
    for (int i = 0; i < length; i++) key.add(rand.nextInt(modulo));
  }

  List encrypt(List message) {
    String error = checkKey(message.length);
    if (error != '') throw new PopUpError(error);
    for (int i = 0; i < message.length; i++) message[i] = message[i] ^ key[i];
    return message;
  }

  List decrypt(List message) {
    String error = checkKey(message.length);
    if (error != '') throw new PopUpError(error);
    for (int i = 0; i < message.length; i++) message[i] = message[i] ^ key[i];
    return message;
  }
}
