class GraphApiException implements Exception {
  String error;

  GraphApiException(this.error);

  @override
  String toString() {
    return error;
  }
}
