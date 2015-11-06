library dartcrypto.utils.convert;

import 'package:cryptoutils/cryptoutils.dart';
import 'dart:convert' as convert show LATIN1;

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

List hexStringToBytes(String str) => CryptoUtils.hexToBytes(str);

String bytesToHexString(List list) => CryptoUtils.bytesToHex(list);

String hexStringToString(String str) => bytesToString(hexStringToBytes(str));

String stringToHexString(String str) => bytesToHexString(stringToBytes(str));

List stringToBytes(String str) => convert.LATIN1.encode(str);

String bytesToString(List list) => convert.LATIN1.decode(list);

String bytesToBase64String(List list) => CryptoUtils.bytesToBase64(list);

List base64StringToBytes(String str) => CryptoUtils.base64StringToBytes(str);
