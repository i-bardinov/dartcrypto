import 'packages/dartcrypto/dartcrypto.dart';
import 'utils.dart';
import 'dart:html';

DivElement body;

void main() {
  SelectElement type = querySelector("#SelectType");
  SelectElement cryptosystem = querySelector("#SelectCrypto");
  type.onChange.listen((e) =>
      buildStructure(int.parse(cryptosystem.value), int.parse(type.value)));
  cryptosystem.onChange.listen((e) =>
      buildStructure(int.parse(cryptosystem.value), int.parse(type.value)));
  body = querySelector("#CryptoBody");
}

void buildStructure(int cryptosystem, int type) {
  clear();
  if (cryptosystem == null ||
      type == null) throw new ArgumentError.notNull('cryptosystem');

  // ALPHABET
  var PElement1 = new ParagraphElement()..text = TEXT_ALPHABET;
  var textAreaAlphabet = new TextAreaElement()..value = ALPHABET_STANDARD;
  PElement1.children
    ..add(new BRElement())
    ..add(new BRElement())
    ..add(textAreaAlphabet);
  body.children.add(PElement1);

  // MESSAGE
  var PElement2 = new ParagraphElement();
  if (type == CIPHER_TYPE_ENCRYPT) {
    PElement2.text = TEXT_MESSAGE_TO_ENCRYPT;
  } else if (type == CIPHER_TYPE_DECRYPT) {
    PElement2.text = TEXT_MESSAGE_TO_DECRYPT;
  }
  var textArea = new TextAreaElement();
  PElement2.children..add(new BRElement())..add(new BRElement())..add(textArea);
  body.children.add(PElement2);

  // KEY
  var PElement3 = new ParagraphElement();
  if (cryptosystem == CIPHER_AFFINE) PElement3.text = TEXT_KEY_AFFINE;
  else if (cryptosystem == CIPHER_CAESAR) PElement3.text = TEXT_KEY_CAESAR;
  else PElement3.text = TEXT_KEY_HILL;
  // Generate key button
  var buttonGenerate = new ButtonElement()..text = BUTTON_GENERATE_KEY;
  if (cryptosystem != CIPHER_CAESAR) PElement3.children.add(buttonGenerate);
  PElement3.children..add(new BRElement())..add(new BRElement());

  var keyAInput = new InputElement();
  var keyBInput = new InputElement();
  var keyTextArea = new TextAreaElement();
  if (cryptosystem == CIPHER_CAESAR || cryptosystem == CIPHER_AFFINE) {
    keyAInput
      ..type = "text"
      ..value = "1"
      ..size = 10
      ..pattern = "^[ 0-9]";
    keyBInput
      ..type = "text"
      ..value = "0"
      ..size = 10
      ..pattern = "^[ 0-9]";
    if (cryptosystem == CIPHER_AFFINE) {
      PElement3.children
        ..add(keyAInput)
        ..add(new BRElement())
        ..add(new BRElement());
    }
    PElement3.children.add(keyBInput);
  } else {
    PElement3.children.add(keyTextArea);
  }

  body.children.add(PElement3);

  // RESULT BUTTON
  var buttonResult = new ButtonElement();
  if (type == CIPHER_TYPE_ENCRYPT) {
    buttonResult.text = BUTTON_ENCRYPT_MESSAGE;
  } else if (type == CIPHER_TYPE_DECRYPT) {
    buttonResult.text = BUTTON_DECRYPT_MESSAGE;
  }
  body.children.add(buttonResult);

  // RESULT MESSAGE
  var PElement4 = new ParagraphElement();
  if (type == CIPHER_TYPE_ENCRYPT) {
    PElement4.text = TEXT_ENCRYPTED_MESSAGE;
  } else if (type == CIPHER_TYPE_DECRYPT) {
    PElement4.text = TEXT_DECRYPTED_MESSAGE;
  }
  var resultTextArea = new TextAreaElement();
  PElement4.children
    ..add(new BRElement())
    ..add(new BRElement())
    ..add(resultTextArea);
  body.children.add(PElement4);

  // Buttons, TextAreas, Fields listen
  switch (cryptosystem) {
    case CIPHER_CAESAR:
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
            resultTextArea.value = convertToString(
                cipher.encrypt(
                    convertToList(textArea.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      } else if (type == CIPHER_TYPE_DECRYPT) {
        buttonResult.onClick.listen((e) =>
            resultTextArea.value = convertToString(
                cipher.decrypt(
                    convertToList(textArea.value, textAreaAlphabet.value)),
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
            resultTextArea.value = convertToString(
                cipher.encrypt(
                    convertToList(textArea.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      } else if (type == CIPHER_TYPE_DECRYPT) {
        buttonResult.onClick.listen((e) =>
            resultTextArea.value = convertToString(
                cipher.decrypt(
                    convertToList(textArea.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      }
      buttonGenerate.onClick.listen((e) {
        cipher.generateKey();
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
            resultTextArea.value = convertToString(
                cipher.encrypt(
                    convertToList(textArea.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      } else if (type == CIPHER_TYPE_DECRYPT) {
        buttonResult.onClick.listen((e) =>
            resultTextArea.value = convertToString(
                cipher.decrypt(
                    convertToList(textArea.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      }
      buttonGenerate.onClick.listen((e) {
        cipher.generateKey();
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
            resultTextArea.value = convertToString(
                cipher.encrypt(
                    convertToList(textArea.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      } else if (type == CIPHER_TYPE_DECRYPT) {
        buttonResult.onClick.listen((e) =>
            resultTextArea.value = convertToString(
                cipher.decrypt(
                    convertToList(textArea.value, textAreaAlphabet.value)),
                textAreaAlphabet.value));
      }
      buttonGenerate.onClick.listen((e) {
        cipher.generateKey();
        keyTextArea.value = convertToString(cipher.key, textAreaAlphabet.value);
      });
      break;
  }
}

void clear() {
  body.children.clear();
}
