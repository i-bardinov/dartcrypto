import 'package:dartcrypto/dartcrypto.dart';
import 'utils.dart';
import 'dart:html';
import 'scrolling.dart';
import 'toast.dart';

var streamEncrypt = null;
var streamDecrypt = null;
var streamKeyChange = null;
NodeValidator nodeValidator = new NodeValidatorBuilder()
  ..allowTextElements()
  ..allowHtml5()
  ..allowElement('a', attributes: ['href', 'target'])
  ..allowNavigation(new MyUriPolicy());

void main() {
  ElementList menuList = querySelectorAll('.drop ul li a');
  menuList
      .forEach((f) => f.onClick.listen((e) => buildStructure(int.parse(f.id))));
}

void buildStructure(int cryptosystem) {
  if (cryptosystem == null) {
    toast("You didn\'t select anything!");
    return;
  }

  TextAreaElement inputTextArea = querySelector("#inputTextArea");
  TextAreaElement keyTextArea = querySelector("#keyTextArea");
  TextAreaElement outputTextArea = querySelector("#outputTextArea");
  DivElement encryptButton = querySelector("#encryptButton");
  DivElement decryptButton = querySelector("#decryptButton");
  ParagraphElement descriptionParagraph = querySelector("#description");

  if (streamEncrypt != null) streamEncrypt.cancel();
  if (streamDecrypt != null) streamDecrypt.cancel();
  if (streamKeyChange != null) streamKeyChange.cancel();

  descriptionParagraph.children.clear();
  descriptionParagraph.style.display = 'block';

  switch (cryptosystem) {
    case CIPHER_CAESAR:
      descriptionParagraph.setInnerHtml(TEXT_DESCRIPTION_CAESAR,
          validator: nodeValidator);
      AffineCipher cipher = new AffineCipher(256, key_A: 01, key_B: null);
      streamKeyChange = keyTextArea.onChange.listen((e) {
        if (keyTextArea.value.length % 2 != 0) {
          toast('Incorrect key!');
          cipher.key_B = null;
          return;
        }
        if (hexStringToBytes(keyTextArea.value).length == 1) {
          cipher.key_B = hexStringToBytes(keyTextArea.value)[0];
          String error = cipher.checkKey();
          if (error != '') {
            toast(error);
            return;
          }
        } else {
          toast('Key size is not 1 octet!');
          cipher.key_B = null;
        }
      });
      streamEncrypt = encryptButton.onClick.listen((e) {
        String error = cipher.checkKey();
        if (error != '') {
          toast(error);
          outputTextArea.value = '';
          return;
        }
        if (inputTextArea.value.length % 2 != 0) {
          toast('Incorrect message!');
          outputTextArea.value = '';
          return;
        }
        outputTextArea.value = bytesToHexString(
            cipher.encrypt(hexStringToBytes(inputTextArea.value)));
        keyTextArea.value = bytesToHexString([cipher.key_B]);
      });
      streamDecrypt = decryptButton.onClick.listen((e) {
        String error = cipher.checkKey();
        if (error != '') {
          toast(error);
          inputTextArea.value = '';
          return;
        }
        if (outputTextArea.value.length % 2 != 0) {
          toast('Incorrect message!');
          inputTextArea.value = '';
          return;
        }
        inputTextArea.value = bytesToHexString(
            cipher.decrypt(hexStringToBytes(outputTextArea.value)));
        keyTextArea.value = bytesToHexString([cipher.key_B]);
      });
      if (hexStringToBytes(keyTextArea.value).length == 1) {
        cipher.key_B = hexStringToBytes(keyTextArea.value)[0];
      } else toast('Key size is not 1 octet!');
      break;
    case CIPHER_AFFINE:
      descriptionParagraph.appendHtml(TEXT_DESCRIPTION_AFFINE,
          validator: nodeValidator);
      AffineCipher cipher = new AffineCipher(256, key_A: null, key_B: null);
      streamKeyChange = keyTextArea.onChange.listen((e) {
        if (keyTextArea.value.length % 2 != 0) {
          toast('Incorrect key!');
          cipher.key_A = null;
          cipher.key_B = null;
          return;
        }
        if (hexStringToBytes(keyTextArea.value).length == 2) {
          cipher.key_A = hexStringToBytes(keyTextArea.value)[0];
          cipher.key_B = hexStringToBytes(keyTextArea.value)[1];
          String error = cipher.checkKey();
          if (error != '') {
            toast(error);
            return;
          }
        } else {
          toast('Key size is not 2 octet!');
          cipher.key_A = null;
          cipher.key_B = null;
        }
      });
      streamEncrypt = encryptButton.onClick.listen((e) {
        String error = cipher.checkKey();
        if (error != '') {
          toast(error);
          outputTextArea.value = '';
          return;
        }
        if (inputTextArea.value.length % 2 != 0) {
          toast('Incorrect message!');
          outputTextArea.value = '';
          return;
        }
        outputTextArea.value = bytesToHexString(
            cipher.encrypt(hexStringToBytes(inputTextArea.value)));
        keyTextArea.value = bytesToHexString([cipher.key_A, cipher.key_B]);
      });
      streamDecrypt = decryptButton.onClick.listen((e) {
        String error = cipher.checkKey();
        if (error != '') {
          toast(error);
          inputTextArea.value = '';
          return;
        }
        if (outputTextArea.value.length % 2 != 0) {
          toast('Incorrect message!');
          inputTextArea.value = '';
          return;
        }
        inputTextArea.value = bytesToHexString(
            cipher.decrypt(hexStringToBytes(outputTextArea.value)));
        keyTextArea.value = bytesToHexString([cipher.key_A, cipher.key_B]);
      });
      if (hexStringToBytes(keyTextArea.value).length == 2) {
        cipher.key_A = hexStringToBytes(keyTextArea.value)[0];
        cipher.key_B = hexStringToBytes(keyTextArea.value)[1];
      } else toast('Key size is not 2 octet!');
      break;
    case CIPHER_HILL:
      descriptionParagraph.appendHtml(TEXT_DESCRIPTION_HILL,
          validator: nodeValidator);
      HillCipher cipher = new HillCipher(256);
      streamKeyChange = keyTextArea.onChange.listen((e) {
        cipher.setKey(hexStringToBytes(keyTextArea.value));
        keyTextArea.value = bytesToHexString(cipher.key.toList());
      });
      streamEncrypt = encryptButton.onClick.listen((e) {
        outputTextArea.value = bytesToHexString(
            cipher.encrypt(hexStringToBytes(inputTextArea.value)));
        keyTextArea.value = bytesToHexString(cipher.key.toList());
      });
      streamDecrypt = decryptButton.onClick.listen((e) {
        inputTextArea.value = bytesToHexString(
            cipher.decrypt(hexStringToBytes(outputTextArea.value)));
        keyTextArea.value = bytesToHexString(cipher.key.toList());
      });
      cipher.setKey(hexStringToBytes(keyTextArea.value));
      keyTextArea.value = bytesToHexString(cipher.key.toList());
      break;
    case CIPHER_VIGENERE:
      descriptionParagraph.appendHtml(TEXT_DESCRIPTION_VIGENERE,
          validator: nodeValidator);
      VigenereCipher cipher = new VigenereCipher(256);
      streamKeyChange = keyTextArea.onChange
          .listen((e) => cipher.key = hexStringToBytes(keyTextArea.value));
      streamEncrypt = encryptButton.onClick.listen((e) {
        outputTextArea.value = bytesToHexString(
            cipher.encrypt(hexStringToBytes(inputTextArea.value)));
        keyTextArea.value = bytesToHexString(cipher.key);
      });
      streamDecrypt = decryptButton.onClick.listen((e) {
        inputTextArea.value = bytesToHexString(
            cipher.decrypt(hexStringToBytes(outputTextArea.value)));
        keyTextArea.value = bytesToHexString(cipher.key);
      });
      cipher.key = hexStringToBytes(keyTextArea.value);
      break;
    case CIPHER_BEAUFORT:
      descriptionParagraph.appendHtml(TEXT_DESCRIPTION_BEAUFORT,
          validator: nodeValidator);
      BeaufortCipher cipher = new BeaufortCipher(256);
      streamKeyChange = keyTextArea.onChange
          .listen((e) => cipher.key = hexStringToBytes(keyTextArea.value));
      streamEncrypt = encryptButton.onClick.listen((e) {
        outputTextArea.value = bytesToHexString(
            cipher.encrypt(hexStringToBytes(inputTextArea.value)));
        keyTextArea.value = bytesToHexString(cipher.key);
      });
      streamDecrypt = decryptButton.onClick.listen((e) {
        inputTextArea.value = bytesToHexString(
            cipher.decrypt(hexStringToBytes(outputTextArea.value)));
        keyTextArea.value = bytesToHexString(cipher.key);
      });
      cipher.key = hexStringToBytes(keyTextArea.value);
      break;
    case CIPHER_OTP:
      descriptionParagraph.appendHtml(TEXT_DESCRIPTION_OTP,
          validator: nodeValidator);
      OTPCipher cipher = new OTPCipher(256);
      streamKeyChange = keyTextArea.onChange
          .listen((e) => cipher.key = hexStringToBytes(keyTextArea.value));
      streamEncrypt = encryptButton.onClick.listen((e) {
        outputTextArea.value = bytesToHexString(
            cipher.encrypt(hexStringToBytes(inputTextArea.value)));
        keyTextArea.value = bytesToHexString(cipher.key);
      });
      streamDecrypt = decryptButton.onClick.listen((e) {
        inputTextArea.value = bytesToHexString(
            cipher.decrypt(hexStringToBytes(outputTextArea.value)));
        keyTextArea.value = bytesToHexString(cipher.key);
      });
      cipher.key = hexStringToBytes(keyTextArea.value);
      break;
    case CIPHER_AES:
      descriptionParagraph.appendHtml(TEXT_DESCRIPTION_AES,
          validator: nodeValidator);
      break;
    case CIPHER_MAGMA:
      descriptionParagraph.appendHtml(TEXT_DESCRIPTION_MAGMA,
          validator: nodeValidator);
      break;
    case CIPHER_RSA:
      descriptionParagraph.appendHtml(TEXT_DESCRIPTION_RSA,
          validator: nodeValidator);
      break;
    case ENCODING_HEX:
      descriptionParagraph.appendHtml(TEXT_DESCRIPTION_HEX,
          validator: nodeValidator);
      break;
    case HASH_SHA_1:
      descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SHA_1,
          validator: nodeValidator);
      break;
    default:
      toast("Unknown selection!");
  }
  scrollTo(
      encryptButton, getDuration(encryptButton, 2), TimingFunctions.easeInOut);
}

class MyUriPolicy implements UriPolicy {
  bool allowsUri(uri) => true;
}
