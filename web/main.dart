import 'package:dartcrypto/dartcrypto.dart';
import 'package:dartcrypto/src/exceptions.dart';
import 'utils.dart';
import 'dart:html';
import 'dart:math';
import 'dart:convert';

var streamEncrypt = null;
var streamDecrypt = null;
var streamKeyChange = null;

void main() {
  SelectElement cryptosystem = querySelector("#SelectCrypto");
  cryptosystem.onChange.listen((e) => buildStructure(
      int.parse(cryptosystem.value)));
}

void buildStructure(int cryptosystem) {
  if (cryptosystem == null) throw new PopUpError('Select Cryptosystem!');

  TextAreaElement inputTextArea = querySelector("#inputTextArea");
  TextAreaElement keyTextArea = querySelector("#keyTextArea");
  TextAreaElement outputTextArea = querySelector("#outputTextArea");
  DivElement encryptButton = querySelector("#encryptButton");
  DivElement decryptButton = querySelector("#decryptButton");

  if (streamEncrypt != null) streamEncrypt.cancel();
  if (streamDecrypt != null) streamDecrypt.cancel();
  if (streamKeyChange != null) streamKeyChange.cancel();

  Random rand = new Random();
  switch (cryptosystem) {
    case CIPHER_CAESAR:
      AffineCipher cipher = new AffineCipher(256);
      if (keyTextArea.value != null && keyTextArea.value.isNotEmpty) cipher.key_B = hexStringToBytes(keyTextArea.value)[0];
      streamKeyChange = keyTextArea.onChange.listen((e) => cipher.key_B = hexStringToBytes(keyTextArea.value)[0]);
      streamEncrypt = encryptButton.onClick.listen((e) => outputTextArea.value = bytesToHexString(cipher.encrypt(hexStringToBytes(inputTextArea.value))));
      streamDecrypt = decryptButton.onClick.listen((e) => inputTextArea.value = bytesToHexString(cipher.decrypt(hexStringToBytes(outputTextArea.value))));
      break;
    case CIPHER_AFFINE:
      AffineCipher cipher = new AffineCipher(256);
      if (keyTextArea.value != null && keyTextArea.value.isNotEmpty) cipher.key_A = hexStringToBytes(keyTextArea.value)[0];
      if (keyTextArea.value != null && keyTextArea.value.isNotEmpty) cipher.key_B = hexStringToBytes(keyTextArea.value)[1];
      streamKeyChange = keyTextArea.onChange.listen((e) {
        cipher.key_A = hexStringToBytes(keyTextArea.value)[0];
        cipher.key_B = hexStringToBytes(keyTextArea.value)[1];
      });
      streamEncrypt = encryptButton.onClick.listen((e) => outputTextArea.value = bytesToHexString(cipher.encrypt(hexStringToBytes(inputTextArea.value))));
      streamDecrypt = decryptButton.onClick.listen((e) => inputTextArea.value = bytesToHexString(cipher.decrypt(hexStringToBytes(outputTextArea.value))));
      break;
    case CIPHER_HILL:
      HillCipher cipher = new HillCipher(256);
      cipher.setKey(hexStringToBytes(keyTextArea.value));
      keyTextArea.value = bytesToHexString(cipher.key.toList());
      streamKeyChange = keyTextArea.onChange.listen((e) {
        cipher.setKey(hexStringToBytes(keyTextArea.value));
        keyTextArea.value = bytesToHexString(cipher.key.toList());
      });
      streamEncrypt = encryptButton.onClick.listen((e) => outputTextArea.value = bytesToHexString(cipher.encrypt(hexStringToBytes(inputTextArea.value))));
      streamDecrypt = decryptButton.onClick.listen((e) => inputTextArea.value = bytesToHexString(cipher.decrypt(hexStringToBytes(outputTextArea.value))));
      break;
    case CIPHER_VIGENERE:
      VigenereCipher cipher = new VigenereCipher(256, hexStringToBytes(keyTextArea.value));
      streamKeyChange = keyTextArea.onChange.listen((e) => cipher.key = hexStringToBytes(keyTextArea.value));
      streamEncrypt = encryptButton.onClick.listen((e) => outputTextArea.value = bytesToHexString(cipher.encrypt(hexStringToBytes(inputTextArea.value))));
      streamDecrypt = decryptButton.onClick.listen((e) => inputTextArea.value = bytesToHexString(cipher.decrypt(hexStringToBytes(outputTextArea.value))));
      break;
    case CIPHER_BEAUFORT:
      BeaufortCipher cipher = new BeaufortCipher(256, hexStringToBytes(keyTextArea.value));
      streamKeyChange = keyTextArea.onChange.listen((e) => cipher.key = hexStringToBytes(keyTextArea.value));
      streamEncrypt = encryptButton.onClick.listen((e) => outputTextArea.value = bytesToHexString(cipher.encrypt(hexStringToBytes(inputTextArea.value))));
      streamDecrypt = decryptButton.onClick.listen((e) => inputTextArea.value = bytesToHexString(cipher.decrypt(hexStringToBytes(outputTextArea.value))));
      break;
    case CIPHER_VERNAM:
      VernamCipher cipher = new VernamCipher(256, hexStringToBytes(keyTextArea.value));
      streamKeyChange = keyTextArea.onChange.listen((e) => cipher.key = hexStringToBytes(keyTextArea.value));
      streamEncrypt = encryptButton.onClick.listen((e) => outputTextArea.value = bytesToHexString(cipher.encrypt(hexStringToBytes(inputTextArea.value))));
      streamDecrypt = decryptButton.onClick.listen((e) => inputTextArea.value = bytesToHexString(cipher.decrypt(hexStringToBytes(outputTextArea.value))));
      break;
    case CIPHER_AES:
    /*buttonResult.onClick.listen((e) {
        resultTextAreaHex.value =
            bytesToHexString(hexStringToBytes(textAreaHex.value));
      });*/
      break;
  }
}
