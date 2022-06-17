import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';

import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Translate.utils.dart';

class Asset with ChangeNotifier {
  Map _accountBalance = {};
  Map _p2pBalance = {};
  Map _marginBalance = {};
  Map _totalAccountBalance = {};
  Map _getCost = {};
  Map _changeAddress = {};
  List _digitialAss = [];
  List _allDigAsset = [];
  List _depositLists = [];
  List _withdrawLists = [];
  List _p2pLists = [];
  List _marginLoanLists = [];
  List _marginHistoryLists = [];
  List _marginTransferLists = [];
  List _financialRecords = [];
  bool _hideBalances = false;
  final String _hideBalanceString = '******';

  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'exchange-token': '',
  };

  Map get accountBalance {
    return _accountBalance;
  }

  Map get p2pBalance {
    return _p2pBalance;
  }

  Map get marginBalance {
    return _marginBalance;
  }

  Map get totalAccountBalance {
    return _totalAccountBalance;
  }

  Map get getCost {
    return _getCost;
  }

  Map get changeAddress {
    return _changeAddress;
  }

  List get digitialAss {
    return _digitialAss;
  }

  List get allDigAsset {
    return _allDigAsset;
  }

  bool get hideBalances {
    return _hideBalances;
  }

  String get hideBalanceString {
    return _hideBalanceString;
  }

  List get depositLists {
    return _depositLists;
  }

  List get withdrawLists {
    return _withdrawLists;
  }

  List get p2pLists {
    return _p2pLists;
  }

  List get marginLoanLists {
    return _marginLoanLists;
  }

  List get marginHistoryLists {
    return _marginHistoryLists;
  }

  List get marginTransferLists {
    return _marginTransferLists;
  }

  List get financialRecords {
    return _financialRecords;
  }

  void toggleHideBalances(value) {
    _hideBalances = value;
    notifyListeners();
  }

  void setDigAssets(digAsset) {
    _digitialAss = digAsset;
    notifyListeners();
  }

  Future<void> filterSearchResults(query) async {
    if (query.isNotEmpty) {
      List dummyListData = [];
      for (var item in _digitialAss) {
        if (item['coin'].contains(query)) {
          if (item['values']['depositOpen'] == 1) {
            dummyListData.add(item);
          }
          notifyListeners();
        }
      }
      _allDigAsset.clear();
      _allDigAsset.addAll(dummyListData);
      return;
    } else {
      _allDigAsset.clear();
      _allDigAsset.addAll(_digitialAss);
      notifyListeners();
      return;
    }
  }

  Future<void> getTotalBalance(auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/finance/total_account_balance',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _totalAccountBalance = responseData['data'];
      } else {
        _totalAccountBalance = {};
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getAccountBalance(ctx, auth, coinSymbols) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/finance/v5/account_balance',
    );

    var postData = json.encode({coinSymbols: coinSymbols});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _accountBalance = responseData['data'];
      } else if (responseData['code'] == "10002") {
        snackAlert(
            ctx, SnackTypes.warning, 'Session Expired, Please login back');
      } else {
        _accountBalance = {};
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getP2pBalance(ctx, auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/finance/v4/otc_account_list',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _p2pBalance = responseData['data'];
      } else if (responseData['code'] == "10002") {
        snackAlert(
            ctx, SnackTypes.warning, 'Session Expired, Please login back');
        Navigator.pushNamed(ctx, '/authentication');
      } else {
        _p2pBalance = {};
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getMarginBalance(auth) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/lever/finance/balance',
    );

    var postData = json.encode({});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _marginBalance = responseData['data'];
      } else {
        _marginBalance = {};
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  // Get Marging Symbol Balance
  Map _marginSymbolBalance = {};

  Map get marginSymbolBalance {
    return _marginSymbolBalance;
  }

  Future<void> getMarginSymbolBalance(auth, symbol) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/lever/finance/symbol/balance',
    );

    var postData = json.encode({'symbol': symbol});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _marginSymbolBalance = responseData['data'];
      } else {
        _marginSymbolBalance = {};
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getCoinCosts(auth, coin) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/cost/Getcost',
    );

    var postData = json.encode({"symbol": coin});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _getCost = responseData['data'];
      } else if (responseData['code'] == '10002') {
        _getCost = {};
      } else {
        _getCost = {};
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getChangeAddress(ctx, auth, coin) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/finance/get_charge_address',
    );

    var postData = json.encode({"symbol": coin});

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _changeAddress = responseData['data'];
      } else {
        _changeAddress = {};
        snackAlert(ctx, SnackTypes.errors, responseData['msg']);
        auth.checkResponseCode(ctx, responseData['code']);
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getDepositTransactions(auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/record/deposit_list',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _depositLists = responseData['data']['financeList'];
      } else {
        _depositLists = [];
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getWithdrawTransactions(auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/record/withdraw_list',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _withdrawLists = responseData['data']['financeList'];
      } else {
        _withdrawLists = [];
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getP2pTransactions(auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/record/otc_transfer_list',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _p2pLists = responseData['data']['financeList'];
      } else {
        _p2pLists = [];
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> borrowMarginWallet(ctx, auth, formData) async {
    /*
    * Params
      amount: "2"
      coin: "USDT"
      symbol: "BTCUSDT"
    */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/lever/finance/borrow',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success, 'Borrow successful');
      } else if (responseData['code'] == 10002) {
        snackAlert(ctx, SnackTypes.warning, 'Please login to access');
      } else {
        snackAlert(ctx, SnackTypes.errors, '${responseData['msg']}');
      }
    } catch (error) {
      snackAlert(ctx, SnackTypes.errors, 'Server error, please try again');
      // throw error;
    }
  }

  Future<void> getMarginLoanTransactions(auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/lever/borrow/new',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _marginLoanLists = responseData['data']['financeList'];
      } else {
        _marginLoanLists = [];
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getMarginHistoryTransactions(auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/lever/borrow/history',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _marginHistoryLists = responseData['data']['financeList'];
      } else {
        _marginHistoryLists = [];
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getMarginTransferTransactions(auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/lever/finance/transfer/list',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _marginTransferLists = responseData['data']['financeList'];
      } else {
        _marginTransferLists = [];
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> getFinancialRecords(auth, formData) async {
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$incrementApi/increment/financial_management',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        _financialRecords = responseData['data']['financeList'];
      } else {
        _financialRecords = [];
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      // throw error;
    }
  }

  Future<void> makeOtcTransfer(ctx, auth, formData) async {
    /*
    * Params
      amount: "1"
      coinSymbol: "LYO1"
      fromAccount: "1" 1 = Digital Account
      toAccount: "2" 2 = P2P Account 
    */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/finance/otc_transfer',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success, 'Transfer successful');
      } else if (responseData['code'] == 10002) {
        snackAlert(ctx, SnackTypes.warning, 'Please login to access');
      } else {
        snackAlert(ctx, SnackTypes.errors, '${responseData['msg']}');
      }
    } catch (error) {
      snackAlert(ctx, SnackTypes.errors, 'Server error, please try again');
      // throw error;
    }
  }

  Future<void> makeMarginTransfer(ctx, auth, formData) async {
    /*
    * Params
      amount: "1"
      coinSymbol: "USDT"
      fromAccount: "1" 1 = Digital Account
      symbol: "btcusdt"
      toAccount: "2" 2 = Margin Account
    */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/lever/finance/transfer',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0') {
        if (responseData['msg'] == 'Failure to transfer leveraged funds！') {
          snackAlert(ctx, SnackTypes.errors, '${responseData['msg']}');
        } else if (responseData['msg'] == 'Insufficient Balance') {
          snackAlert(ctx, SnackTypes.errors, 'Insufficient Balance');
        } else {
          snackAlert(ctx, SnackTypes.success, 'Transfer Successful');
        }
      } else if (responseData['code'] == 10002) {
        snackAlert(ctx, SnackTypes.warning, 'Please login to access');
      } else {
        snackAlert(ctx, SnackTypes.errors, '${responseData['msg']}');
      }
    } catch (error) {
      snackAlert(ctx, SnackTypes.errors, 'Server error, please try again');
      // throw error;
    }
  }
}
