const String TEXT_DESCRIPTION_CAESAR =
'''
In cryptography, a <a href=\'https://en.wikipedia.org/wiki/Caesar_cipher\' target=\'_blank\'>Caesar cipher</a>,
also known as Caesar's cipher, the shift cipher, Caesar's code or Caesar shift, is one of the simplest and most
widely known encryption techniques. It is a type of substitution cipher in which each letter in the plaintext
is replaced by a letter some fixed number of positions down the alphabet. For example, with a left shift of 3,
D would be replaced by A, E would become B, and so on. The method is named after Julius Caesar, who used it
in his private correspondence. <br><br> <b>Message, key and encrypted message</b> is a <b>hexadecimal</b>
string each <b>2 characters is 1 octet</b> (i.e. FFAB1F is 3 octet - FF, AB, 1F). <b>Key</b> should be only <b>1 hex
octet </b> (i.e. AB) - it is a shift. For each octet <b>x</b> from message we have: E(x) = x + key.
''';
const String TEXT_DESCRIPTION_AFFINE =
'''
<a href=\'https://en.wikipedia.org/wiki/Affine_cipher\' target=\'_blank\'>The affine cipher</a>
is a type of monoalphabetic substitution cipher, wherein each letter in an alphabet is mapped
to its numeric equivalent, encrypted using a simple mathematical function, and converted back to a letter.
The formula used means that each letter encrypts to one other letter, and back again, meaning the cipher is
essentially a standard substitution cipher with a rule governing which letter goes to which. As such, it has
the weaknesses of all substitution ciphers. <br><br><b>Message, key and encrypted message</b> is a <b>hexadecimal</b>
string each <b>2 character is 1 octet</b> (i.e. FFAB1F is 3 octet - FF, AB, 1F). <b>Key</b> should be only <b>2 hex
octets</b> (i.e. AB24). For each octet <b>x</b> from message we have: E(x) = x*key[1] + key[2].
''';
const String TEXT_DESCRIPTION_HILL =
'''
In classical cryptography, the <a href=\'https://en.wikipedia.org/wiki/Hill_cipher\' target=\'_blank\'>Hill cipher</a>
 is a polygraphic substitution cipher based on linear algebra.
Invented by Lester S. Hill in 1929, it was the first polygraphic cipher in which it was practical (though barely)
to operate on more than three symbols at once. <br><br><b>Message, key and encrypted message</b> is a <b>hexadecimal</b>
string each <b>2 character is 1 octet</b> (i.e. FFAB1F is 3 octet - FF, AB, 1F). <b>Key size</b> should be a <b>square hex
octets</b> (i.e. 1, 4, 9, 16, ... octets). Key is a matrix of dimension equal to square of key size. You can add 00 to
fill key or it can be made automatically by program.
''';
const String TEXT_DESCRIPTION_VIGENERE =
'''
<a href=\'https://en.wikipedia.org/wiki/Vigenere_cipher\' target=\'_blank\'>The Vigenere cipher</a> is a
method of encrypting alphabetic text by using a series of different Caesar ciphers
based on the letters of a keyword. It is a simple form of polyalphabetic substitution. <br><br><b>Message,
key and encrypted message</b> is a <b>hexadecimal</b>
string each <b>2 character is 1 octet</b> (i.e. FFAB1F is 3 octet - FF, AB, 1F). <b>Key</b> can be any size.
''';
const String TEXT_DESCRIPTION_BEAUFORT =
'''
<a href=\'https://en.wikipedia.org/wiki/Beaufort_cipher\' target=\'_blank\'>The Beaufort cipher</a>,
created by Sir Francis Beaufort, is a substitution cipher similar to the Vigen?re cipher,
with a slightly modified enciphering mechanism and tableau.
<br><br><b>Message, key and encrypted message</b> is a <b>hexadecimal</b>
string each <b>2 character is 1 octet</b> (i.e. FFAB1F is 3 octet - FF, AB, 1F). <b>Key</b> can be any size.
''';
const String TEXT_DESCRIPTION_OTP =
'''
In cryptography, <a href=\'https://en.wikipedia.org/wiki/One-time_pad\' target=\'_blank\'>the one-time pad (OTP)</a>
is an encryption technique that cannot be cracked if used correctly. In this technique, a plaintext is paired with a
random secret key (also referred to as a one-time pad). Then, each bit or character of the plaintext is encrypted by
combining it with the corresponding bit or character from the pad using modular addition. If the key is truly random,
is at least as long as the plaintext, is never reused in whole or in part, and is kept completely secret, then the
resulting ciphertext will be impossible to decrypt or break. It has also been proven that any cipher with
the perfect secrecy property must use keys with effectively the same requirements as OTP keys. However, practical
problems have prevented one-time pads from being widely used.
<br><br><b>Message, key and encrypted message</b> is a <b>hexadecimal</b>
string each <b>2 character is 1 octet</b> (i.e. FFAB1F is 3 octet - FF, AB, 1F). <b>Key size</b> should be equal
to <b>message size</b>.
''';
const String TEXT_DESCRIPTION_AES =
'''

''';
const String TEXT_DESCRIPTION_MAGMA =
'''

''';
const String TEXT_DESCRIPTION_RSA =
'''
<a href=\'https://en.wikipedia.org/wiki/RSA_(cryptosystem)\' target=\'_blank\'>RSA</a> is one of the first practical public-key cryptosystems and is widely used for secure data transmission.
In such a cryptosystem, the encryption key is public and differs from the decryption key which is kept secret.
In RSA, this asymmetry is based on the practical difficulty of factoring the product of two large prime numbers,
the factoring problem. RSA is made of the initial letters of the surnames of Ron Rivest, Adi Shamir, and Leonard
Adleman, who first publicly described the algorithm in 1977.<br>
A user of RSA creates and then publishes a public key based on two large prime numbers, along with an auxiliary value.
The prime numbers must be kept secret. Anyone can use the public key to encrypt a message, but with currently
published methods, if the public key is large enough, only someone with knowledge of the prime numbers can
feasibly decode the message.
''';
const String TEXT_DESCRIPTION_SHA_1 =
'''
In cryptography, <a href=\'https://en.wikipedia.org/wiki/SHA-1\' target=\'_blank\'>SHA-1 (Secure Hash Algorithm 1)</a>
 is a cryptographic hash function designed by the United
States National Security Agency and is a U.S. Federal Information Processing Standard published by the
United States NIST. SHA-1 is considered insecure against well-funded opponents, and it is recommended
 to use SHA-2 or SHA-3 instead.
SHA-1 produces a 160-bit (20-byte) hash value known as a message digest. A SHA-1 hash value is
typically rendered as a hexadecimal number, 40 digits long.
''';
const String TEXT_DESCRIPTION_HEX =
'''
In mathematics and computing, <a href=\'https://en.wikipedia.org/wiki/Hexadecimal\' target=\'_blank\'>hexadecimal
(also base 16, or hex)</a> is a positional numeral system with a radix, or base, of 16. It uses sixteen distinct
symbols, most often the symbols 0 - 9 to represent values zero to nine, and A, B, C, D, E, F (or alternatively a, b, c,
 d, e, f) to represent values ten to fifteen. Hexadecimal numerals are widely used by computer systems designers
  and programmers.
''';

const int ENCODING_HEX = 101;

const int CIPHER_CAESAR = 1001;
const int CIPHER_AFFINE = 1002;
const int CIPHER_VIGENERE = 1003;
const int CIPHER_BEAUFORT = 1004;
const int CIPHER_OTP = 1005;
const int CIPHER_HILL = 1101;
const int CIPHER_MAGMA = 2001;
const int CIPHER_AES = 2002;

const int CIPHER_RSA = 3001;

const int HASH_SHA_1 = 4001;

const int KEY_MAX_SIZE_VIGENERE = 20;
const int KEY_MAX_SIZE_BEAUFORT = 20;
const int KEY_MAX_DIM_HILL = 4;
