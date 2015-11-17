import 'dart:convert';
import 'dart:html';

import 'package:dartcrypto/dartcrypto.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:rsa/rsa.dart' as rsa;
import 'package:cipher/cipher.dart' as cipher;
import "package:cipher/impl/client.dart" as client_cipher;

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
    throw new Exception("You didn\'t select anything!");
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
      break;*/
    case CIPHER_RSA_GENERATOR:
      buildRSAPEMGenerator();
      break;
    case ENCODINGS:
      buildEncoding();
      break;
    case HASH_SHA_1:
    case HASH_SHA_224:
    case HASH_SHA_256:
    case HASH_SHA_384:
    case HASH_SHA_512:
    case HASH_SHA_512_224:
    case HASH_SHA_512_256:
    case HASH_SHA_3_224:
    case HASH_SHA_3_256:
    case HASH_SHA_3_384:
    case HASH_SHA_3_512:
    case HASH_MD2:
    case HASH_MD4:
    case HASH_MD5:
    case HASH_TIGER:
    case HASH_WHIRLPOOL:
    case HASH_RIPEMD_128:
    case HASH_RIPEMD_160:
    case HASH_RIPEMD_256:
    case HASH_RIPEMD_320:
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
      tempKey = getBytesFromString(key, keyEncode);
      if (tempKey == null || tempKey.length != 1) throw new Exception(
          "Incorrect encoding key $keyNumber!");
      if (keyNumber == 1) cipher.key_A = tempKey[0];
      else if (keyNumber == 2) cipher.key_B = tempKey[0];
    } catch (exception, stackTrace) {
      toast(exception.toString().replaceAll(new RegExp('Exception: '), ''));
      print(exception);
      throw new Exception(stackTrace);
    }
  }

  keyGenerateButton.onClick.listen((e) {
    keyTextAreaA.value = '';
    keyTextAreaB.value = '';
    try {
      cipher.generateKey();
      if (type == CIPHER_CAESAR) cipher.key_A = 0x01;
      keyTextAreaA.value = getStringFromBytes([cipher.key_A], keyEncode);
      keyTextAreaB.value = getStringFromBytes([cipher.key_B], keyEncode);
    } catch (exception, stackTrace) {
      toast(exception.toString().replaceAll(new RegExp('Exception: '), ''));
      print(exception);
      throw new Exception(stackTrace);
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
      List list =
          cipher.encrypt(getBytesFromString(inputTextArea.value, inputEncode));
      if (list == null) throw new Exception('Incorrect message encoding!');
      outputTextArea.value = getStringFromBytes(list, outputEncode);
    } catch (exception, stackTrace) {
      toast(exception.toString().replaceAll(new RegExp('Exception: '), ''));
      print(exception);
      throw new Exception(stackTrace);
    }
  });
  decryptButton.onClick.listen((e) {
    inputTextArea.value = '';
    try {
      checkKey(keyTextAreaA.value, keyNumber: 1);
      checkKey(keyTextAreaB.value, keyNumber: 2);
      List list = cipher
          .decrypt(getBytesFromString(outputTextArea.value, outputEncode));
      if (list == null) throw new Exception('Incorrect message encoding!');
      inputTextArea.value = getStringFromBytes(list, inputEncode);
    } catch (exception, stackTrace) {
      toast(exception.toString().replaceAll(new RegExp('Exception: '), ''));
      print(exception);
      throw new Exception(stackTrace);
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
      keyTextArea.value = getStringFromBytes(cipher.key, keyEncode);
      initVectorTextArea.value =
          getStringFromBytes(cipher.initVector, keyEncode);
    } catch (exception, stackTrace) {
      toast(exception.toString().replaceAll(new RegExp('Exception: '), ''));
      print(exception);
      throw new Exception(stackTrace);
    }
  });

  void checkKey(String key, String iv) {
    try {
      if (key == null) throw new Exception("Key is empty!");
      cipher.key = getBytesFromString(key, keyEncode);
      cipher.initVector = getBytesFromString(iv, keyEncode);
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
      List list = cipher.decrypt(
          getBytesFromString(inputTextArea.value, inputEncode),
          mode: mode);
      if (list == null) throw new Exception('Incorrect Initial Vector!');
      outputTextArea.value = getStringFromBytes(list, outputEncode);
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
      List list = cipher.decrypt(
          getBytesFromString(outputTextArea.value, outputEncode),
          mode: mode);
      if (list == null) throw new Exception('Incorrect Initial Vector!');
      inputTextArea.value = getStringFromBytes(list, inputEncode);
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
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_RC4A,
        validator: nodeValidator);
    cipher = new RC4ACipher();
  } else if (type == CIPHER_RC4PLUS) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_RC4PLUS,
        validator: nodeValidator);
    cipher = new RC4PlusCipher();
  } else if (type == CIPHER_SPRITZ) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SPRITZ,
        validator: nodeValidator);
    cipher = new SpritzCipher();
  } else if (type == CIPHER_VMPC) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_VMPC,
        validator: nodeValidator);
    cipher = new VMPCCipher();
  }

  void checkKey(String key) {
    try {
      if (key == null) throw new Exception("Key is empty!");
      cipher.key = getBytesFromString(key, keyEncode);
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
        String str;
        if (inputTextArea.value.length != 0) str = inputTextArea.value;
        else str = outputTextArea.value;
        int len = getBytesFromString(str, inputEncode).length;
        cipher.generateKey(len);
      } else cipher.generateKey();
      keyTextArea.value = getStringFromBytes(cipher.key, keyEncode);
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
      List list =
          cipher.encrypt(getBytesFromString(inputTextArea.value, inputEncode));
      if (list == null) throw new Exception('Incorrect message encoding!');
      outputTextArea.value = getStringFromBytes(list, outputEncode);
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
      List list = cipher
          .decrypt(getBytesFromString(outputTextArea.value, outputEncode));
      if (list == null) throw new Exception('Incorrect message encoding!');
      inputTextArea.value = getStringFromBytes(list, inputEncode);
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

void buildRSAPEMGenerator() {
  List inputEncode = [ENCODING_LATIN1];
  SpanElement wrapper = querySelector('#dynamic');
  wrapper.setInnerHtml(HTML_CODE_RSA_PEM_GENERATOR, validator: nodeValidator);

  TextAreaElement inputTextArea = querySelector("#inputTextArea");
  TextAreaElement outputTextArea = querySelector("#outputTextArea");
  DivElement generatePEMButton = querySelector("#generatePEMButton");
  DivElement generateCoefButton = querySelector("#generateCoefButton");
  ParagraphElement descriptionParagraph = querySelector('#description');

  encodings(inputTextArea, inputEncode, type: "Input");

  descriptionParagraph.appendHtml(TEXT_DESCRIPTION_RSA_PEM_GENERATOR,
      validator: nodeValidator);

  scrollTo(
      inputTextArea, getDuration(inputTextArea, 2), TimingFunctions.easeInOut);
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

  String digestName;
  client_cipher.initCipher();
  if (type == HASH_SHA_1) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SHA_1,
        validator: nodeValidator);
    digestName = "SHA-1";
  } else if (type == HASH_SHA_224) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SHA_2,
        validator: nodeValidator);
    digestName = "SHA-224";
  } else if (type == HASH_SHA_256) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SHA_2,
        validator: nodeValidator);
    digestName = "SHA-256";
  } else if (type == HASH_SHA_384) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SHA_2,
        validator: nodeValidator);
    digestName = "SHA-384";
  } else if (type == HASH_SHA_512) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SHA_2,
        validator: nodeValidator);
    digestName = "SHA-512";
  } else if (type == HASH_SHA_512_224) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SHA_2,
        validator: nodeValidator);
    digestName = "SHA-512/224";
  } else if (type == HASH_SHA_512_256) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SHA_2,
        validator: nodeValidator);
    digestName = "SHA-512/256";
  } else if (type == HASH_SHA_3_224) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SHA_3,
        validator: nodeValidator);
    digestName = "SHA-3/224";
  } else if (type == HASH_SHA_3_256) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SHA_3,
        validator: nodeValidator);
    digestName = "SHA-3/256";
  } else if (type == HASH_SHA_3_384) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SHA_3,
        validator: nodeValidator);
    digestName = "SHA-3/384";
  } else if (type == HASH_SHA_3_512) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_SHA_3,
        validator: nodeValidator);
    digestName = "SHA-3/512";
  } else if (type == HASH_MD5) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_MD5,
        validator: nodeValidator);
    digestName = "MD5";
  } else if (type == HASH_MD2) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_MD2,
        validator: nodeValidator);
    digestName = "MD2";
  } else if (type == HASH_MD4) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_MD4,
        validator: nodeValidator);
    digestName = "MD4";
  } else if (type == HASH_MD4) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_MD4,
        validator: nodeValidator);
    digestName = "MD4";
  } else if (type == HASH_TIGER) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_TIGER,
        validator: nodeValidator);
    digestName = "Tiger";
  } else if (type == HASH_WHIRLPOOL) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_WHIRLPOOL,
        validator: nodeValidator);
    digestName = "Whirlpool";
  } else if (type == HASH_RIPEMD_128) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_RIPEMD,
        validator: nodeValidator);
    digestName = "RIPEMD-128";
  } else if (type == HASH_RIPEMD_160) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_RIPEMD,
        validator: nodeValidator);
    digestName = "RIPEMD-160";
  } else if (type == HASH_RIPEMD_256) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_RIPEMD,
        validator: nodeValidator);
    digestName = "RIPEMD-256";
  } else if (type == HASH_RIPEMD_320) {
    descriptionParagraph.appendHtml(TEXT_DESCRIPTION_RIPEMD,
        validator: nodeValidator);
    digestName = "RIPEMD-320";
  }
  var digest = new cipher.Digest(digestName);

  void calc_hash() {
    outputTextArea.value = '';
    try {
      digest.reset();
      outputTextArea.value = bytesToHexString(digest.process(getBytesFromString(inputTextArea.value, inputEncode)));
    } catch (exception, stackTrace) {
      toast(exception.toString().replaceAll(new RegExp('Exception: '), ''));
      print(exception);
      throw new Exception(stackTrace);
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

  void clickBack() {
    if (encode[0] == ENCODING_LATIN1) querySelector("#latin1$type").click();
    if (encode[0] == ENCODING_HEX) querySelector("#hextext$type").click();
    if (encode[0] == ENCODING_BASE64) querySelector("#base64$type").click();
    if (encode[0] == ENCODING_UTF8) querySelector("#utf8$type").click();
    if (encode[0] == ENCODING_ASCII) querySelector("#ascii$type").click();
  }

  querySelector("#latin1$type")?.onClick?.listen((e) {
    try {
      field.value = LATIN1.decode(getBytesFromString(field.value, encode));
      changeValue ? encode[0] = ENCODING_LATIN1 : encode[0] = encode[0];
    } catch (e) {
      toast("Cannot convert to LATIN1!");
      clickBack();
      querySelector("#latin1$type").blur();
    }
  });
  querySelector("#hextext$type")?.onClick?.listen((e) {
    try {
      field.value = bytesToHexString(getBytesFromString(field.value, encode));
      changeValue ? encode[0] = ENCODING_HEX : encode[0] = encode[0];
    } catch (e) {
      toast("Cannot convert to Hex!");
      clickBack();
      querySelector("#hextext$type").blur();
    }
  });
  querySelector("#base64$type")?.onClick?.listen((e) {
    try {
      field.value =
          bytesToBase64String(getBytesFromString(field.value, encode));
      changeValue ? encode[0] = ENCODING_BASE64 : encode[0] = encode[0];
    } catch (e) {
      toast("Cannot convert to Base64!");
      clickBack();
      querySelector("#base64$type").blur();
    }
  });
  querySelector("#utf8$type")?.onClick?.listen((e) {
    try {
      field.value = UTF8.decode(getBytesFromString(field.value, encode));
      changeValue ? encode[0] = ENCODING_UTF8 : encode[0] = encode[0];
    } catch (e) {
      toast("Cannot convert to UTF-8!");
      clickBack();
      querySelector("#utf8$type").blur();
    }
  });
  querySelector("#ascii$type")?.onClick?.listen((e) {
    try {
      field.value = ASCII.decode(getBytesFromString(field.value, encode));
      changeValue ? encode[0] = ENCODING_ASCII : encode[0] = encode[0];
    } catch (e) {
      toast("Cannot convert to ASCII!");
      clickBack();
      querySelector("#ascii$type").blur();
    }
  });
}

List getBytesFromString(String field, List encode) {
  if (encode[0] == ENCODING_HEX) return hexStringToBytes(field);
  if (encode[0] == ENCODING_LATIN1) return LATIN1.encode(field);
  if (encode[0] == ENCODING_BASE64) return base64StringToBytes(field);
  if (encode[0] == ENCODING_UTF8) return UTF8.encode(field);
  if (encode[0] == ENCODING_ASCII) return ASCII.encode(field);
  return null;
}

String getStringFromBytes(List field, List encode) {
  if (encode[0] == ENCODING_HEX) return bytesToHexString(field);
  if (encode[0] == ENCODING_LATIN1) return LATIN1.decode(field);
  if (encode[0] == ENCODING_BASE64) return bytesToBase64String(field);
  if (encode[0] == ENCODING_UTF8) return UTF8.decode(field);
  if (encode[0] == ENCODING_ASCII) return ASCII.decode(field);
  return null;
}

class MyUriPolicy implements UriPolicy {
  bool allowsUri(uri) => true;
}
