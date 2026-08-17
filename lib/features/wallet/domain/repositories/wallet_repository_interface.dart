import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class WalletRepositoryInterface<T> extends RepositoryInterface {
  // Future<dynamic> getWalletTransactionList(int offset, String types, String startDate, String endDate, String filterByType);

  Future<dynamic> addFundToWallet(String amount, String paymentMethod);

  Future<dynamic> getLocalWalletMethods();

  Future<dynamic> getLocalWalletTopUpRequests({int? offset = 1});

  Future<dynamic> createLocalWalletTopUpRequest({
    required int methodId,
    required String amount,
  });

  Future<dynamic> confirmLocalWalletTopUpRequest({
    required int requestId,
    required String transactionId,
    String? payerPhone,
    String? customerNote,
  });

  Future<dynamic> getWalletBonusBannerList();

  @override
  Future<dynamic> getList(
      {int? offset = 1,
      String? filterBy,
      DateTime? startDate,
      DateTime? endDate,
      List<String>? transactionTypes});
}
