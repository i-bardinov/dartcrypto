const String ALPHABET_STANDARD = "_ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.?,-";
const String TEXT_ALPHABET = "Alphabet: ";
const String TEXT_MESSAGE_TO_ENCRYPT = "Message to encrypt: ";
const String TEXT_MESSAGE_TO_DECRYPT = "Message to decrypt: ";
const String TEXT_KEY_AFFINE = "Key A and key B (Ax + B, A,B - Integers, x - symbol of message): ";
const String TEXT_KEY_CAESAR = "Key B (x + B, B - Integer, x - symbol of message): ";
const String TEXT_KEY_HILL = "Key: ";
const String TEXT_ENCRYPTED_MESSAGE = "Encrypted Message:  ";
const String TEXT_DECRYPTED_MESSAGE = "Decrypted Message:  ";
const String BUTTON_GENERATE_KEY = "Generate Key";
const String BUTTON_ENCRYPT_MESSAGE = "Encrypt";
const String BUTTON_DECRYPT_MESSAGE = "Decrypt";

const int CIPHER_CAESAR = 0;
const int CIPHER_AFFINE = 1;
const int CIPHER_HILL = 2;
const int CIPHER_VIGENERE = 3;
const int CIPHER_BEAUFORT = 4;

const int CIPHER_TYPE_ENCRYPT = 0;
const int CIPHER_TYPE_DECRYPT = 1;
const int CIPHER_TYPE_HACK = 2;