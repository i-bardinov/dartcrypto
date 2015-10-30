import 'package:dartcrypto/dartcrypto.dart';
import 'package:dartcrypto/src/exceptions.dart';
import 'utils.dart';
import 'dart:html';
import 'dart:math';
import 'dart:convert';

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

  Random rand = new Random();
  switch (cryptosystem) {
  /*case CIPHER_CAESAR:
    case CIPHER_AFFINE:
      AffineCipher cipher = new AffineCipher(textAreaAlphabet.value.length,
          int.parse(keyAInput.value), int.parse(keyBInput.value));
      textAreaAlphabet.onChange
          .listen((e) => cipher.modulo = textAreaAlphabet.value.length);
      keyAInput.onChange
          .listen((e) => cipher.key_A = int.parse(keyAInput.value));
      keyBInput.onChange
          .listen((e) => cipher.key_B = int.parse(keyBInput.value));
      if (type == CIPHER_TYPE_ENCRYPT) {
        buttonResult.onClick.listen((e) =>
            resultTextAreaHex.value = convertToString(
                cipher.encrypt(
                    convertToList(textAreaHex.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      } else if (type == CIPHER_TYPE_DECRYPT) {
        buttonResult.onClick.listen((e) =>
            resultTextAreaHex.value = convertToString(
                cipher.decrypt(
                    convertToList(textAreaHex.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      }
      buttonGenerate.onClick.listen((e) {
        cipher.generateKey();
        keyAInput.value = cipher.key_A.toString();
        keyBInput.value = cipher.key_B.toString();
      });
      break;
    case CIPHER_HILL:
      HillCipher cipher = new HillCipher(textAreaAlphabet.value.length);
      textAreaAlphabet.onChange.listen((e) {
        cipher.modulo = textAreaAlphabet.value.length;
        cipher.setKey(convertToList(keyTextArea.value, textAreaAlphabet.value));
      });
      keyTextArea.onChange.listen((e) {
        cipher.setKey(convertToList(keyTextArea.value, textAreaAlphabet.value));
        keyTextArea.value =
            convertToString(cipher.key.toList(), textAreaAlphabet.value);
      });
      if (type == CIPHER_TYPE_ENCRYPT) {
        buttonResult.onClick.listen((e) =>
            resultTextAreaHex.value = convertToString(
                cipher.encrypt(
                    convertToList(textAreaHex.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      } else if (type == CIPHER_TYPE_DECRYPT) {
        buttonResult.onClick.listen((e) =>
            resultTextAreaHex.value = convertToString(
                cipher.decrypt(
                    convertToList(textAreaHex.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      }
      buttonGenerate.onClick.listen((e) {
        cipher.generateKey(rand.nextInt(KEY_MAX_DIM_HILL) + 1);
        keyTextArea.value =
            convertToString(cipher.key.toList(), textAreaAlphabet.value);
      });
      break;
    case CIPHER_VIGENERE:
      VigenereCipher cipher = new VigenereCipher(textAreaAlphabet.value.length,
          convertToList(keyTextArea.value, textAreaAlphabet.value));
      textAreaAlphabet.onChange.listen((e) {
        cipher.modulo = textAreaAlphabet.value.length;
        cipher.key = convertToList(keyTextArea.value, textAreaAlphabet.value);
      });
      keyTextArea.onChange.listen((e) => cipher.key =
          convertToList(keyTextArea.value, textAreaAlphabet.value));
      if (type == CIPHER_TYPE_ENCRYPT) {
        buttonResult.onClick.listen((e) =>
            resultTextAreaHex.value = convertToString(
                cipher.encrypt(
                    convertToList(textAreaHex.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      } else if (type == CIPHER_TYPE_DECRYPT) {
        buttonResult.onClick.listen((e) =>
            resultTextAreaHex.value = convertToString(
                cipher.decrypt(
                    convertToList(textAreaHex.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      }
      buttonGenerate.onClick.listen((e) {
        cipher.generateKey(rand.nextInt(KEY_MAX_SIZE_VIGENERE));
        keyTextArea.value = convertToString(cipher.key, textAreaAlphabet.value);
      });
      break;
    case CIPHER_BEAUFORT:
      BeaufortCipher cipher = new BeaufortCipher(textAreaAlphabet.value.length,
          convertToList(keyTextArea.value, textAreaAlphabet.value));
      textAreaAlphabet.onChange.listen((e) {
        cipher.modulo = textAreaAlphabet.value.length;
        cipher.key = convertToList(keyTextArea.value, textAreaAlphabet.value);
      });
      keyTextArea.onChange.listen((e) => cipher.key =
          convertToList(keyTextArea.value, textAreaAlphabet.value));
      if (type == CIPHER_TYPE_ENCRYPT) {
        buttonResult.onClick.listen((e) =>
            resultTextAreaHex.value = convertToString(
                cipher.encrypt(
                    convertToList(textAreaHex.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      } else if (type == CIPHER_TYPE_DECRYPT) {
        buttonResult.onClick.listen((e) =>
            resultTextAreaHex.value = convertToString(
                cipher.decrypt(
                    convertToList(textAreaHex.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      }
      buttonGenerate.onClick.listen((e) {
        cipher.generateKey(KEY_MAX_SIZE_BEAUFORT);
        keyTextArea.value = convertToString(cipher.key, textAreaAlphabet.value);
      });
      break;*/
    case CIPHER_VERNAM:
      VernamCipher cipher = new VernamCipher(256, hexStringToBytes(keyTextArea.value));
      keyTextArea.onChange.listen((e) => cipher.key = hexStringToBytes(keyTextArea.value));
      encryptButton.onClick.listen((e) => outputTextArea.value = bytesToHexString(cipher.encrypt(hexStringToBytes(inputTextArea.value))));
      decryptButton.onClick.listen((e) => inputTextArea.value = bytesToHexString(cipher.decrypt(hexStringToBytes(outputTextArea.value))));
      break;
    case CIPHER_AES:
    /*buttonResult.onClick.listen((e) {
        resultTextAreaHex.value =
            bytesToHexString(hexStringToBytes(textAreaHex.value));
      });*/
      break;
  }
}

void clear(Element element) {
  element.children.clear();
}
