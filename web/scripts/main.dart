import 'dart:convert';
import 'dart:html';

import 'package:dartcrypto/dartcrypto.dart';
import 'package:crypto/crypto.dart' as crypto;

import 'scrolling.dart';
import 'toast.dart';
import 'utils.dart';

NodeValidator nodeValidator = new NodeValidatorBuilder()
  ..allowTextElements()
  ..allowHtml5()
  ..allowElement('a', attributes: ['href', 'target'])
  ..allowElement('div', attributes: ['fit', 'display', 'style'])
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

  SpanElement wrapper = querySelector('#dynamic');
  wrapper.setInnerHtml('');

  switch (type) {
    case CIPHER_CAESAR:
    case CIPHER_AFFINE:
      buildAffine(type);
      break;
    case CIPHER_HILL:
      buildBlockCiphers(type);
      break;
    case CIPHER_BEAUFORT:
    case CIPHER_VIGENERE:
    case CIPHER_OTP:
    case CIPHER_RC4:
    case CIPHER_RC4A:
    case CIPHER_RC4PLUS:
    case CIPHER_SPRITZ:
    case CIPHER_VMPC:
      buildStandardCiphers(type);
      break;
    /*case CIPHER_RSA:
      wrapper?.setInnerHtml(HTML_CODE_RSA, validator: nodeValidator);
      descriptionParagraph?.appendHtml(TEXT_DESCRIPTION_RSA,
          validator: nodeValidator);
      //buildRSA();
      break;
    case CIPHER_RSA_GENERATOR:
      break;*/
    case ENCODINGS:
      buildEncoding();
      break;
    case HASH_SHA_1:
    case HASH_SHA_256:
    case HASH_MD5:
      buildStandardHash(type);
      break;
  }
}

void buildAffine(int type) {
  List inputEncode = [ENCODING_LATIN1];
  List keyEncode = [ENCODING_LATIN1];
  List outputEncode = [ENCODING_HEX];
  SpanElement wrapper = querySelector('#dynamic');
  wrapper?.setInnerHtml(HTML_CODE_AFFINE, validator: nodeValidator);

  TextAreaElement inputTextArea = querySelector("#inputTextArea");
  TextAreaElement keyTextAreaA = querySelector("#keyTextAreaA");
  TextAreaElement keyTextAreaB = querySelector("#keyTextAreaB");
  TextAreaElement outputTextArea = querySelector("#outputTextArea");
  DivElement encryptButton = querySelector("#encryptButton");
  DivElement keyGenerateButton = querySelector("#keyGenerateButton");
  DivElement decryptButton = querySelector("#decryptButton");
  ParagraphElement descriptionParagraph = querySelector('#description');

  encodings(inputTextArea, inputEncode, type: "Input");
  encodings(keyTextAreaA, keyEncode, type: "Key", changeValue: false);
  encodings(keyTextAreaB, keyEncode, type: "Key");
  encodings(outputTextArea, outputEncode, type: "Output");

  if (type == CIPHER_CAESAR) {
    descriptionParagraph?.appendHtml(TEXT_DESCRIPTION_CAESAR,
        validator: nodeValidator);
    keyTextAreaA.value = bytesToString([0x01]);
    keyTextAreaA.style.display = 'none';
    querySelector('#BRelement').style.display = 'none';
  } else if (type == CIPHER_AFFINE) {
    descriptionParagraph?.appendHtml(TEXT_DESCRIPTION_AFFINE,
        validator: nodeValidator);
  }

  AffineCipher cipher = new AffineCipher(256, key_A: null, key_B: null);

  void checkKey(String key, {int keyNumber: 0}) {
    List tempKey = null;
    try {
      if (key == null) throw new Exception("Key $keyNumber is empty!");
      if (keyEncode[0] == ENCODING_HEX) tempKey = hexStringToBytes(key);
      else if (keyEncode[0] == ENCODING_LATIN1) tempKey = stringToBytes(key);
      else if (keyEncode[0] == ENCODING_BASE64) tempKey =
          base64StringToBytes(key);
      if (tempKey == null || tempKey.length != 1) throw new Exception(
          "Incorrect encoding key $keyNumber!");
      if (keyNumber == 1) cipher.key_A = tempKey[0];
      else if (keyNumber == 2) cipher.key_B = tempKey[0];
    } catch (e) {
      toast(e.toString().replaceAll(new RegExp('Exception: '), ''));
      throw new Exception(e);
    }
  }

  keyGenerateButton.onClick.listen((e) {
    keyTextAreaA.value = '';
    keyTextAreaB.value = '';
    try {
      cipher.generateKey();
      if (type == CIPHER_CAESAR) cipher.key_A = 0x01;
      if (keyEncode[0] == ENCODING_HEX) {
        keyTextAreaA.value = bytesToHexString([cipher.key_A]);
        keyTextAreaB.value = bytesToHexString([cipher.key_B]);
      } else if (keyEncode[0] == ENCODING_LATIN1) {
        keyTextAreaA.value = bytesToString([cipher.key_A]);
        keyTextAreaB.value = bytesToString([cipher.key_B]);
      } else if (keyEncode[0] == ENCODING_BASE64) {
        keyTextAreaA.value = bytesToBase64String([cipher.key_A]);
        keyTextAreaB.value = bytesToBase64String([cipher.key_B]);
      }
    } catch (e) {
      toast(e.toString().replaceAll(new RegExp('Exception: '), ''));
      throw new Exception(e);
    }
  });

  keyTextAreaA.onChange
      .listen((e) => checkKey(keyTextAreaA.value, keyNumber: 1));
  keyTextAreaB.onChange
      .listen((e) => checkKey(keyTextAreaB.value, keyNumber: 2));
  encryptButton.onClick.listen((e) {
    outputTextArea.value = '';
    try {
      checkKey(keyTextAreaA.value, keyNumber: 1);
      checkKey(keyTextAreaB.value, keyNumber: 2);
      List list = null;
      if (inputEncode[0] == ENCODING_HEX) list =
          cipher.encrypt(hexStringToBytes(inputTextArea.value));
      else if (inputEncode[0] == ENCODING_LATIN1) list =
          cipher.encrypt(stringToBytes(inputTextArea.value));
      else if (inputEncode[0] == ENCODING_BASE64) list =
          cipher.encrypt(base64StringToBytes(inputTextArea.value));
      if (list == null) throw new Exception('Incorrect message encoding!');
      if (outputEncode[0] == ENCODING_HEX) outputTextArea.value =
          bytesToHexString(list);
      else if (outputEncode[0] == ENCODING_LATIN1) outputTextArea.value =
          bytesToString(list);
      else if (outputEncode[0] == ENCODING_BASE64) outputTextArea.value =
          bytesToBase64String(list);
    } catch (e) {
      toast(e.toString().replaceAll(new RegExp('Exception: '), ''));
      throw new Exception(e);
    }
  });
  decryptButton.onClick.listen((e) {
    inputTextArea.value = '';
    try {
      checkKey(keyTextAreaA.value, keyNumber: 1);
      checkKey(keyTextAreaB.value, keyNumber: 2);
      List list = null;
      if (outputEncode[0] == ENCODING_HEX) list =
          cipher.decrypt(hexStringToBytes(outputTextArea.value));
      else if (outputEncode[0] == ENCODING_LATIN1) list =
          cipher.decrypt(stringToBytes(outputTextArea.value));
      else if (outputEncode[0] == ENCODING_BASE64) list =
          cipher.decrypt(base64StringToBytes(outputTextArea.value));
      if (list == null) throw new Exception('Incorrect message encoding!');
      if (inputEncode[0] == ENCODING_HEX) inputTextArea.value =
          bytesToHexString(list);
      else if (inputEncode[0] == ENCODING_LATIN1) inputTextArea.value =
          bytesToString(list);
      else if (inputEncode[0] == ENCODING_BASE64) inputTextArea.value =
          bytesToBase64String(list);
    } catch (e) {
      toast(e.toString().replaceAll(new RegExp('Exception: '), ''));
      throw new Exception(e);
    }
  });

  scrollTo(
      encryptButton, getDuration(encryptButton, 2), TimingFunctions.easeInOut);
}

void buildBlockCiphers(int type) {
  List inputEncode = [ENCODING_LATIN1];
  List keyEncode = [ENCODING_LATIN1];
  List outputEncode = [ENCODING_HEX];
  SpanElement wrapper = querySelector('#dynamic');
  wrapper.setInnerHtml(HTML_CODE_BLOCK_CIPHERS, validator: nodeValidator);

  int mode = BLOCK_MODE_ECB;

  TextAreaElement inputTextArea = querySelector("#inputTextArea");
  TextAreaElement keyTextArea = querySelector("#keyTextArea");
  TextAreaElement outputTextArea = querySelector("#outputTextArea");
  TextAreaElement initVectorTextArea = querySelector("#initvectTextArea");
  DivElement encryptButton = querySelector("#encryptButton");
  DivElement keyGenerateButton = querySelector("#keyGenerateButton");
  DivElement decryptButton = querySelector("#decryptButton");
  ParagraphElement descriptionParagraph = querySelector('#description');

  encodings(inputTextArea, inputEncode, type: "Input");
  encodings(keyTextArea, keyEncode, type: "Key", changeValue: false);
  encodings(initVectorTextArea, keyEncode, type: "Key");
  encodings(outputTextArea, outputEncode, type: "Output");

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
  if (type == CIPHER_HILL) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_HILL,
        validator: nodeValidator);
    cipher = new HillCipher(256);
  }

  keyGenerateButton.onClick.listen((e) {
    keyTextArea.value = '';
    initVectorTextArea.value = '';
    try {
      cipher.generateKey();
      if (keyEncode[0] == ENCODING_HEX) {
        keyTextArea.value = bytesToHexString(cipher.key);
        initVectorTextArea.value = bytesToHexString(cipher.initVector);
      } else if (keyEncode[0] == ENCODING_LATIN1) {
        keyTextArea.value = bytesToString(cipher.key);
        initVectorTextArea.value = bytesToString(cipher.initVector);
      } else if (keyEncode[0] == ENCODING_BASE64) {
        keyTextArea.value = bytesToBase64String(cipher.key);
        initVectorTextArea.value = bytesToBase64String(cipher.initVector);
      }
    } catch (e) {
      toast(e.toString().replaceAll(new RegExp('Exception: '), ''));
      throw new Exception(e);
    }
  });

  void checkKey(String key, String iv) {
    try {
      if (key == null) throw new Exception("Key is empty!");
      if (keyEncode[0] == ENCODING_HEX) {
        cipher.key = hexStringToBytes(key);
        cipher.initVector = hexStringToBytes(iv);
      } else if (keyEncode[0] == ENCODING_LATIN1) {
        cipher.key = stringToBytes(key);
        cipher.initVector = stringToBytes(iv);
      } else if (keyEncode[0] == ENCODING_BASE64) {
        cipher.key = base64StringToBytes(key);
        cipher.initVector = base64StringToBytes(iv);
      }
    } catch (exception, stackTrace) {
      toast(exception.toString().replaceAll(new RegExp('Exception: '), ''));
      print(exception);
      throw new Exception(stackTrace);
    }
  }

  keyTextArea.onChange
      .listen((e) => checkKey(keyTextArea.value, initVectorTextArea.value));
  initVectorTextArea.onChange
      .listen((e) => checkKey(keyTextArea.value, initVectorTextArea.value));
  encryptButton.onClick.listen((e) {
    outputTextArea.value = '';
    try {
      checkKey(keyTextArea.value, initVectorTextArea.value);
      List list = null;
      if (inputEncode[0] == ENCODING_HEX) list =
          cipher.encrypt(hexStringToBytes(inputTextArea.value), mode: mode);
      else if (inputEncode[0] == ENCODING_LATIN1) list =
          cipher.encrypt(stringToBytes(inputTextArea.value), mode: mode);
      else if (inputEncode[0] == ENCODING_BASE64) list =
          cipher.encrypt(base64StringToBytes(inputTextArea.value), mode: mode);
      if (list == null) throw new Exception('Incorrect Initial Vector!');
      if (outputEncode[0] == ENCODING_HEX) outputTextArea.value =
          bytesToHexString(list);
      else if (outputEncode[0] == ENCODING_LATIN1) outputTextArea.value =
          bytesToString(list);
      else if (outputEncode[0] == ENCODING_BASE64) outputTextArea.value =
          bytesToBase64String(list);
    } catch (exception, stackTrace) {
      toast(exception.toString().replaceAll(new RegExp('Exception: '), ''));
      print(exception);
      throw new Exception(stackTrace);
    }
  });
  decryptButton.onClick.listen((e) {
    inputTextArea.value = '';
    try {
      checkKey(keyTextArea.value, initVectorTextArea.value);
      List list = null;
      if (outputEncode[0] == ENCODING_HEX) list =
          cipher.decrypt(hexStringToBytes(outputTextArea.value), mode: mode);
      else if (outputEncode[0] == ENCODING_LATIN1) list =
          cipher.decrypt(stringToBytes(outputTextArea.value), mode: mode);
      else if (outputEncode[0] == ENCODING_BASE64) list =
          cipher.decrypt(base64StringToBytes(outputTextArea.value), mode: mode);
      if (list == null) throw new Exception('Incorrect Initial Vector!');
      if (inputEncode[0] == ENCODING_HEX) inputTextArea.value =
          bytesToHexString(list);
      else if (inputEncode[0] == ENCODING_LATIN1) inputTextArea.value =
          bytesToString(list);
      else if (inputEncode[0] == ENCODING_BASE64) inputTextArea.value =
          bytesToBase64String(list);
    } catch (exception, stackTrace) {
      toast(exception.toString().replaceAll(new RegExp('Exception: '), ''));
      print(exception);
      throw new Exception(stackTrace);
    }
  });

  scrollTo(
      encryptButton, getDuration(encryptButton, 2), TimingFunctions.easeInOut);
}

void buildStandardCiphers(int type) {
  List inputEncode = [ENCODING_LATIN1];
  List keyEncode = [ENCODING_LATIN1];
  List outputEncode = [ENCODING_HEX];
  SpanElement wrapper = querySelector('#dynamic');
  wrapper?.setInnerHtml(HTML_CODE_STANDARD_CIPHERS, validator: nodeValidator);

  TextAreaElement inputTextArea = querySelector("#inputTextArea");
  TextAreaElement keyTextArea = querySelector("#keyTextArea");
  TextAreaElement outputTextArea = querySelector("#outputTextArea");
  DivElement encryptButton = querySelector("#encryptButton");
  DivElement keyGenerateButton = querySelector("#keyGenerateButton");
  DivElement decryptButton = querySelector("#decryptButton");
  ParagraphElement descriptionParagraph = querySelector('#description');

  encodings(inputTextArea, inputEncode, type: "Input");
  encodings(keyTextArea, keyEncode, type: "Key");
  encodings(outputTextArea, outputEncode, type: "Output");

  var cipher = null;
  if (type == CIPHER_VIGENERE) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_VIGENERE,
        validator: nodeValidator);
    cipher = new VigenereCipher(256);
  } else if (type == CIPHER_BEAUFORT) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_BEAUFORT,
        validator: nodeValidator);
    cipher = new BeaufortCipher(256);
  } else if (type == CIPHER_OTP) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_OTP,
        validator: nodeValidator);
    cipher = new OTPCipher(256);
  } else if (type == CIPHER_RC4) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_RC4,
        validator: nodeValidator);
    cipher = new RC4Cipher();
  } else if (type == CIPHER_RC4A) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_RC4,
        validator: nodeValidator);
    cipher = new RC4ACipher();
  } else if (type == CIPHER_RC4PLUS) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_RC4,
        validator: nodeValidator);
    cipher = new RC4PlusCipher();
  } else if (type == CIPHER_SPRITZ) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_RC4,
        validator: nodeValidator);
    cipher = new SpritzCipher();
  } else if (type == CIPHER_VMPC) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_RC4,
        validator: nodeValidator);
    cipher = new VMPCCipher();
  }

  void checkKey(String key) {
    try {
      if (key == null) throw new Exception("Key is empty!");
      if (keyEncode[0] == ENCODING_HEX) cipher.key = hexStringToBytes(key);
      else if (keyEncode[0] == ENCODING_LATIN1) cipher.key = stringToBytes(key);
      else if (keyEncode[0] == ENCODING_BASE64) cipher.key =
          base64StringToBytes(key);
    } catch (exception, stackTrace) {
      toast(exception.toString().replaceAll(new RegExp('Exception: '), ''));
      print(exception);
      throw new Exception(stackTrace);
    }
  }

  keyGenerateButton.onClick.listen((e) {
    keyTextArea.value = '';
    try {
      if (type == CIPHER_OTP) {
        if (inputTextArea.value.length != 0) cipher
            .generateKey(inputTextArea.value.length);
        else cipher.generateKey(outputTextArea.value.length);
      } else cipher.generateKey();
      if (keyEncode[0] == ENCODING_HEX) keyTextArea.value =
          bytesToHexString(cipher.key);
      else if (keyEncode[0] == ENCODING_LATIN1) keyTextArea.value =
          bytesToString(cipher.key);
      else if (keyEncode[0] == ENCODING_BASE64) keyTextArea.value =
          bytesToBase64String(cipher.key);
    } catch (exception, stackTrace) {
      toast(exception.toString().replaceAll(new RegExp('Exception: '), ''));
      print(exception);
      throw new Exception(stackTrace);
    }
  });

  keyTextArea.onChange.listen((e) => checkKey(keyTextArea.value));
  encryptButton.onClick.listen((e) {
    outputTextArea.value = '';
    try {
      checkKey(keyTextArea.value);
      List list = null;
      if (inputEncode[0] == ENCODING_HEX) list =
          cipher.encrypt(hexStringToBytes(inputTextArea.value));
      else if (inputEncode[0] == ENCODING_LATIN1) list =
          cipher.encrypt(stringToBytes(inputTextArea.value));
      else if (inputEncode[0] == ENCODING_BASE64) list =
          cipher.encrypt(base64StringToBytes(inputTextArea.value));
      if (list == null) throw new Exception('Incorrect message encoding!');
      if (outputEncode[0] == ENCODING_HEX) outputTextArea.value =
          bytesToHexString(list);
      else if (outputEncode[0] == ENCODING_LATIN1) outputTextArea.value =
          bytesToString(list);
      else if (outputEncode[0] == ENCODING_BASE64) outputTextArea.value =
          bytesToBase64String(list);
    } catch (exception, stackTrace) {
      toast(exception.toString().replaceAll(new RegExp('Exception: '), ''));
      print(exception);
      throw new Exception(stackTrace);
    }
  });
  decryptButton.onClick.listen((e) {
    inputTextArea.value = '';
    try {
      checkKey(keyTextArea.value);
      List list = null;
      if (outputEncode[0] == ENCODING_HEX) list =
          cipher.decrypt(hexStringToBytes(outputTextArea.value));
      else if (outputEncode[0] == ENCODING_LATIN1) list =
          cipher.decrypt(stringToBytes(outputTextArea.value));
      else if (outputEncode[0] == ENCODING_BASE64) list =
          cipher.decrypt(base64StringToBytes(outputTextArea.value));
      if (list == null) throw new Exception('Incorrect message encoding!');
      if (inputEncode[0] == ENCODING_HEX) inputTextArea.value =
          bytesToHexString(list);
      else if (inputEncode[0] == ENCODING_LATIN1) inputTextArea.value =
          bytesToString(list);
      else if (inputEncode[0] == ENCODING_BASE64) inputTextArea.value =
          bytesToBase64String(list);
    } catch (exception, stackTrace) {
      toast(exception.toString().replaceAll(new RegExp('Exception: '), ''));
      print(exception);
      throw new Exception(stackTrace);
    }
  });

  scrollTo(
      encryptButton, getDuration(encryptButton, 2), TimingFunctions.easeInOut);
}

void buildEncoding() {
  List inputEncode = [ENCODING_LATIN1];
  SpanElement wrapper = querySelector('#dynamic');

  wrapper.setInnerHtml(HTML_CODE_ENCODINGS, validator: nodeValidator);

  TextAreaElement inputTextArea = querySelector("#inputTextArea");
  ParagraphElement descriptionParagraph = querySelector('#description');

  encodings(inputTextArea, inputEncode, type: "Input");

  descriptionParagraph.appendHtml(TEXT_DESCRIPTION_ENCODINGS,
      validator: nodeValidator);

  scrollTo(
      inputTextArea, getDuration(inputTextArea, 2), TimingFunctions.easeInOut);
}

void buildRSA() {
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

void buildStandardHash(int type) {
  List inputEncode = [ENCODING_LATIN1];
  SpanElement wrapper = querySelector('#dynamic');

  wrapper.setInnerHtml(HTML_CODE_STANDARD_HASH, validator: nodeValidator);

  TextAreaElement inputTextArea = querySelector("#inputTextArea");
  TextAreaElement outputTextArea = querySelector("#outputTextArea");
  DivElement hashButton = querySelector("#hashButton");
  ParagraphElement descriptionParagraph = querySelector('#description');

  encodings(inputTextArea, inputEncode, type: "Input");

  var hash;
  if (type == HASH_SHA_1) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SHA_1,
        validator: nodeValidator);
    hash = new crypto.SHA1();
  } else if (type == HASH_SHA_256) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SHA_2,
        validator: nodeValidator);
    hash = new crypto.SHA256();
  } else if (type == HASH_MD5) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_MD5,
        validator: nodeValidator);
    hash = new crypto.MD5();
  }

  void calc_hash() {
    outputTextArea.value = '';
    try {
      if (inputEncode[0] == ENCODING_HEX) hash
          .add(hexStringToBytes(inputTextArea.value));
      else if (inputEncode[0] == ENCODING_LATIN1) hash
          .add(stringToBytes(inputTextArea.value));
      else if (inputEncode[0] == ENCODING_BASE64) hash
          .add(base64StringToBytes(inputTextArea.value));
      outputTextArea.value = bytesToHexString(hash.close());
      hash = hash.newInstance();
    } catch (e) {
      toast(e.toString().replaceAll(new RegExp('Exception: '), ''));
      throw new Exception(e);
    }
  }

  inputTextArea.onChange.listen((e) => calc_hash());
  hashButton.onClick.listen((e) => calc_hash());

  scrollTo(
      inputTextArea, getDuration(inputTextArea, 2), TimingFunctions.easeInOut);
}

void encodings(TextAreaElement field, List encode,
    {String type: "Input", bool changeValue: true}) {
  if (field == null) throw new ArgumentError.notNull('field');

  querySelector("#latin1$type")?.onClick?.listen((e) {
    try {
      if (encode[0] == ENCODING_HEX) field.value =
          LATIN1.decode(hexStringToBytes(field.value));
      if (encode[0] == ENCODING_BASE64) field.value =
          LATIN1.decode(base64StringToBytes(field.value));
      if (encode[0] == ENCODING_UTF8) field.value =
          LATIN1.decode(UTF8.encode(field.value));
      if (encode[0] == ENCODING_ASCII) field.value =
          LATIN1.decode(ASCII.encode(field.value));
      changeValue ? encode[0] = ENCODING_LATIN1 : encode[0] = encode[0];
    } catch (e) {
      toast("Cannot convert to LATIN1!");
      if (encode[0] == ENCODING_UTF8) querySelector("#utf8$type").click();
      if (encode[0] == ENCODING_HEX) querySelector("#hextext$type").click();
      if (encode[0] == ENCODING_BASE64) querySelector("#base64$type").click();
      if (encode[0] == ENCODING_ASCII) querySelector("#ascii$type").click();
      querySelector("#latin1$type").blur();
    }
  });
  querySelector("#hextext$type")?.onClick?.listen((e) {
    try {
      if (encode[0] == ENCODING_LATIN1) field.value =
          bytesToHexString(LATIN1.encode(field.value));
      if (encode[0] == ENCODING_BASE64) field.value =
          bytesToHexString(base64StringToBytes(field.value));
      if (encode[0] == ENCODING_UTF8) field.value =
          bytesToHexString(UTF8.encode(field.value));
      if (encode[0] == ENCODING_ASCII) field.value =
          bytesToHexString(ASCII.encode(field.value));
      changeValue ? encode[0] = ENCODING_HEX : encode[0] = encode[0];
    } catch (e) {
      toast("Cannot convert to Hex!");
      if (encode[0] == ENCODING_LATIN1) querySelector("#latin1$type")?.click();
      if (encode[0] == ENCODING_UTF8) querySelector("#utf8$type").click();
      if (encode[0] == ENCODING_BASE64) querySelector("#base64$type").click();
      if (encode[0] == ENCODING_ASCII) querySelector("#ascii$type").click();
      querySelector("#hextext$type").blur();
    }
  });
  querySelector("#base64$type")?.onClick?.listen((e) {
    try {
      if (encode[0] == ENCODING_LATIN1) field.value =
          bytesToBase64String(LATIN1.encode(field.value));
      if (encode[0] == ENCODING_HEX) field.value =
          bytesToBase64String(hexStringToBytes(field.value));
      if (encode[0] == ENCODING_UTF8) field.value =
          bytesToBase64String(UTF8.encode(field.value));
      if (encode[0] == ENCODING_ASCII) field.value =
          bytesToBase64String(ASCII.encode(field.value));
      changeValue ? encode[0] = ENCODING_BASE64 : encode[0] = encode[0];
    } catch (e) {
      toast("Cannot convert to Base64!");
      if (encode[0] == ENCODING_LATIN1) querySelector("#latin1$type").click();
      if (encode[0] == ENCODING_HEX) querySelector("#hextext$type").click();
      if (encode[0] == ENCODING_UTF8) querySelector("#utf8$type").click();
      if (encode[0] == ENCODING_ASCII) querySelector("#ascii$type").click();
      querySelector("#base64$type").blur();
    }
  });
  querySelector("#utf8$type")?.onClick?.listen((e) {
    try {
      if (encode[0] == ENCODING_LATIN1) field.value =
          UTF8.decode(LATIN1.encode(field.value));
      if (encode[0] == ENCODING_HEX) field.value =
          UTF8.decode(hexStringToBytes(field.value));
      if (encode[0] == ENCODING_BASE64) field.value =
          UTF8.decode(base64StringToBytes(field.value));
      if (encode[0] == ENCODING_ASCII) field.value =
          UTF8.decode(ASCII.encode(field.value));
      changeValue ? encode[0] = ENCODING_UTF8 : encode[0] = encode[0];
    } catch (e) {
      toast("Cannot convert to UTF-8!");
      if (encode[0] == ENCODING_LATIN1) querySelector("#latin1$type").click();
      if (encode[0] == ENCODING_HEX) querySelector("#hextext$type").click();
      if (encode[0] == ENCODING_BASE64) querySelector("#base64$type").click();
      if (encode[0] == ENCODING_ASCII) querySelector("#ascii$type").click();
      querySelector("#utf8$type").blur();
    }
  });
  querySelector("#ascii$type")?.onClick?.listen((e) {
    try {
      if (encode[0] == ENCODING_LATIN1) field.value =
          ASCII.decode(LATIN1.encode(field.value));
      if (encode[0] == ENCODING_HEX) field.value =
          ASCII.decode(hexStringToBytes(field.value));
      if (encode[0] == ENCODING_UTF8) field.value =
          ASCII.decode(UTF8.encode(field.value));
      if (encode[0] == ENCODING_BASE64) field.value =
          ASCII.decode(base64StringToBytes(field.value));
      changeValue ? encode[0] = ENCODING_ASCII : encode[0] = encode[0];
    } catch (e) {
      toast("Cannot convert to ASCII!");
      if (encode[0] == ENCODING_LATIN1) querySelector("#latin1$type").click();
      if (encode[0] == ENCODING_HEX) querySelector("#hextext$type").click();
      if (encode[0] == ENCODING_BASE64) querySelector("#base64$type").click();
      if (encode[0] == ENCODING_UTF8) querySelector("#utf8$type").click();
      querySelector("#ascii$type").blur();
    }
  });
}

class MyUriPolicy implements UriPolicy {
  bool allowsUri(uri) => true;
}
