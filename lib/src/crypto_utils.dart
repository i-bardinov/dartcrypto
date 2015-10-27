library dartcrypto.crypto_utils;

import 'dart:math';

class Matrix {
  int rows;
  int columns;
  int modulo;

  List<List> matrix;

  Matrix.Random(int rows, int columns, [int modulo]) {
    this.rows = rows;
    this.columns = columns;
    if (modulo != null && modulo != 0) this.modulo = modulo;
    Random rand = new Random();
    if (modulo != null && modulo != 0) matrix = new List.generate(
        rows, (i) => new List.generate(columns, (i) => rand.nextInt(modulo)));
    else matrix = new List.generate(
        rows, (i) => new List.generate(columns, (i) => rand.nextInt(1 << 32)));
  }

  Matrix(int rows, int columns, List list, [int modulo]) {
    this.rows = rows;
    this.columns = columns;
    if (modulo != null && modulo != 0) this.modulo = modulo;
    matrix = new List();
    for (int i = 0; i < rows; i++) {
      matrix.add(new List());
      for (int j = 0; j < columns; j++) {
        if (modulo != null && modulo != 0) matrix[i]
            .add(list[i * rows + j] % modulo);
        else matrix[i].add(list[i * rows + j]);
      }
    }
  }

  List operator [](int index) {
    return matrix[index];
  }

  void operator []=(int index, List value) {
    if (value.length != columns)
      throw new ArgumentError.value(value.length, 'value.length', 'Length of row cannot be > than column');
    if (modulo != null && modulo != 0)
      matrix[index] = value.map( (f) => f %= modulo);
    else
      matrix[index] = value;
  }

  int determinant() {
    if (matrix[0].length == 1)
      return matrix[0][0];
    int determinant = 0;
    if (!isSquare()) throw new Exception(
        "Matrix is not square: $rows, $columns");

    if (columns == 2 && rows == 2) {
      determinant = matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];
      if (modulo != null && modulo != 0) return determinant % modulo;
      return determinant;
    } else {
      for (int i = 0; i < columns; i++) {
        determinant = determinant +
            matrix[0][i] * pow(-1, 1 + 1 + i) * minor(0, i).determinant();
      }
    }

    if (modulo != null && modulo != 0) return determinant % modulo;
    return determinant;
  }

  Matrix inverse() {
    if (!isSquare()) throw new Exception(
        "Matrix is not square: $rows, $columns");
    int det = determinant();
    if (det == 0) throw new ArgumentError.value(
        det, 'det', "Matrix has determinant = 0. Cannot find inverse matrix");
    var detm = 0;
    if (modulo != null && modulo != 0) detm = det.modInverse(modulo);
    else detm = 1 / det;

    if (rows == 2 && columns == 2) {
      List list = [
        matrix[1][1] * detm,
        matrix[0][1] * detm * (-1),
        matrix[1][0] * detm * (-1),
        matrix[0][0] * detm
      ];
      if (modulo != null && modulo != 0) list.forEach((f) => f %= modulo);
      return new Matrix(rows, columns, list);
    }

    List list = new List();
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        var el = detm * pow(-1, 1 + j + 1 + i) * minor(i, j).determinant();
        if (modulo != null && modulo != 0) el = el % modulo;
        list.add(el);
      }
    }
    Matrix reverseMatrix = new Matrix(rows, columns, list);
    return reverseMatrix.transpose();
  }

  Matrix transpose() {
    List list = new List();
    for (int i = 0; i < rows; i++) for (int j = 0;
        j < columns;
        j++) list.add(matrix[j][i]);
    return new Matrix(columns, rows, list);
  }

  bool isSquare() {
    if (matrix == null || matrix.isEmpty) return false;
    if (rows != columns) return false;

    return true;
  }

  Matrix minor(int i, int j) {
    List list = new List();
    for (int k = 0; k < rows; k++) for (int l = 0;
        l < columns;
        l++) if (k != i && j != l) list.add(matrix[k][l]);

    Matrix tempMatrix = new Matrix(rows - 1, columns - 1, list);
    return tempMatrix;
  }

  bool isEmpty() {
    if (matrix.isEmpty) return true;
    return matrix[0].isEmpty;
  }

  List toList() {
    List list = new List();
    matrix.forEach((f) => f.forEach((g) => list.add(g)));
    return list;
  }

  String toString() {
    return matrix.toString();
  }
}

String convertToString(List list, [String alphabet]) {
  if (list == null) throw new ArgumentError.notNull('list');
  if (alphabet == null) return new String.fromCharCodes(list);

  String str = '';
  int mod = alphabet.length;
  list.forEach((f) => str += alphabet[f % mod]);
  return str;
}

List convertToList(String str, [String alphabet]) {
  if (str == null) throw new ArgumentError.notNull('str');
  if (alphabet == null) return str.runes.toList();

  int alphabetSize = alphabet.length;
  List list = new List();
  for (int i = 0; i < str.length; i++) for (int j = 0;
      j < alphabetSize;
      j++) if (str[i] == alphabet[j]) list.add(j);
  return list;
}
