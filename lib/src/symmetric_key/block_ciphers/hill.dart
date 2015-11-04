library dartcrypto.ciphers.hill;

import 'dart:math';
import 'package:dartcrypto/src/utils/matrix.dart';
import "package:dartcrypto/src/exceptions.dart";

class HillCipher {
  List key = null;
  Matrix mKey = null;
  int dimension = 0;
  int modulo = 0;

  HillCipher(this.modulo, [this.key]);

  String checkKey() {
    if (key == null || key.isEmpty) return 'Key is null!';
    if ((mKey == null && key != null) || (mKey.toList() != key)) {
      int dim = sqrt(key.length).ceil();
      dimension = dim;
      List list = new List();
      key.forEach( (f) => list.add(f));
      while (list.length < pow(dim, 2)) list.add(0x00);
      key = list;
      mKey = new Matrix(dimension, dimension, key, modulo);
    }
    if (pow(dimension, 2) !=
        mKey.toList().length) return "Incorrect key size!";
    int det = mKey.determinant();
    if (det == 0 ||
        det.gcd(modulo) != 1 ||
        det.modInverse(modulo) ==
            null) return 'Determinant should be prime!';
    return '';
  }

  void generateKey(int dim) {
    Matrix tkey = new Matrix.Random(dim, dim, modulo);
    int det = tkey.determinant();
    if (det == 0 || det.modInverse(modulo) == null) {
      generateKey(dim);
      return;
    }
    mKey = tkey;
    dimension = dim;
  }

  List encrypt(List message) {
    String error = checkKey();
    if (error != '') throw new PopUpError(error);
    List list = new List();
    message.forEach((f)=> list.add(f));
    while (list.length % dimension != 0) list.add(0x00);
    message = list;
    List encMessage = new List();
    int k = -1;
    for (int i = 0; i < message.length; i++) {
      int temp = 0;
      if (i % dimension == 0) k++;
      for (int j = 0; j < dimension; j++) {
        temp = temp + mKey[i % dimension][j] * message[j + k * dimension];
      }
      encMessage.add(temp % modulo);
    }
    return encMessage;
  }

  List decrypt(List message) {
    String error = checkKey();
    if (error != '') throw new PopUpError(error);
    List list = new List();
    message.forEach((f)=> list.add(f));
    while (list.length % dimension != 0) list.add(0x00);
    message = list;
    Matrix invKey = mKey.inverse();
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
