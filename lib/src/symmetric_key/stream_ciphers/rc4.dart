library dartcrypto.ciphers.rc4;

import 'dart:math' as math show pow, Random;

class RC4Cipher {
  List key = null;
  List s_box = null;
  int parI = 0, parJ = 0;

  int n = 256;

  static int KEY_MAX_SIZE = 256;

  RC4Cipher([int blockSize = 8, this.key]) {
    this.n = math.pow(2, blockSize);
  }

  void init() {
    parI = 0;
    parJ = 0;
    if (key == null) throw new Exception("Key is null!");
    s_box = new List.generate(n, (int k) => k);
    int j = 0, keySize = key.length;
    for (int i = 0; i < n; i++) {
      j = (j + s_box[i] + key[i % keySize]) % n;
      int temp = s_box[i];
      s_box[i] = s_box[j];
      s_box[j] = temp;
    }
  }

  int generateRandomByte() {
    parI = (parI + 1) % n;
    parJ = (parJ + s_box[parI]) % n;
    int temp = s_box[parI];
    s_box[parI] = s_box[parJ];
    s_box[parJ] = temp;
    return s_box[(s_box[parI] + s_box[parJ]) % n];
  }

  void generateKey([int length = 32]) {
    math.Random rand = new math.Random();
    if (length == null) length = rand.nextInt(KEY_MAX_SIZE) + 1;
    key = new List.generate(length, (i) => rand.nextInt(256));
  }

  List encrypt(List message) {
    if (message == null) throw new Exception("Message is null!");
    init();
    for (int i = 0;
        i < message.length;
        i++) message[i] = message[i] ^ generateRandomByte();
    return message;
  }

  List decrypt(List message) {
    if (message == null) throw new Exception("Message is null!");
    init();
    for (int i = 0;
        i < message.length;
        i++) message[i] = message[i] ^ generateRandomByte();
    return message;
  }
}

class RC4PlusCipher extends RC4Cipher {
  RC4PlusCipher([int blockSize = 8, List key]) : super(blockSize, key);

  int generateRandomByte() {
    parI = (parI + 1) % n;
    int a = s_box[parI];
    parJ = (parJ + a) % n;
    int b = s_box[parJ];
    s_box[parI] = b;
    s_box[parJ] = a;
    int c = (s_box[((parI << 5) ^ (parJ >> 3)) % n] +
            s_box[((parJ << 5) ^ (parI >> 3)) % n]) %
        n;
    return ((s_box[(a + b) % n] + s_box[c ^ 0xAA]) % n) ^ s_box[(parJ + b) % n];
  }
}

class SpritzCipher extends RC4Cipher {
  int prime = 13, parK = 0;

  SpritzCipher([int blockSize = 8, List key]) {
    this.n = math.pow(2, blockSize);
    /*math.Random rand = new math.Random();
    do {
      prime = rand.nextInt(n);
    } while (prime.gcd(n) != 1);*/
  }

  void init() {
    parI = 0;
    parJ = 0;
    parK = 0;
    if (key == null) throw new Exception("Key is null!");
    s_box = new List.generate(n, (int k) => k);
    int j = 0, keySize = key.length;
    for (int i = 0; i < n; i++) {
      j = (j + s_box[i] + key[i % keySize]) % n;
      int temp = s_box[i];
      s_box[i] = s_box[j];
      s_box[j] = temp;
    }
  }

  int generateRandomByte(int parZ) {
    parI = (parI + prime) % n;
    parJ = (parK + s_box[(parJ + s_box[parI]) % n]) % n;
    parK = (parK + parI + s_box[parJ]) % n;
    int temp = s_box[parI];
    s_box[parI] = s_box[parJ];
    s_box[parJ] = temp;
    return s_box[(parJ + s_box[(parI + s_box[(parZ + parK) % n]) % n]) % n];
  }

  List encrypt(List message) {
    if (message == null) throw new Exception("Message is null!");
    init();
    int z = generateRandomByte(0);
    for (int i = 0; i < message.length; i++) {
      message[i] = message[i] ^ z;
      z = generateRandomByte(z);
    }
    return message;
  }

  List decrypt(List message) {
    if (message == null) throw new Exception("Message is null!");
    init();
    int z = generateRandomByte(0);
    for (int i = 0; i < message.length; i++) {
      message[i] = message[i] ^ z;
      z = generateRandomByte(z);
    }
    return message;
  }
}

class RC4ACipher extends RC4Cipher {
  int parI = 0, parJ1 = 0, parJ2 = 0;
  List s_box1 = null, s_box2 = null;
  RC4ACipher([int blockSize = 8, List key]) : super(blockSize, key);

  void init() {
    parI = 0;
    parJ1 = 0;
    parJ2 = 0;
    if (key == null) throw new Exception("Key is null!");
    s_box1 = new List.generate(n, (int k) => k);
    int j = 0, keySize = key.length;
    for (int i = 0; i < n; i++) {
      j = (j + s_box1[i] + key[i % keySize]) % n;
      int temp = s_box1[i];
      s_box1[i] = s_box1[j];
      s_box1[j] = temp;
    }
    s_box2 = new List.from(s_box1);
  }

  List generateRandomByte() {
    parI = (parI + 1) % n;
    parJ1 = (parJ1 + s_box1[parI]) % n;
    int temp = s_box1[parI];
    s_box1[parI] = s_box1[parJ1];
    s_box1[parJ1] = temp;
    int out1 = s_box2[(s_box1[parI] + s_box1[parJ1]) % n];

    parJ2 = (parJ2 + s_box2[parI]) % n;
    temp = s_box2[parI];
    s_box2[parI] = s_box2[parJ2];
    s_box2[parJ2] = temp;
    int out2 = s_box1[(s_box2[parI] + s_box2[parJ2]) % n];
    return [out1, out2];
  }

  List encrypt(List message) {
    if (message == null) throw new Exception("Message is null!");
    int messageSize = message.length;
    init();
    for (int i = 0; i < messageSize; i += 2) {
      List temp = generateRandomByte();
      message[i] = message[i] ^ temp[0];
      if (i + 1 < messageSize) message[i + 1] = message[i + 1] ^ temp[1];
    }
    return message;
  }

  List decrypt(List message) {
    if (message == null) throw new Exception("Message is null!");
    int messageSize = message.length;
    init();
    for (int i = 0; i < messageSize; i += 2) {
      List temp = generateRandomByte();
      message[i] = message[i] ^ temp[0];
      if (i + 1 < messageSize) message[i + 1] = message[i + 1] ^ temp[1];
    }
    return message;
  }
}

class VMPCCipher extends RC4Cipher {
  VMPCCipher([int blockSize = 8, List key]) : super(blockSize, key);

  void init() {
    parI = 0;
    parJ = 0;
    if (key == null) throw new Exception("Key is null!");
    s_box = new List.generate(n, (int k) => k);
    int i = 0, keySize = key.length;
    for (int j = 0; j < 3 * n; j++) {
      i = j % n;
      parJ = s_box[(parJ + s_box[i] + key[j % keySize]) % n];
      int temp = s_box[i];
      s_box[i] = s_box[parJ];
      s_box[parJ] = temp;
    }
  }

  int generateRandomByte() {
    parJ = s_box[(parJ + s_box[parI]) % n];
    int output = s_box[(s_box[s_box[parJ]] + 1) % n];
    int temp = s_box[parI];
    s_box[parI] = s_box[parJ];
    s_box[parJ] = temp;
    parI = (parI + 1) % n;
    return output;
  }
}
