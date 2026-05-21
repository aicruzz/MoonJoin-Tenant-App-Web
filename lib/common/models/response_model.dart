class ResponseModel {
  final bool isSuccess;
  final String message;
  final dynamic data;

  ResponseModel(this.isSuccess, this.message, [this.data]);
}
