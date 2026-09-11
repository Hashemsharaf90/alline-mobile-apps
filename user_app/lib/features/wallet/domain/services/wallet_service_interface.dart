abstract class WalletServiceInterface {
  // Future<dynamic> getWalletTransactionList(int offset, String types, String startDate, String endDate, String filterByType);

  Future<dynamic> addFundToWallet(String amount, String paymentMethod);

  Future<dynamic> getLocalWalletMethods();

  Future<dynamic> getLocalWalletTopUpRequests({int? offset = 1});

  Future<dynamic> createLocalWalletTopUpRequest({
    required int methodId,
    required String amount,
    String? transactionId,
    String? payerPhone,
    String? customerNote,
  });

  Future<dynamic> confirmLocalWalletTopUpRequest({
    required int requestId,
    required String transactionId,
    String? payerPhone,
    String? customerNote,
  });

  Future<dynamic> getWalletBonusBannerList();

  Future<dynamic> getList(
      {int? offset = 1,
      String? filterBy,
      DateTime? startDate,
      DateTime? endDate,
      List<String>? transactionTypes});
}
