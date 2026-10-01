class ResponseModel {
  final bool _isSuccess;
  final String? _message;
  final String? approvalStatus;
  final String? reviewNote;

  ResponseModel(this._isSuccess, this._message, {this.approvalStatus, this.reviewNote});

  String? get message => _message;
  bool get isSuccess => _isSuccess;
}