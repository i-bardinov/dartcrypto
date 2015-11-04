library dartcrypto.utils.convert;

import 'package:cryptoutils/cryptoutils.dart';
import 'dart:convert';

String bytesToStringByAlphabet(List list, [String alphabet]) {
  if (list == null) return null;
  if (alphabet == null) return new String.fromCharCodes(list);

  String str = '';
  int mod = alphabet.length;
  list.forEach((f) => str += alphabet[f % mod]);
  return str;
}

List stringToBytesByAlphabet(String str, [String alphabet]) {
  if (str == null) return null;
  if (alphabet == null) return str.runes.toList();

  int alphabetSize = alphabet.length;
  List list = new List();
  for (int i = 0; i < str.length; i++) for (int j = 0;
      j < alphabetSize;
      j++) if (str[i] == alphabet[j]) list.add(j);
  return list;
}

List hexStringToBytes(String str) {
  if (str == null) return null;
  return CryptoUtils.hexToBytes(str);
}

String bytesToHexString(List list) {
  if (list == null) return null;
  return CryptoUtils.bytesToHex(list);
}

String hexStringToString(String str) {
  if (str == null) return null;
  List list = hexStringToBytes(str);
  if (list == null) return null;
  return bytesToString(list);
}

String stringToHexString(String str) {
  if (str == null) return null;
  return bytesToHexString(stringToBytes(str));
}

List stringToBytes(String str) {
  if (str == null) return null;
  //TODO: implement encoding
  return LATIN1.encode(str);
}

String bytesToString(List list) {
  if (list == null) return null;
  //TODO: implement decoding
  return LATIN1.decode(list);
}

String bytesToBase64String(List list) {
  if (list == null) return null;
  return CryptoUtils.bytesToBase64(list);
}

List base64StringToBytes(String str) {
  if (str == null) return null;
  if (str.length % 4 != 0) return null;
  return CryptoUtils.base64StringToBytes(str);
}
