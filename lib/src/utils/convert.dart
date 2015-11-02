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

List hexStringToBytes(String str, {int octets: 1}) {
  int size = octets * 2;
  List list = new List();
  int len = str.length;
  if (len % size !=
      0) throw new PopUpError("Cannot response hexadecimal number!");
  for (int i = 0; i < len; i += size) list.add(int.parse(
      str.substring(i, i + size),
      radix: 16,
      onError: (source) =>
          throw new PopUpError("Message should be hexadecimal")));
  return list;
}

String bytesToHexString(List list) {
  return CryptoUtils.bytesToHex(list);
}

String hexStringToString(String str, {int octets: 2}) {
  return bytesToString(hexStringToBytes(str, octets: octets));
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
