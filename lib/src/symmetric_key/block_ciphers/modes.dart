library dartcrypto.ciphers.modes;

List ECB_mode_encryption(List message, enc) {
  return enc(message);
}

List ECB_mode_decryption(List message, dec) {
  return dec(message);
}

List CBC_mode_encryption(List message, List prevEncMessage, enc) {
  if (message.length !=
  prevEncMessage.length) throw new Exception('Error in block size!');
  for (int i = 0;
  i < message.length;
  i++) message[i] = message[i] ^ prevEncMessage[i];
  return enc(message);
}

List CBC_mode_decryption(List message, List prevEncMessage, dec) {
  if (message.length !=
  prevEncMessage.length) throw new Exception('Error in block size!');
  message = dec(message);
  for (int i = 0;
  i < message.length;
  i++) message[i] = message[i] ^ prevEncMessage[i];
  return message;
}

List PCBC_mode_encryption(
    List message, List prevMessage, List prevEncMessage, enc) {
  if (message.length != prevEncMessage.length ||
  message.length !=
  prevMessage.length) throw new Exception('Error in block size!');
  for (int i = 0;
  i < message.length;
  i++) message[i] = message[i] ^ prevMessage[i] ^ prevEncMessage[i];
  return enc(message);
}

List PCBC_mode_decryption(
    List message, List prevMessage, List prevEncMessage, dec) {
  if (message.length != prevEncMessage.length ||
  message.length !=
  prevMessage.length) throw new Exception('Error in block size!');
  message = dec(message);
  for (int i = 0;
  i < message.length;
  i++) message[i] = message[i] ^ prevEncMessage[i] ^ prevMessage[i];
  return message;
}

List CFB_mode_encryption(List message, List prevEncMessage, enc) {
  if (message.length !=
  prevEncMessage.length) throw new Exception('Error in block size!');
  prevEncMessage = enc(prevEncMessage);
  for (int i = 0;
  i < message.length;
  i++) message[i] = prevEncMessage[i] ^ message[i];
  return message;
}

List CFB_mode_decryption(List message, List prevEncMessage, dec) {
  if (message.length !=
  prevEncMessage.length) throw new Exception('Error in block size!');
  prevEncMessage = dec(prevEncMessage);
  for (int i = 0;
  i < message.length;
  i++) message[i] = message[i] ^ prevEncMessage[i];
  return message;
}

List OFB_mode_encryption() {
  // TODO: implement
  return [];
}

List OFB_mode_decryption() {
  // TODO: implement
  return [];
}

List CTR_mode_encryption() {
  // TODO: implement
  return [];
}

List CTR_mode_decryption() {
  // TODO: implement
  return [];
}
