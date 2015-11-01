library dartcrypto.utils.convert;

import 'package:crypto/crypto.dart';
import 'package:dartcrypto/src/exceptions.dart';
import 'dart:convert';

String bytesToStringByAlphabet(List list, [String alphabet]) {
  if (list == null) throw new ArgumentError.notNull('list');
  if (alphabet == null) return new String.fromCharCodes(list);

  String str = '';
  int mod = alphabet.length;
  list.forEach((f) => str += alphabet[f % mod]);
  return str;
}

List stringToBytesByAlphabet(String str, [String alphabet]) {
  if (str == null) throw new ArgumentError.notNull('str');
  if (alphabet == null) return str.runes.toList();

  int alphabetSize = alphabet.length;
  List list = new List();
  for (int i = 0; i < str.length; i++) for (int j = 0;
      j < alphabetSize;
      j++) if (str[i] == alphabet[j]) list.add(j);
  return list;
}

List hexStringToBytes(String str) {
  List list = new List();
  int len = str.length;
  if (len != (len / 2).floor() * 2) throw new PopUpError(
      "Cannot response hexadecimal number!");
  for (int i = 0; i < len; i += 2) list.add(int.parse(str[i] + str[i + 1],
      radix: 16,
      onError: (source) =>
          throw new PopUpError("Message should be hexadecimal")));
  return list;
}

String bytesToHexString(List list) {
  return CryptoUtils.bytesToHex(list);
}

String hexStringToString(String str) {
  return bytesToString(hexStringToBytes(str));
}

String stringToHexString(String str) {
  return bytesToHexString(stringToBytes(str));
}

List stringToBytes(String str) {
  return UTF8.encode(str);
}

String bytesToString(List list) {
  return UTF8.decode(list);
}
