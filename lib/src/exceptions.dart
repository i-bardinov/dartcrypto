library dartcrypto.exceptions;

class PopUpError implements Exception {
  String msg;

  PopUpError(String keyValue) {
    if (keyValue == null || keyValue == "") keyValue = "null";
    msg = keyValue;
    //window.alert('$msg');

  }

  String toString() => "$msg";
}
