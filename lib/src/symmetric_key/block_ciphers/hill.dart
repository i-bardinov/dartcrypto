library dartcrypto.ciphers.hill;

import 'dart:math';
import 'package:dartcrypto/src/utils/matrix.dart';
import "package:dartcrypto/src/exceptions.dart";

class HillCipher {
  Matrix key = null;
  int dimension = 0;
  int modulo = 0;

  HillCipher(this.modulo, {this.dimension, this.key});

  String checkKey() {
    if (key == null || key.isEmpty()) return 'Key is null!';
    if (pow(dimension, 2) !=
        key.toList().length) return "Key length should be square!";
    int det = key.determinant();
    if (det == 0 ||
        det.gcd(modulo) != 1 ||
        det.modInverse(modulo) ==
            null) return 'Determinant should be prime!';
    return '';
  }

  void setKey(List list) {
    int dim = sqrt(list.length).ceil();
    dimension = dim;
    while (list.length < pow(dim, 2)) list.add(0x00);
    key = new Matrix(dim, dim, list, modulo);
  }

  void generateKey(int dim) {
    Matrix tkey = new Matrix.Random(dim, dim, modulo);
    int det = tkey.determinant();
    if (det == 0 || det.modInverse(modulo) == null) {
      generateKey(dim);
      return;
    }
    key = tkey;
    dimension = dim;
  }

  List encrypt(List message) {
    String error = checkKey();
    if (error != '') throw new PopUpError(error);
    while (message.length % dimension != 0) message.add(0);
    List encMessage = new List();
    int k = -1;
    for (int i = 0; i < message.length; i++) {
      int temp = 0;
      if (i % dimension == 0) k++;
      for (int j = 0; j < dimension; j++) {
        temp = temp + key[i % dimension][j] * message[j + k * dimension];
      }
      encMessage.add(temp % modulo);
    }
    return encMessage;
  }

  List decrypt(List message) {
    String error = checkKey();
    if (error != '') throw new PopUpError(error);
    while (message.length % dimension != 0) message.add(0);
    Matrix invKey = key.inverse();
    List decMessage = new List();
    int k = -1;
    for (int i = 0; i < message.length; i++) {
      int temp = 0;
      if (i % dimension == 0) k++;
      for (int j = 0; j < dimension; j++) {
        temp = temp + invKey[i % dimension][j] * message[j + k * dimension];
      }
      decMessage.add(temp % modulo);
    }
    return decMessage;
  }
}
