library dartcrypto.ciphers.hill;

import 'dart:math';
import 'package:dartcrypto/src/utils/matrix.dart';
import "package:dartcrypto/src/exceptions.dart";
import 'modes.dart';

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
      key.forEach((f) => list.add(f));
      while (list.length < pow(dim, 2)) list.add(0x00);
      key = list;
      mKey = new Matrix(dimension, dimension, key, modulo);
    }
    if (pow(dimension, 2) != mKey.toList().length) return "Incorrect key size!";
    int det = mKey.determinant();
    if (det == 0 ||
        det.gcd(modulo) != 1 ||
        det.modInverse(modulo) == null) return 'Determinant should be prime!';
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

  List block_encrypt(List message) {
    List list = new List();
    for (int i = 0; i < dimension; i++) {
      int temp = 0;
      for (int j = 0; j < dimension; j++) {
        temp = temp + mKey[i][j] * message[j];
      }
      list.add(temp % modulo);
    }
    return list;
  }

  List encrypt(List message, {int mode: BLOCK_MODE_ECB, List initVec: null}) {
    String error = checkKey();
    if (error != '') throw new PopUpError(error);
    List list = new List();
    message.forEach((f) => list.add(f));
    while (list.length % dimension != 0) list.add(0x00);
    message = list;

    if (initVec != null) print(initVec.toString());

    List encMessage = new List();
    switch (mode) {
      case BLOCK_MODE_ECB:
        for (int i = 0; i < message.length; i += dimension) ECB_mode_encryption(
                message.sublist(i, i + dimension), block_encrypt)
            .forEach((f) => encMessage.add(f));
        break;
      case BLOCK_MODE_CBC:
        if (initVec == null || initVec.length != dimension) return null;
        List temp = initVec;
        for (int i = 0; i < message.length; i += dimension) {
          temp = CBC_mode_encryption(
              message.sublist(i, i + dimension), temp, block_encrypt);
          temp.forEach((f) => encMessage.add(f));
        }
        break;
      case BLOCK_MODE_PCBC:
        if (initVec == null || initVec.length != dimension) return null;
        List prevEnc = initVec;
        List prev = new List.generate(dimension, (f) => 0);
        for (int i = 0; i < message.length; i += dimension) {
          prevEnc = PCBC_mode_encryption(
              message.sublist(i, i + dimension), prev, prevEnc, block_encrypt);
          prevEnc.forEach((f) => encMessage.add(f));
          prev = message.sublist(i, i + dimension);
        }
        break;
      case BLOCK_MODE_CFB:
        if (initVec == null || initVec.length != dimension) return null;
        List temp = initVec;
        for (int i = 0; i < message.length; i += dimension) {
          temp = CFB_mode_encryption(
              message.sublist(i, i + dimension), temp, block_encrypt);
          temp.forEach((f) => encMessage.add(f));
        }
        break;
      default:
        for (int i = 0; i < message.length; i += dimension) ECB_mode_encryption(
            message.sublist(i, i + dimension), block_encrypt)
        .forEach((f) => encMessage.add(f));
    }
    return encMessage;
  }

  List block_decrypt(List message) {
    Matrix invKey = mKey.inverse();
    List list = new List();
    for (int i = 0; i < dimension; i++) {
      int temp = 0;
      for (int j = 0; j < dimension; j++) {
        temp = temp + invKey[i][j] * message[j];
      }
      list.add(temp % modulo);
    }
    return list;
  }

  List decrypt(List message, {int mode: BLOCK_MODE_ECB, List initVec: null}) {
    String error = checkKey();
    if (error != '') throw new PopUpError(error);
    List list = new List();
    message.forEach((f) => list.add(f));
    while (list.length % dimension != 0) list.add(0x00);
    message = list;

    List decMessage = new List();
    switch (mode) {
      case BLOCK_MODE_ECB:
        for (int i = 0; i < message.length; i += dimension) ECB_mode_decryption(
                message.sublist(i, i + dimension), block_decrypt)
            .forEach((f) => decMessage.add(f));
        break;
      case BLOCK_MODE_CBC:
        if (initVec == null || initVec.length != dimension) return null;
        List temp = initVec;
        for (int i = 0; i < message.length; i += dimension) {
          CBC_mode_decryption(
                  message.sublist(i, i + dimension), temp, block_decrypt)
              .forEach((f) => decMessage.add(f));
          temp = message.sublist(i, i + dimension);
        }
        break;
      case BLOCK_MODE_PCBC:
        if (initVec == null || initVec.length != dimension) return null;
        List prevEnc = initVec;
        List prev = new List.generate(dimension, (f) => 0);
        for (int i = 0; i < message.length; i += dimension) {
          prev = PCBC_mode_decryption(
              message.sublist(i, i + dimension), prev, prevEnc, block_decrypt);
          prev.forEach((f) => decMessage.add(f));
          prevEnc = message.sublist(i, i + dimension);
        }
        break;
      case BLOCK_MODE_CFB:
        if (initVec == null || initVec.length != dimension) return null;
        List temp = initVec;
        for (int i = 0; i < message.length; i += dimension) {
          CFB_mode_decryption(
                  message.sublist(i, i + dimension), temp, block_encrypt)
              .forEach((f) => decMessage.add(f));
          temp = message.sublist(i, i + dimension);
        }
        break;
      default:
        for (int i = 0; i < message.length; i += dimension) ECB_mode_decryption(
            message.sublist(i, i + dimension), block_decrypt)
        .forEach((f) => decMessage.add(f));
    }
    return decMessage;
  }
}
