import 'package:dartcrypto/dartcrypto.dart';
import 'utils.dart';
import 'dart:html';
import 'scrolling.dart';
import 'toast.dart';
import 'dart:convert';

NodeValidator nodeValidator = new NodeValidatorBuilder()
  ..allowTextElements()
  ..allowHtml5()
  ..allowElement('a', attributes: ['href', 'target'])
  ..allowElement('div', attributes: ['fit', 'display'])
  ..allowElement('paper-ripple', attributes: ['fit'])
  ..allowElement('input', attributes: ['pattern', 'style', 'display'])
  ..allowElement('textarea', attributes: ['style', 'display'])
  ..allowNavigation(new MyUriPolicy());

void main() {
  ElementList menuList = querySelectorAll('.drop ul li a');
  menuList
      .forEach((f) => f.onClick.listen((e) => buildStructure(int.parse(f.id))));
}

void buildStructure(int type) {
  if (type == null) {
    toast("You didn\'t select anything!");
    return;
  }

  switch (type) {
    case CIPHER_CAESAR:
      buildCaesar();
      break;
    case CIPHER_AFFINE:
      buildAffine();
      break;
    case CIPHER_HILL:
    //case CIPHER_AES:
    //case CIPHER_MAGMA:
      buildBlockCiphers(type);
      break;
    case CIPHER_BEAUFORT:
    case CIPHER_VIGENERE:
    case CIPHER_OTP:
      buildStandardCiphers(type);
      break;
    case CIPHER_RSA:
      //buildRSA();
      break;
    case CIPHER_RSA_GENERATOR:
      break;
    case ENCODINGS:
      buildEncoding();
      break;
  }
}

void buildCaesar() {
  SpanElement wrapper = querySelector('#dynamic');
  wrapper.setInnerHtml('');
  int inputEncode = ENCODING_LATIN1;
  int keyEncode = ENCODING_LATIN1;
  int outputEncode = ENCODING_HEX;

  wrapper.setInnerHtml(HTML_CODE_CAESAR, validator: nodeValidator);

  TextAreaElement inputTextArea = querySelector("#inputTextArea");
  InputElement inputKeyB = querySelector("#keyInputB");
  TextAreaElement outputTextArea = querySelector("#outputTextArea");
  DivElement encryptButton = querySelector("#encryptButton");
  DivElement decryptButton = querySelector("#decryptButton");
  ParagraphElement descriptionParagraph = querySelector('#description');

  querySelector("#plaintextInput").onClick.listen((e) {
    if (inputEncode == ENCODING_HEX) inputTextArea.value =
        hexStringToString(inputTextArea.value);
    if (inputEncode == ENCODING_BASE64) inputTextArea.value =
        bytesToString(base64StringToBytes(inputTextArea.value));
    inputEncode = ENCODING_LATIN1;
  });
  querySelector("#hextextInput").onClick.listen((e) {
    if (inputEncode == ENCODING_LATIN1) inputTextArea.value =
        stringToHexString(inputTextArea.value);
    if (inputEncode == ENCODING_BASE64) inputTextArea.value =
        bytesToHexString(base64StringToBytes(inputTextArea.value));
    inputEncode = ENCODING_HEX;
  });
  querySelector("#base64Input").onClick.listen((e) {
    if (inputEncode == ENCODING_LATIN1) inputTextArea.value =
        bytesToBase64String(stringToBytes(inputTextArea.value));
    if (inputEncode == ENCODING_HEX) inputTextArea.value =
        bytesToBase64String(hexStringToBytes(inputTextArea.value));
    inputEncode = ENCODING_BASE64;
  });
  querySelector("#plaintextKey").onClick.listen((e) {
    if (keyEncode == ENCODING_HEX) inputKeyB.value =
        hexStringToString(inputKeyB.value);
    if (keyEncode == ENCODING_BASE64) inputKeyB.value =
        bytesToString(base64StringToBytes(inputKeyB.value));
    keyEncode = ENCODING_LATIN1;
  });
  querySelector("#hextextKey").onClick.listen((e) {
    if (keyEncode == ENCODING_LATIN1) inputKeyB.value =
        stringToHexString(inputKeyB.value);
    if (keyEncode == ENCODING_BASE64) inputKeyB.value =
        bytesToHexString(base64StringToBytes(inputKeyB.value));
    keyEncode = ENCODING_HEX;
  });
  querySelector("#base64Key").onClick.listen((e) {
    if (keyEncode == ENCODING_LATIN1) inputKeyB.value =
        bytesToBase64String(stringToBytes(inputKeyB.value));

    if (keyEncode == ENCODING_HEX) inputKeyB.value =
        bytesToBase64String(hexStringToBytes(inputKeyB.value));
    keyEncode = ENCODING_BASE64;
  });
  querySelector("#plaintextOutput").onClick.listen((e) {
    if (outputEncode == ENCODING_HEX) outputTextArea.value =
        hexStringToString(outputTextArea.value);
    if (outputEncode == ENCODING_BASE64) outputTextArea.value =
        bytesToString(base64StringToBytes(outputTextArea.value));
    outputEncode = ENCODING_LATIN1;
  });
  querySelector("#hextextOutput").onClick.listen((e) {
    if (outputEncode == ENCODING_LATIN1) outputTextArea.value =
        stringToHexString(outputTextArea.value);
    if (outputEncode == ENCODING_BASE64) outputTextArea.value =
        bytesToHexString(base64StringToBytes(outputTextArea.value));
    outputEncode = ENCODING_HEX;
  });
  querySelector("#base64Output").onClick.listen((e) {
    if (outputEncode == ENCODING_LATIN1) outputTextArea.value =
        bytesToBase64String(stringToBytes(outputTextArea.value));
    if (outputEncode == ENCODING_HEX) outputTextArea.value =
        bytesToBase64String(hexStringToBytes(outputTextArea.value));
    outputEncode = ENCODING_BASE64;
  });

  descriptionParagraph.appendHtml(TEXT_DESCRIPTION_CAESAR,
      validator: nodeValidator);

  AffineCipher cipher = new AffineCipher(256, key_A: 1, key_B: null);
  inputKeyB.onChange.listen((e) {
    if (keyEncode == ENCODING_HEX) cipher.key_B =
        int.parse(inputKeyB.value, radix: 16, onError: (source) => null);
    else if (keyEncode == ENCODING_LATIN1) {
      if (inputKeyB.value.length != 1) {
        toast('Incorrect key size!');
        cipher.key_B = null;
        return;
      } else cipher.key_B = stringToBytes(inputKeyB.value)[0];
    } else if (keyEncode == ENCODING_BASE64) {
      if (inputKeyB.value.length % 4 != 0 ||
          base64StringToBytes(inputKeyB.value).length != 1) {
        toast('Incorrect key!');
        cipher.key_B = null;
        return;
      } else cipher.key_B = base64StringToBytes(inputKeyB.value)[0];
    }
    String error = cipher.checkKey();
    if (error != '') {
      toast(error);
      return;
    }
  });
  encryptButton.onClick.listen((e) {
    outputTextArea.value = '';
    if (keyEncode == ENCODING_HEX) cipher.key_B =
        int.parse(inputKeyB.value, radix: 16, onError: (source) => null);
    else if (keyEncode == ENCODING_LATIN1) {
      if (inputKeyB.value.length != 1) {
        toast('Incorrect key size!');
        cipher.key_B = null;
        return;
      } else cipher.key_B = stringToBytes(inputKeyB.value)[0];
    } else if (keyEncode == ENCODING_BASE64) {
      if (inputKeyB.value.length % 4 != 0 ||
          base64StringToBytes(inputKeyB.value).length != 1) {
        toast('Incorrect key!');
        cipher.key_B = null;
        return;
      } else cipher.key_B = base64StringToBytes(inputKeyB.value)[0];
    }
    String error = cipher.checkKey();
    if (error != '') {
      toast(error);
      return;
    }
    List list = null;
    if (inputEncode == ENCODING_HEX) list =
        cipher.encrypt(hexStringToBytes(inputTextArea.value));
    else if (inputEncode == ENCODING_LATIN1) list =
        cipher.encrypt(stringToBytes(inputTextArea.value));
    else if (inputEncode == ENCODING_BASE64) {
      if (inputTextArea.value.length % 4 != 0) list = null;
      else list = cipher.encrypt(base64StringToBytes(inputTextArea.value));
    }
    if (list == null) toast('Incorrect message!');
    if (outputEncode == ENCODING_HEX) outputTextArea.value =
        bytesToHexString(list);
    else if (outputEncode == ENCODING_LATIN1) outputTextArea.value =
        bytesToString(list);
    else if (outputEncode == ENCODING_BASE64) outputTextArea.value =
        bytesToBase64String(list);
    if (keyEncode == ENCODING_HEX) inputKeyB.value =
        bytesToHexString([cipher.key_B]);
    else if (keyEncode == ENCODING_LATIN1) inputKeyB.value =
        bytesToString([cipher.key_B]);
    else if (keyEncode == ENCODING_BASE64) inputKeyB.value =
        bytesToBase64String([cipher.key_B]);
  });
  decryptButton.onClick.listen((e) {
    inputTextArea.value = '';
    if (keyEncode == ENCODING_HEX) cipher.key_B =
        int.parse(inputKeyB.value, radix: 16, onError: (source) => null);
    else if (keyEncode == ENCODING_LATIN1) {
      if (inputKeyB.value.length != 1) {
        toast('Incorrect key size!');
        cipher.key_B = null;
        return;
      } else cipher.key_B = stringToBytes(inputKeyB.value)[0];
    } else if (keyEncode == ENCODING_BASE64) {
      if (inputKeyB.value.length % 4 != 0 ||
          base64StringToBytes(inputKeyB.value).length != 1) {
        toast('Incorrect key!');
        cipher.key_B = null;
        return;
      } else cipher.key_B = base64StringToBytes(inputKeyB.value)[0];
    }
    String error = cipher.checkKey();
    if (error != '') {
      toast(error);
      return;
    }
    List list = null;
    if (outputEncode == ENCODING_HEX) list =
        cipher.decrypt(hexStringToBytes(outputTextArea.value));
    else if (outputEncode == ENCODING_LATIN1) list =
        cipher.decrypt(stringToBytes(outputTextArea.value));
    else if (outputEncode == ENCODING_BASE64) {
      if (outputTextArea.value.length % 4 != 0) list = null;
      else list = cipher.decrypt(base64StringToBytes(outputTextArea.value));
    }
    if (list == null) toast('Incorrect message!');
    if (inputEncode == ENCODING_HEX) inputTextArea.value =
        bytesToHexString(list);
    else if (inputEncode == ENCODING_LATIN1) inputTextArea.value =
        bytesToString(list);
    else if (inputEncode == ENCODING_BASE64) inputTextArea.value =
        bytesToBase64String(list);
    if (keyEncode == ENCODING_HEX) inputKeyB.value =
        bytesToHexString([cipher.key_B]);
    else if (keyEncode == ENCODING_LATIN1) inputKeyB.value =
        bytesToString([cipher.key_B]);
    else if (keyEncode == ENCODING_BASE64) inputKeyB.value =
        bytesToBase64String([cipher.key_B]);
  });

  scrollTo(
      encryptButton, getDuration(encryptButton, 2), TimingFunctions.easeInOut);
}

void buildAffine() {
  SpanElement wrapper = querySelector('#dynamic');
  wrapper.setInnerHtml('');
  int inputEncode = ENCODING_LATIN1;
  int keyEncode = ENCODING_LATIN1;
  int outputEncode = ENCODING_HEX;

  wrapper.setInnerHtml(HTML_CODE_AFFINE, validator: nodeValidator);

  TextAreaElement inputTextArea = querySelector("#inputTextArea");
  InputElement inputKeyA = querySelector("#keyInputA");
  InputElement inputKeyB = querySelector("#keyInputB");
  TextAreaElement outputTextArea = querySelector("#outputTextArea");
  DivElement encryptButton = querySelector("#encryptButton");
  DivElement decryptButton = querySelector("#decryptButton");
  ParagraphElement descriptionParagraph = querySelector('#description');

  querySelector("#plaintextInput").onClick.listen((e) {
    if (inputEncode == ENCODING_HEX) inputTextArea.value =
        hexStringToString(inputTextArea.value);
    if (inputEncode == ENCODING_BASE64) inputTextArea.value =
        bytesToString(base64StringToBytes(inputTextArea.value));
    inputEncode = ENCODING_LATIN1;
  });
  querySelector("#hextextInput").onClick.listen((e) {
    if (inputEncode == ENCODING_LATIN1) inputTextArea.value =
        stringToHexString(inputTextArea.value);
    if (inputEncode == ENCODING_BASE64) inputTextArea.value =
        bytesToHexString(base64StringToBytes(inputTextArea.value));
    inputEncode = ENCODING_HEX;
  });
  querySelector("#base64Input").onClick.listen((e) {
    if (inputEncode == ENCODING_LATIN1) inputTextArea.value =
        bytesToBase64String(stringToBytes(inputTextArea.value));
    if (inputEncode == ENCODING_HEX) inputTextArea.value =
        bytesToBase64String(hexStringToBytes(inputTextArea.value));
    inputEncode = ENCODING_BASE64;
  });
  querySelector("#plaintextKey").onClick.listen((e) {
    if (keyEncode == ENCODING_HEX) {
      inputKeyA.value = hexStringToString(inputKeyA.value);
      inputKeyB.value = hexStringToString(inputKeyB.value);
    }
    if (keyEncode == ENCODING_BASE64) {
      inputKeyB.value = bytesToString(base64StringToBytes(inputKeyB.value));
      inputKeyA.value = bytesToString(base64StringToBytes(inputKeyA.value));
    }
    keyEncode = ENCODING_LATIN1;
  });
  querySelector("#hextextKey").onClick.listen((e) {
    if (keyEncode == ENCODING_LATIN1) {
      inputKeyA.value = stringToHexString(inputKeyA.value);
      inputKeyB.value = stringToHexString(inputKeyB.value);
    }
    if (keyEncode == ENCODING_BASE64) {
      inputKeyA.value = bytesToHexString(base64StringToBytes(inputKeyA.value));
      inputKeyB.value = bytesToHexString(base64StringToBytes(inputKeyB.value));
    }
    keyEncode = ENCODING_HEX;
  });
  querySelector("#base64Key").onClick.listen((e) {
    if (keyEncode == ENCODING_LATIN1) {
      inputKeyA.value = bytesToBase64String(stringToBytes(inputKeyA.value));
      inputKeyB.value = bytesToBase64String(stringToBytes(inputKeyB.value));
    }
    if (keyEncode == ENCODING_HEX) {
      inputKeyA.value = bytesToBase64String(hexStringToBytes(inputKeyA.value));
      inputKeyB.value = bytesToBase64String(hexStringToBytes(inputKeyB.value));
    }
    keyEncode = ENCODING_BASE64;
  });
  querySelector("#plaintextOutput").onClick.listen((e) {
    if (outputEncode == ENCODING_HEX) outputTextArea.value =
        hexStringToString(outputTextArea.value);
    if (outputEncode == ENCODING_BASE64) outputTextArea.value =
        bytesToString(base64StringToBytes(outputTextArea.value));
    outputEncode = ENCODING_LATIN1;
  });
  querySelector("#hextextOutput").onClick.listen((e) {
    if (outputEncode == ENCODING_LATIN1) outputTextArea.value =
        stringToHexString(outputTextArea.value);
    if (outputEncode == ENCODING_BASE64) outputTextArea.value =
        bytesToHexString(base64StringToBytes(outputTextArea.value));
    outputEncode = ENCODING_HEX;
  });
  querySelector("#base64Output").onClick.listen((e) {
    if (outputEncode == ENCODING_LATIN1) outputTextArea.value =
        bytesToBase64String(stringToBytes(outputTextArea.value));
    if (outputEncode == ENCODING_HEX) outputTextArea.value =
        bytesToBase64String(hexStringToBytes(outputTextArea.value));
    outputEncode = ENCODING_BASE64;
  });

  descriptionParagraph.appendHtml(TEXT_DESCRIPTION_AFFINE,
      validator: nodeValidator);

  AffineCipher cipher = new AffineCipher(256, key_A: null, key_B: null);
  inputKeyA.onChange.listen((e) {
    if (keyEncode == ENCODING_HEX) cipher.key_A =
        int.parse(inputKeyA.value, radix: 16, onError: (source) => null);
    else if (keyEncode == ENCODING_LATIN1) {
      if (inputKeyA.value.length != 1) {
        toast('Incorrect key 1 size!');
        cipher.key_A = null;
        return;
      } else cipher.key_A = stringToBytes(inputKeyA.value)[0];
    } else if (keyEncode == ENCODING_BASE64) {
      if (inputKeyA.value.length % 4 != 0 ||
          base64StringToBytes(inputKeyA.value).length != 1) {
        toast('Incorrect key 1!');
        cipher.key_A = null;
        return;
      } else cipher.key_A = base64StringToBytes(inputKeyA.value)[0];
    }
  });
  inputKeyB.onChange.listen((e) {
    if (keyEncode == ENCODING_HEX) cipher.key_B =
        int.parse(inputKeyB.value, radix: 16, onError: (source) => null);
    else if (keyEncode == ENCODING_LATIN1) {
      if (inputKeyB.value.length != 1) {
        toast('Incorrect key 2 size!');
        cipher.key_B = null;
        return;
      } else cipher.key_B = stringToBytes(inputKeyB.value)[0];
    } else if (keyEncode == ENCODING_BASE64) {
      if (inputKeyB.value.length % 4 != 0 ||
          base64StringToBytes(inputKeyB.value).length != 1) {
        toast('Incorrect key 2!');
        cipher.key_B = null;
        return;
      } else cipher.key_B = base64StringToBytes(inputKeyB.value)[0];
    }
    String error = cipher.checkKey();
    if (error != '') {
      toast(error);
      return;
    }
  });
  encryptButton.onClick.listen((e) {
    outputTextArea.value = '';
    if (keyEncode == ENCODING_HEX) cipher.key_A =
        int.parse(inputKeyA.value, radix: 16, onError: (source) => null);
    else if (keyEncode == ENCODING_LATIN1) {
      if (inputKeyA.value.length != 1) {
        toast('Incorrect key 1 size!');
        cipher.key_A = null;
        return;
      } else cipher.key_A = stringToBytes(inputKeyA.value)[0];
    } else if (keyEncode == ENCODING_BASE64) {
      if (inputKeyA.value.length % 4 != 0 ||
          base64StringToBytes(inputKeyA.value).length != 1) {
        toast('Incorrect key 1!');
        cipher.key_A = null;
        return;
      } else cipher.key_A = base64StringToBytes(inputKeyA.value)[0];
    }
    if (keyEncode == ENCODING_HEX) cipher.key_B =
        int.parse(inputKeyB.value, radix: 16, onError: (source) => null);
    else if (keyEncode == ENCODING_LATIN1) {
      if (inputKeyB.value.length != 1) {
        toast('Incorrect key 2 size!');
        cipher.key_B = null;
        return;
      } else cipher.key_B = stringToBytes(inputKeyB.value)[0];
    } else if (keyEncode == ENCODING_BASE64) {
      if (inputKeyB.value.length % 4 != 0 ||
          base64StringToBytes(inputKeyB.value).length != 1) {
        toast('Incorrect key 2!');
        cipher.key_B = null;
        return;
      } else cipher.key_B = base64StringToBytes(inputKeyB.value)[0];
    }
    String error = cipher.checkKey();
    if (error != '') {
      toast(error);
      return;
    }
    List list = null;
    if (inputEncode == ENCODING_HEX) list =
        cipher.encrypt(hexStringToBytes(inputTextArea.value));
    else if (inputEncode == ENCODING_LATIN1) list =
        cipher.encrypt(stringToBytes(inputTextArea.value));
    else if (inputEncode == ENCODING_BASE64) {
      if (inputTextArea.value.length % 4 != 0) list = null;
      else list = cipher.encrypt(base64StringToBytes(inputTextArea.value));
    }
    if (list == null) toast('Incorrect message!');
    if (outputEncode == ENCODING_HEX) outputTextArea.value =
        bytesToHexString(list);
    else if (outputEncode == ENCODING_LATIN1) outputTextArea.value =
        bytesToString(list);
    else if (outputEncode == ENCODING_BASE64) outputTextArea.value =
        bytesToBase64String(list);
    if (keyEncode == ENCODING_HEX) {
      inputKeyA.value = bytesToHexString([cipher.key_A]);
      inputKeyB.value = bytesToHexString([cipher.key_B]);
    } else if (keyEncode == ENCODING_LATIN1) {
      inputKeyB.value = bytesToString([cipher.key_B]);
      inputKeyA.value = bytesToString([cipher.key_A]);
    } else if (keyEncode == ENCODING_BASE64) {
      inputKeyA.value = bytesToBase64String([cipher.key_A]);
      inputKeyB.value = bytesToBase64String([cipher.key_B]);
    }
  });
  decryptButton.onClick.listen((e) {
    inputTextArea.value = '';
    if (keyEncode == ENCODING_HEX) cipher.key_A =
        int.parse(inputKeyA.value, radix: 16, onError: (source) => null);
    else if (keyEncode == ENCODING_LATIN1) {
      if (inputKeyA.value.length != 1) {
        toast('Incorrect key 1 size!');
        cipher.key_A = null;
        return;
      } else cipher.key_A = stringToBytes(inputKeyA.value)[0];
    } else if (keyEncode == ENCODING_BASE64) {
      if (inputKeyA.value.length % 4 != 0 ||
          base64StringToBytes(inputKeyA.value).length != 1) {
        toast('Incorrect key 1!');
        cipher.key_A = null;
        return;
      } else cipher.key_A = base64StringToBytes(inputKeyA.value)[0];
    }
    if (keyEncode == ENCODING_HEX) cipher.key_B =
        int.parse(inputKeyB.value, radix: 16, onError: (source) => null);
    else if (keyEncode == ENCODING_LATIN1) {
      if (inputKeyB.value.length != 1) {
        toast('Incorrect key size!');
        cipher.key_B = null;
        return;
      } else cipher.key_B = stringToBytes(inputKeyB.value)[0];
    } else if (keyEncode == ENCODING_BASE64) {
      if (inputKeyB.value.length % 4 != 0 ||
          base64StringToBytes(inputKeyB.value).length != 1) {
        toast('Incorrect key!');
        cipher.key_B = null;
        return;
      } else cipher.key_B = base64StringToBytes(inputKeyB.value)[0];
    }
    String error = cipher.checkKey();
    if (error != '') {
      toast(error);
      return;
    }
    List list = null;
    if (outputEncode == ENCODING_HEX) list =
        cipher.decrypt(hexStringToBytes(outputTextArea.value));
    else if (outputEncode == ENCODING_LATIN1) list =
        cipher.decrypt(stringToBytes(outputTextArea.value));
    else if (outputEncode == ENCODING_BASE64) {
      if (outputTextArea.value.length % 4 != 0) list = null;
      else list = cipher.decrypt(base64StringToBytes(outputTextArea.value));
    }
    if (list == null) toast('Incorrect message!');
    if (inputEncode == ENCODING_HEX) inputTextArea.value =
        bytesToHexString(list);
    else if (inputEncode == ENCODING_LATIN1) inputTextArea.value =
        bytesToString(list);
    else if (inputEncode == ENCODING_BASE64) inputTextArea.value =
        bytesToBase64String(list);
    if (keyEncode == ENCODING_HEX) {
      inputKeyA.value = bytesToHexString([cipher.key_A]);
      inputKeyB.value = bytesToHexString([cipher.key_B]);
    } else if (keyEncode == ENCODING_LATIN1) {
      inputKeyB.value = bytesToString([cipher.key_B]);
      inputKeyA.value = bytesToString([cipher.key_A]);
    } else if (keyEncode == ENCODING_BASE64) {
      inputKeyA.value = bytesToBase64String([cipher.key_A]);
      inputKeyB.value = bytesToBase64String([cipher.key_B]);
    }
  });

  scrollTo(
      encryptButton, getDuration(encryptButton, 2), TimingFunctions.easeInOut);
}

void buildStandardCiphers(int type) {
  SpanElement wrapper = querySelector('#dynamic');
  wrapper.setInnerHtml('');
  int inputEncode = ENCODING_LATIN1;
  int keyEncode = ENCODING_LATIN1;
  int outputEncode = ENCODING_HEX;

  wrapper.setInnerHtml(HTML_CODE_STANDARD_CIPHERS, validator: nodeValidator);

  TextAreaElement inputTextArea = querySelector("#inputTextArea");
  TextAreaElement keyTextArea = querySelector("#keyTextArea");
  TextAreaElement outputTextArea = querySelector("#outputTextArea");
  DivElement encryptButton = querySelector("#encryptButton");
  DivElement decryptButton = querySelector("#decryptButton");
  ParagraphElement descriptionParagraph = querySelector('#description');

  querySelector("#plaintextInput").onClick.listen((e) {
    if (inputEncode == ENCODING_HEX) inputTextArea.value =
        hexStringToString(inputTextArea.value);
    if (inputEncode == ENCODING_BASE64) inputTextArea.value =
        bytesToString(base64StringToBytes(inputTextArea.value));
    inputEncode = ENCODING_LATIN1;
  });
  querySelector("#hextextInput").onClick.listen((e) {
    if (inputEncode == ENCODING_LATIN1) inputTextArea.value =
        stringToHexString(inputTextArea.value);
    if (inputEncode == ENCODING_BASE64) inputTextArea.value =
        bytesToHexString(base64StringToBytes(inputTextArea.value));
    inputEncode = ENCODING_HEX;
  });
  querySelector("#base64Input").onClick.listen((e) {
    if (inputEncode == ENCODING_LATIN1) inputTextArea.value =
        bytesToBase64String(stringToBytes(inputTextArea.value));
    if (inputEncode == ENCODING_HEX) inputTextArea.value =
        bytesToBase64String(hexStringToBytes(inputTextArea.value));
    inputEncode = ENCODING_BASE64;
  });
  querySelector("#plaintextKey").onClick.listen((e) {
    if (keyEncode == ENCODING_HEX) keyTextArea.value =
        hexStringToString(keyTextArea.value);
    if (keyEncode == ENCODING_BASE64) keyTextArea.value =
        bytesToString(base64StringToBytes(keyTextArea.value));
    keyEncode = ENCODING_LATIN1;
  });
  querySelector("#hextextKey").onClick.listen((e) {
    if (keyEncode == ENCODING_LATIN1) keyTextArea.value =
        stringToHexString(keyTextArea.value);
    if (keyEncode == ENCODING_BASE64) keyTextArea.value =
        bytesToHexString(base64StringToBytes(keyTextArea.value));
    keyEncode = ENCODING_HEX;
  });
  querySelector("#base64Key").onClick.listen((e) {
    if (keyEncode == ENCODING_LATIN1) keyTextArea.value =
        bytesToBase64String(stringToBytes(keyTextArea.value));

    if (keyEncode == ENCODING_HEX) keyTextArea.value =
        bytesToBase64String(hexStringToBytes(keyTextArea.value));
    keyEncode = ENCODING_BASE64;
  });
  querySelector("#plaintextOutput").onClick.listen((e) {
    if (outputEncode == ENCODING_HEX) outputTextArea.value =
        hexStringToString(outputTextArea.value);
    if (outputEncode == ENCODING_BASE64) outputTextArea.value =
        bytesToString(base64StringToBytes(outputTextArea.value));
    outputEncode = ENCODING_LATIN1;
  });
  querySelector("#hextextOutput").onClick.listen((e) {
    if (outputEncode == ENCODING_LATIN1) outputTextArea.value =
        stringToHexString(outputTextArea.value);
    if (outputEncode == ENCODING_BASE64) outputTextArea.value =
        bytesToHexString(base64StringToBytes(outputTextArea.value));
    outputEncode = ENCODING_HEX;
  });
  querySelector("#base64Output").onClick.listen((e) {
    if (outputEncode == ENCODING_LATIN1) outputTextArea.value =
        bytesToBase64String(stringToBytes(outputTextArea.value));
    if (outputEncode == ENCODING_HEX) outputTextArea.value =
        bytesToBase64String(hexStringToBytes(outputTextArea.value));
    outputEncode = ENCODING_BASE64;
  });

  var cipher = null;
  switch (type) {
    case CIPHER_VIGENERE:
      descriptionParagraph.appendHtml(TEXT_DESCRIPTION_VIGENERE,
          validator: nodeValidator);
      cipher = new VigenereCipher(256);
      break;
    case CIPHER_BEAUFORT:
      descriptionParagraph.appendHtml(TEXT_DESCRIPTION_BEAUFORT,
          validator: nodeValidator);
      cipher = new BeaufortCipher(256);
      break;
    case CIPHER_OTP:
      descriptionParagraph.appendHtml(TEXT_DESCRIPTION_OTP,
          validator: nodeValidator);
      cipher = new OTPCipher(256);
      break;
  }

  keyTextArea.onChange.listen((e) {
    if (keyEncode == ENCODING_HEX) cipher.key =
        hexStringToBytes(keyTextArea.value);
    else if (keyEncode == ENCODING_LATIN1) {
      cipher.key = stringToBytes(keyTextArea.value);
    } else if (keyEncode == ENCODING_BASE64) {
      if (keyTextArea.value.length % 4 != 0) {
        toast('Incorrect key!');
        cipher.key = null;
        return;
      } else cipher.key = base64StringToBytes(keyTextArea.value);
    }
    String error = cipher.checkKey();
    if (error != '') {
      toast(error);
      return;
    }
  });
  encryptButton.onClick.listen((e) {
    outputTextArea.value = '';
    if (keyEncode == ENCODING_HEX) cipher.key =
        hexStringToBytes(keyTextArea.value);
    else if (keyEncode == ENCODING_LATIN1) {
      cipher.key = stringToBytes(keyTextArea.value);
    } else if (keyEncode == ENCODING_BASE64) {
      if (keyTextArea.value.length % 4 != 0) {
        toast('Incorrect key!');
        cipher.key = null;
        return;
      } else cipher.key = base64StringToBytes(keyTextArea.value);
    }
    String error = cipher.checkKey();
    if (error != '') {
      toast(error);
      return;
    }
    List list = null;
    if (inputEncode == ENCODING_HEX) list =
        cipher.encrypt(hexStringToBytes(inputTextArea.value));
    else if (inputEncode == ENCODING_LATIN1) list =
        cipher.encrypt(stringToBytes(inputTextArea.value));
    else if (inputEncode == ENCODING_BASE64) {
      if (inputTextArea.value.length % 4 != 0) list = null;
      else list = cipher.encrypt(base64StringToBytes(inputTextArea.value));
    }
    if (list == null) toast('Incorrect message!');
    if (outputEncode == ENCODING_HEX) outputTextArea.value =
        bytesToHexString(list);
    else if (outputEncode == ENCODING_LATIN1) outputTextArea.value =
        bytesToString(list);
    else if (outputEncode == ENCODING_BASE64) outputTextArea.value =
        bytesToBase64String(list);
    if (keyEncode == ENCODING_HEX) keyTextArea.value =
        bytesToHexString(cipher.key);
    else if (keyEncode == ENCODING_LATIN1) keyTextArea.value =
        bytesToString(cipher.key);
    else if (keyEncode == ENCODING_BASE64) keyTextArea.value =
        bytesToBase64String(cipher.key);
  });
  decryptButton.onClick.listen((e) {
    inputTextArea.value = '';
    if (keyEncode == ENCODING_HEX) cipher.key =
        hexStringToBytes(keyTextArea.value);
    else if (keyEncode == ENCODING_LATIN1) {
      cipher.key = stringToBytes(keyTextArea.value);
    } else if (keyEncode == ENCODING_BASE64) {
      if (keyTextArea.value.length % 4 != 0) {
        toast('Incorrect key!');
        cipher.key = null;
        return;
      } else cipher.key = base64StringToBytes(keyTextArea.value);
    }
    String error = cipher.checkKey();
    if (error != '') {
      toast(error);
      return;
    }
    List list = null;
    if (outputEncode == ENCODING_HEX) list =
        cipher.decrypt(hexStringToBytes(outputTextArea.value));
    else if (outputEncode == ENCODING_LATIN1) list =
        cipher.decrypt(stringToBytes(outputTextArea.value));
    else if (outputEncode == ENCODING_BASE64) {
      if (outputTextArea.value.length % 4 != 0) list = null;
      else list = cipher.decrypt(base64StringToBytes(outputTextArea.value));
    }
    if (list == null) toast('Incorrect message!');
    if (inputEncode == ENCODING_HEX) inputTextArea.value =
        bytesToHexString(list);
    else if (inputEncode == ENCODING_LATIN1) inputTextArea.value =
        bytesToString(list);
    else if (inputEncode == ENCODING_BASE64) inputTextArea.value =
        bytesToBase64String(list);
    if (keyEncode == ENCODING_HEX) keyTextArea.value =
        bytesToHexString(cipher.key);
    else if (keyEncode == ENCODING_LATIN1) keyTextArea.value =
        bytesToString(cipher.key);
    else if (keyEncode == ENCODING_BASE64) keyTextArea.value =
        bytesToBase64String(cipher.key);
  });

  scrollTo(
      encryptButton, getDuration(encryptButton, 2), TimingFunctions.easeInOut);
}

void buildBlockCiphers(int type) {
  SpanElement wrapper = querySelector('#dynamic');
  wrapper.setInnerHtml('');
  int inputEncode = ENCODING_LATIN1;
  int keyEncode = ENCODING_LATIN1;
  int outputEncode = ENCODING_HEX;

  int mode = BLOCK_MODE_ECB;

  wrapper.setInnerHtml(HTML_CODE_BLOCK_CIPHERS, validator: nodeValidator);

  TextAreaElement inputTextArea = querySelector("#inputTextArea");
  TextAreaElement keyTextArea = querySelector("#keyTextArea");
  TextAreaElement outputTextArea = querySelector("#outputTextArea");
  TextAreaElement initVectorTextArea = querySelector("#initvectTextArea");
  DivElement encryptButton = querySelector("#encryptButton");
  DivElement decryptButton = querySelector("#decryptButton");
  ParagraphElement descriptionParagraph = querySelector('#description');

  querySelector("#plaintextInput").onClick.listen((e) {
    if (inputEncode == ENCODING_HEX) {
      inputTextArea.value = hexStringToString(inputTextArea.value);
    }
    if (inputEncode == ENCODING_BASE64) {
      inputTextArea.value =
          bytesToString(base64StringToBytes(inputTextArea.value));
    }
    inputEncode = ENCODING_LATIN1;
  });
  querySelector("#hextextInput").onClick.listen((e) {
    if (inputEncode == ENCODING_LATIN1) {
      inputTextArea.value = stringToHexString(inputTextArea.value);
    }
    if (inputEncode == ENCODING_BASE64) {
      inputTextArea.value =
          bytesToHexString(base64StringToBytes(inputTextArea.value));
    }
    inputEncode = ENCODING_HEX;
  });
  querySelector("#base64Input").onClick.listen((e) {
    if (inputEncode == ENCODING_LATIN1) {
      inputTextArea.value =
          bytesToBase64String(stringToBytes(inputTextArea.value));
    }
    if (inputEncode == ENCODING_HEX) {
      inputTextArea.value =
          bytesToBase64String(hexStringToBytes(inputTextArea.value));
    }
    inputEncode = ENCODING_BASE64;
  });
  querySelector("#plaintextKey").onClick.listen((e) {
    if (keyEncode == ENCODING_HEX) {
      keyTextArea.value = hexStringToString(keyTextArea.value);
      initVectorTextArea.value = hexStringToString(initVectorTextArea.value);
    }
    if (keyEncode == ENCODING_BASE64) {
      keyTextArea.value = bytesToString(base64StringToBytes(keyTextArea.value));
      initVectorTextArea.value =
          bytesToString(base64StringToBytes(initVectorTextArea.value));
    }
    keyEncode = ENCODING_LATIN1;
  });
  querySelector("#hextextKey").onClick.listen((e) {
    if (keyEncode == ENCODING_LATIN1) {
      keyTextArea.value = stringToHexString(keyTextArea.value);
      initVectorTextArea.value = stringToHexString(initVectorTextArea.value);
    }
    if (keyEncode == ENCODING_BASE64) {
      keyTextArea.value =
          bytesToHexString(base64StringToBytes(keyTextArea.value));
      initVectorTextArea.value =
          bytesToHexString(base64StringToBytes(initVectorTextArea.value));
    }
    keyEncode = ENCODING_HEX;
  });
  querySelector("#base64Key").onClick.listen((e) {
    if (keyEncode == ENCODING_LATIN1) {
      keyTextArea.value = bytesToBase64String(stringToBytes(keyTextArea.value));
      initVectorTextArea.value =
          bytesToBase64String(stringToBytes(initVectorTextArea.value));
    }
    if (keyEncode == ENCODING_HEX) {
      keyTextArea.value =
          bytesToBase64String(hexStringToBytes(keyTextArea.value));
      initVectorTextArea.value =
          bytesToBase64String(hexStringToBytes(initVectorTextArea.value));
    }
    keyEncode = ENCODING_BASE64;
  });
  querySelector("#plaintextOutput").onClick.listen((e) {
    if (outputEncode == ENCODING_HEX) {
      outputTextArea.value = hexStringToString(outputTextArea.value);
    }
    if (outputEncode == ENCODING_BASE64) {
      outputTextArea.value =
          bytesToString(base64StringToBytes(outputTextArea.value));
    }
    outputEncode = ENCODING_LATIN1;
  });
  querySelector("#hextextOutput").onClick.listen((e) {
    if (outputEncode == ENCODING_LATIN1) {
      outputTextArea.value = stringToHexString(outputTextArea.value);
    }
    if (outputEncode == ENCODING_BASE64) {
      outputTextArea.value =
          bytesToHexString(base64StringToBytes(outputTextArea.value));
    }
    outputEncode = ENCODING_HEX;
  });
  querySelector("#base64Output").onClick.listen((e) {
    if (outputEncode == ENCODING_LATIN1) {
      outputTextArea.value =
          bytesToBase64String(stringToBytes(outputTextArea.value));
    }
    if (outputEncode == ENCODING_HEX) {
      outputTextArea.value =
          bytesToBase64String(hexStringToBytes(outputTextArea.value));
    }
    outputEncode = ENCODING_BASE64;
  });

  String height = keyTextArea.style.height;
  querySelector("#ecbMode").onClick.listen((e) {
    mode = BLOCK_MODE_ECB;
    initVectorTextArea.style.display = 'none';
    keyTextArea.style.height = height;
  });
  querySelector("#cbcMode").onClick.listen((e) {
    mode = BLOCK_MODE_CBC;
    initVectorTextArea.style.display = 'block';
    keyTextArea.style.height = '140px';
  });
  querySelector("#pcbcMode").onClick.listen((e) {
    mode = BLOCK_MODE_PCBC;
    initVectorTextArea.style.display = 'block';
    keyTextArea.style.height = '140px';
  });
  querySelector("#cfbMode").onClick.listen((e) {
    mode = BLOCK_MODE_CFB;
    initVectorTextArea.style.display = 'block';
    keyTextArea.style.height = '140px';
  });
  querySelector("#ofbMode").onClick.listen((e) {
    mode = BLOCK_MODE_OFB;
    initVectorTextArea.style.display = 'none';
    keyTextArea.style.height = height;
  });
  querySelector("#ctrMode").onClick.listen((e) {
    mode = BLOCK_MODE_CTR;
    initVectorTextArea.style.display = 'none';
    keyTextArea.style.height = height;
  });

  var cipher = null;
  switch (type) {
    case CIPHER_HILL:
      descriptionParagraph.appendHtml(TEXT_DESCRIPTION_HILL,
          validator: nodeValidator);
      cipher = new HillCipher(256);
      break;
  }

  keyTextArea.onChange.listen((e) {
    if (keyEncode == ENCODING_HEX) cipher.key =
        hexStringToBytes(keyTextArea.value);
    else if (keyEncode == ENCODING_LATIN1) {
      cipher.key = stringToBytes(keyTextArea.value);
    } else if (keyEncode == ENCODING_BASE64) {
      if (keyTextArea.value.length % 4 != 0) {
        toast('Incorrect key!');
        cipher.key = null;
        return;
      } else cipher.key = base64StringToBytes(keyTextArea.value);
    }
    String error = cipher.checkKey();
    if (error != '') {
      toast(error);
      return;
    }
  });
  encryptButton.onClick.listen((e) {
    outputTextArea.value = '';
    List initvector = null;
    if (keyEncode == ENCODING_HEX) {
      cipher.key = hexStringToBytes(keyTextArea.value);
      initvector = hexStringToBytes(initVectorTextArea.value);
    } else if (keyEncode == ENCODING_LATIN1) {
      cipher.key = stringToBytes(keyTextArea.value);
      initvector = stringToBytes(initVectorTextArea.value);
    } else if (keyEncode == ENCODING_BASE64) {
      initvector = base64StringToBytes(initVectorTextArea.value);
      if (keyTextArea.value.length % 4 != 0) {
        toast('Incorrect key!');
        cipher.key = null;
        return;
      } else cipher.key = base64StringToBytes(keyTextArea.value);
    }
    String error = cipher.checkKey();
    if (error != '') {
      toast(error);
      return;
    }
    List list = null;
    if (inputEncode == ENCODING_HEX) list = cipher.encrypt(
        hexStringToBytes(inputTextArea.value),
        mode: mode,
        initVec: initvector);
    else if (inputEncode == ENCODING_LATIN1) list = cipher.encrypt(
        stringToBytes(inputTextArea.value),
        mode: mode,
        initVec: initvector);
    else if (inputEncode == ENCODING_BASE64) {
      if (inputTextArea.value.length % 4 != 0) {
        list = null;
        toast('Incorrect message!');
        return;
      } else list = cipher.encrypt(base64StringToBytes(inputTextArea.value),
          mode: mode, initVec: initvector);
    }
    if (list == null) {
      toast('Incorrect message or IV!');
      return;
    }
    if (outputEncode == ENCODING_HEX) outputTextArea.value =
        bytesToHexString(list);
    else if (outputEncode == ENCODING_LATIN1) outputTextArea.value =
        bytesToString(list);
    else if (outputEncode == ENCODING_BASE64) outputTextArea.value =
        bytesToBase64String(list);
    if (keyEncode == ENCODING_HEX) keyTextArea.value =
        bytesToHexString(cipher.key);
    else if (keyEncode == ENCODING_LATIN1) keyTextArea.value =
        bytesToString(cipher.key);
    else if (keyEncode == ENCODING_BASE64) keyTextArea.value =
        bytesToBase64String(cipher.key);
  });
  decryptButton.onClick.listen((e) {
    inputTextArea.value = '';
    List initvector = null;
    if (keyEncode == ENCODING_HEX) {
      cipher.key = hexStringToBytes(keyTextArea.value);
      initvector = hexStringToBytes(initVectorTextArea.value);
    } else if (keyEncode == ENCODING_LATIN1) {
      cipher.key = stringToBytes(keyTextArea.value);
      initvector = stringToBytes(initVectorTextArea.value);
    } else if (keyEncode == ENCODING_BASE64) {
      initvector = base64StringToBytes(initVectorTextArea.value);
      if (keyTextArea.value.length % 4 != 0) {
        toast('Incorrect key!');
        cipher.key = null;
        return;
      } else cipher.key = base64StringToBytes(keyTextArea.value);
    }
    String error = cipher.checkKey();
    if (error != '') {
      toast(error);
      return;
    }
    List list = null;
    if (outputEncode == ENCODING_HEX) list = cipher.decrypt(
        hexStringToBytes(outputTextArea.value),
        mode: mode,
        initVec: initvector);
    else if (outputEncode == ENCODING_LATIN1) list = cipher.decrypt(
        stringToBytes(outputTextArea.value),
        mode: mode,
        initVec: initvector);
    else if (outputEncode == ENCODING_BASE64) {
      if (outputTextArea.value.length % 4 != 0) {
        list = null;
        toast('Incorrect message!');
        return;
      } else list = cipher.decrypt(base64StringToBytes(outputTextArea.value),
          mode: mode, initVec: initvector);
    }
    if (list == null) {
      toast('Incorrect message or IV!');
      return;
    }
    if (inputEncode == ENCODING_HEX) inputTextArea.value =
        bytesToHexString(list);
    else if (inputEncode == ENCODING_LATIN1) inputTextArea.value =
        bytesToString(list);
    else if (inputEncode == ENCODING_BASE64) inputTextArea.value =
        bytesToBase64String(list);
    if (keyEncode == ENCODING_HEX) keyTextArea.value =
        bytesToHexString(cipher.key);
    else if (keyEncode == ENCODING_LATIN1) keyTextArea.value =
        bytesToString(cipher.key);
    else if (keyEncode == ENCODING_BASE64) keyTextArea.value =
        bytesToBase64String(cipher.key);
  });

  scrollTo(
      encryptButton, getDuration(encryptButton, 2), TimingFunctions.easeInOut);
}

void buildEncoding() {
  SpanElement wrapper = querySelector('#dynamic');
  wrapper.setInnerHtml('');
  int inputEncode = ENCODING_LATIN1;

  wrapper.setInnerHtml(HTML_CODE_ENCODINGS, validator: nodeValidator);

  TextAreaElement inputTextArea = querySelector("#inputTextArea");
  ParagraphElement descriptionParagraph = querySelector('#description');

  querySelector("#latin1Input").onClick.listen((e) {
    if (inputEncode == ENCODING_HEX) inputTextArea.value =
        LATIN1.decode(hexStringToBytes(inputTextArea.value));
    if (inputEncode == ENCODING_BASE64) inputTextArea.value =
        LATIN1.decode(base64StringToBytes(inputTextArea.value));
    if (inputEncode == ENCODING_UTF8) inputTextArea.value =
        LATIN1.decode(UTF8.encode(inputTextArea.value));
    if (inputEncode == ENCODING_ASCII) inputTextArea.value =
        LATIN1.decode(ASCII.encode(inputTextArea.value));
    inputEncode = ENCODING_LATIN1;
  });
  querySelector("#hextextInput").onClick.listen((e) {
    if (inputEncode == ENCODING_LATIN1) inputTextArea.value =
        bytesToHexString(LATIN1.encode(inputTextArea.value));
    if (inputEncode == ENCODING_BASE64) inputTextArea.value =
        bytesToHexString(base64StringToBytes(inputTextArea.value));
    if (inputEncode == ENCODING_UTF8) inputTextArea.value =
        bytesToHexString(UTF8.encode(inputTextArea.value));
    if (inputEncode == ENCODING_ASCII) inputTextArea.value =
        bytesToHexString(ASCII.encode(inputTextArea.value));
    inputEncode = ENCODING_HEX;
  });
  querySelector("#base64Input").onClick.listen((e) {
    if (inputEncode == ENCODING_LATIN1) inputTextArea.value =
        bytesToBase64String(LATIN1.encode(inputTextArea.value));
    if (inputEncode == ENCODING_HEX) inputTextArea.value =
        bytesToBase64String(hexStringToBytes(inputTextArea.value));
    if (inputEncode == ENCODING_UTF8) inputTextArea.value =
        bytesToBase64String(UTF8.encode(inputTextArea.value));
    if (inputEncode == ENCODING_ASCII) inputTextArea.value =
        bytesToBase64String(ASCII.encode(inputTextArea.value));
    inputEncode = ENCODING_BASE64;
  });
  querySelector("#utf8Input").onClick.listen((e) {
    if (inputEncode == ENCODING_LATIN1) inputTextArea.value =
        UTF8.decode(LATIN1.encode(inputTextArea.value));
    if (inputEncode == ENCODING_HEX) inputTextArea.value =
        UTF8.decode(hexStringToBytes(inputTextArea.value));
    if (inputEncode == ENCODING_BASE64) inputTextArea.value =
        UTF8.decode(base64StringToBytes(inputTextArea.value));
    if (inputEncode == ENCODING_ASCII) inputTextArea.value =
        UTF8.decode(ASCII.encode(inputTextArea.value));
    inputEncode = ENCODING_UTF8;
  });
  querySelector("#asciiInput").onClick.listen((e) {
    if (inputEncode == ENCODING_LATIN1) inputTextArea.value =
        ASCII.decode(LATIN1.encode(inputTextArea.value));
    if (inputEncode == ENCODING_HEX) inputTextArea.value =
        ASCII.decode(hexStringToBytes(inputTextArea.value));
    if (inputEncode == ENCODING_UTF8) inputTextArea.value =
        ASCII.decode(UTF8.encode(inputTextArea.value));
    if (inputEncode == ENCODING_BASE64) inputTextArea.value =
        ASCII.decode(base64StringToBytes(inputTextArea.value));
    inputEncode = ENCODING_ASCII;
  });

  descriptionParagraph.appendHtml(TEXT_DESCRIPTION_ENCODINGS,
      validator: nodeValidator);

  scrollTo(
      inputTextArea, getDuration(inputTextArea, 2), TimingFunctions.easeInOut);
}

void buildRSA() {
  SpanElement wrapper = querySelector('#dynamic');
  wrapper.setInnerHtml('');
  int inputEncode = ENCODING_LATIN1;
  int keyEncode = ENCODING_LATIN1;
  int outputEncode = ENCODING_HEX;

  wrapper.setInnerHtml(HTML_CODE_RSA, validator: nodeValidator);
/*
  TextAreaElement inputTextArea = querySelector("#inputTextArea");
  TextAreaElement keyTextArea = querySelector("#keyTextArea");
  TextAreaElement outputTextArea = querySelector("#outputTextArea");
  TextAreaElement initVectorTextArea = querySelector("#initvectTextArea");
  DivElement encryptButton = querySelector("#encryptButton");
  DivElement decryptButton = querySelector("#decryptButton");
  ParagraphElement descriptionParagraph = querySelector('#description');*/

  /*descriptionParagraph.appendHtml(TEXT_DESCRIPTION_RSA,
  validator: nodeValidator);*/

  /*scrollTo(
      inputTextArea, getDuration(inputTextArea, 2), TimingFunctions.easeInOut);*/
}

class MyUriPolicy implements UriPolicy {
  bool allowsUri(uri) => true;
}
