library dartcrypto.ciphers.hill;

import 'dart:math' as math;
import 'package:dartcrypto/src/utils/matrix.dart';
import 'modes.dart';

class HillCipher {
  Matrix mkey = null;
  List key = null;
  int dimension = 0;
  int modulo = 0;
  List initVector = null;

  HillCipher(this.modulo, [this.mkey]);

  void checkKey() {
    if (key == null || key.isEmpty) throw new Exception('Key is empty!');
    int tmp = key.length;
    dimension = math.sqrt(tmp).floor();
    if (math.pow(dimension, 2) !=
        tmp) throw new Exception("Incorrect key size! Should be square!");
    mkey = new Matrix(dimension, dimension, key, modulo);
    int det = mkey.determinant();
    if (det == 0 ||
        det.gcd(modulo) != 1 ||
        det.modInverse(modulo) == null) throw new Exception(
        'Determinant $det should be coprime with $modulo!');
  }

  void generateKey([int dim = 4]) {
    math.Random rand = new math.Random();
    Matrix tkey = new Matrix.Random(dim, dim, modulo);
    int det = tkey.determinant();
    if (det == 0 || det.gcd(modulo) != 1 || det.modInverse(modulo) == null) {
      generateKey(dim);
      return;
    }
    initVector = new List.generate(dim, (i) => rand.nextInt(modulo));
    mkey = tkey;
    key = tkey.toList();
    dimension = dim;
  }

  List block_encrypt(List message) {
    List list = new List();
    for (int i = 0; i < dimension; i++) {
      int temp = 0;
      for (int j = 0; j < dimension; j++) {
        temp = temp + mkey[i][j] * message[j];
      }
      list.add(temp % modulo);
    }
    return list;
  }

  List encrypt(List message, {int mode: BLOCK_MODE_ECB}) {
    checkKey();
    List list = new List();
    message.forEach((f) => list.add(f));
    while (list.length % dimension != 0) list.add(0x00);
    message = list;
    List initVec = initVector;

    List encMessage = new List();
    switch (mode) {
      case BLOCK_MODE_ECB:
        for (int i = 0; i < message.length; i += dimension) ECB_mode_encryption(
                message.sublist(i, i + dimension), block_encrypt)
            .forEach((f) => encMessage.add(f));
        break;
      case BLOCK_MODE_CBC:
        if (initVec == null || initVec.length != dimension) throw new Exception(
            'Initial vector is null!');
        List temp = initVec;
        for (int i = 0; i < message.length; i += dimension) {
          temp = CBC_mode_encryption(
              message.sublist(i, i + dimension), temp, block_encrypt);
          temp.forEach((f) => encMessage.add(f));
        }
        break;
      case BLOCK_MODE_PCBC:
        if (initVec == null || initVec.length != dimension) throw new Exception(
            'Initial vector is null!');
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
        if (initVec == null || initVec.length != dimension) throw new Exception(
            'Initial vector is null!');
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
    Matrix invKey = mkey.inverse();
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

  List decrypt(List message, {int mode: BLOCK_MODE_ECB}) {
    checkKey();
    List list = new List();
    message.forEach((f) => list.add(f));
    while (list.length % dimension != 0) list.add(0x00);
    message = list;
    List initVec = initVector;

    List decMessage = new List();
    switch (mode) {
      case BLOCK_MODE_ECB:
        for (int i = 0; i < message.length; i += dimension) ECB_mode_decryption(
                message.sublist(i, i + dimension), block_decrypt)
            .forEach((f) => decMessage.add(f));
        break;
      case BLOCK_MODE_CBC:
        if (initVec == null || initVec.length != dimension) throw new Exception(
            'Initial vector is null!');
        List temp = initVec;
        for (int i = 0; i < message.length; i += dimension) {
          CBC_mode_decryption(
                  message.sublist(i, i + dimension), temp, block_decrypt)
              .forEach((f) => decMessage.add(f));
          temp = message.sublist(i, i + dimension);
        }
        break;
      case BLOCK_MODE_PCBC:
        if (initVec == null || initVec.length != dimension) throw new Exception(
            'Initial vector is null!');
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
        if (initVec == null || initVec.length != dimension) throw new Exception(
            'Initial vector is null!');
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
