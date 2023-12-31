import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Translate.utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GiftCardProvider with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
    'token': '',
    'userId': '',
    'provider': '',
  };
  String paymentstatus = 'Waiting for payment';

  // get provider list

  String _provierid = '';
  String get providerid {
    return _provierid;
  }

  void setproviderid(value) {
    _provierid = value;
    notifyListeners();
  }

  dynamic _giftcardamount;

  dynamic get giftcardamount {
    return _giftcardamount;
  }

  void setgiftcardamount(value) {
    _giftcardamount = value;
    notifyListeners();
  }

  List _allgiftprovider = [];

  List get allgiftprovider {
    return _allgiftprovider;
  }

  Future<void> getAllGiftProvider() async {
    var url = Uri.https(lyoApiUrl, 'gift-card/providers');

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == 200) {
        _allgiftprovider = responseData['data'];
        return notifyListeners();
      } else {
        _allgiftprovider = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);

      return notifyListeners();
    }
  }

  //// Get Wallet//
  List _allwallet = [];

  List get allwallet {
    return _allwallet;
  }

  var walletBalance;

  Future<void> getAllWallet(ctx, auth, userid) async {
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var url = Uri.https(lyoApiUrl, 'gift-card/wallets');

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == 200) {
        _allwallet = [];
        for (var wallet in responseData['data']) {
          _allwallet.add(wallet['coinType']);
          _allwallet.add(wallet['coin']);
        }
        return notifyListeners();
      } else {
        _allwallet = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  Map _toActiveCountry = {};

  Map get toActiveCountry {
    return _toActiveCountry;
  }

  void setActiveCountry(country) {
    _toActiveCountry = country;
    return notifyListeners();
  }

  // Get all countries//

  bool isCountryLoading = false;

  List _allCountries = [];

  List get allCountries {
    return _allCountries;
  }

  Future<void> getAllCountries(ctx, auth, userid) async {
    isCountryLoading = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';
    headers['provider'] = providerid;

    var url = Uri.https(lyoApiUrl, 'gift-card/countries');

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);
      if (responseData['code'] == 200) {
        _allCountries = responseData['data']['countries'];

        _toActiveCountry = responseData['data']['active_country'];

        isCountryLoading = false;
        return notifyListeners();
      } else {
        _allCountries = [];
        isCountryLoading = false;
        return notifyListeners();
      }
    } catch (error) {
      isCountryLoading = false;
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  //// Get All Catalog ///
  Map _toActiveCatalog = {};

  Map get toActiveCatalog {
    return _toActiveCatalog;
  }

  void settActiveCatalog(catlog) {
    _toActiveCatalog = catlog;

    return notifyListeners();
  }

  bool IsCatalogloading = false;

  List _allCatalog = [];

  List get allCatalog {
    return _allCatalog;
  }

  List _sliderlist = [];

  List get sliderlist {
    return _sliderlist;
  }

  Future<void> getAllCatalog(ctx, auth, userid, postdata, catUpdate) async {
    IsCatalogloading = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';
    headers['provider'] = providerid;
    var mydata = json.encode(postdata);
    var url = Uri.https(lyoApiUrl, 'gift-card/catalogues');

    try {
      final response = await http.post(url, body: mydata, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == 200) {
        IsCatalogloading = false;
        _allCatalog = responseData['data'];

        if (_toActiveCatalog.isEmpty) {
          _toActiveCatalog = _allCatalog[0];
        } else if (catUpdate) {
          if (_allCatalog.length > 0) {
            _toActiveCatalog = _allCatalog[0];
          } else {
            _toActiveCatalog = {};
          }
        }

        _sliderlist = _allCatalog.take(5).toList();

        return notifyListeners();
      } else {
        IsCatalogloading = false;
        _allCatalog = [];
        return notifyListeners();
      }
    } catch (error) {
      IsCatalogloading = false;
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  // Get all cards
  bool cardloading = false;

  List _allCard = [];

  List get allCard {
    return _allCard;
  }

  Future<void> getAllCard(
    ctx,
    auth,
    userid,
  ) async {
    cardloading = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';
    headers['provider'] = providerid;

    var countrycode = _toActiveCountry['iso3'] ?? _toActiveCountry['iso2'];
    var catid = _toActiveCatalog['id'];
    var name = _toActiveCatalog['brand'].split(" ")[0];

    var url = Uri.https(
        lyoApiUrl, 'gift-card/cards/$catid/$countrycode', {'name': '$name'});

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == 200) {
        cardloading = false;
        _allCard = responseData['data'];

        return notifyListeners();
      } else {
        cardloading = false;
        _allCard = [];
        return notifyListeners();
      }
    } catch (error) {
      cardloading = false;
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  //// Estimate////

  bool isEstimate = false;

  Map _estimateRate = {};

  Map get estimateRate {
    return _estimateRate;
  }

  Future<void> getEstimateRate(ctx, auth, userid, postdata) async {
    isEstimate = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var mydata = json.encode(postdata);

    var url = Uri.https(lyoApiUrl, 'gift-card/estimate');

    try {
      final response = await http.post(
        url,
        body: mydata,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == 200) {
        isEstimate = false;
        _estimateRate = responseData['data'][0];

        return notifyListeners();
      } else {
        //snackAlert(ctx, SnackTypes.warning, responseData['msg']);
        isEstimate = false;
        _estimateRate = {};

        return notifyListeners();
      }
    } catch (error) {
      isEstimate = false;

      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  /// Otp verification///
  bool _isverify = false;

  bool get isverify {
    return _isverify;
  }

  void setverify(value) {
    _isverify = value;
  }

  //Google code enable//
  bool _isgoogleCode = false;

  bool get isgoogleCode {
    return _isgoogleCode;
  }

  void setgoolgeCode(value) {
    _isgoogleCode = value;
  }

  bool otpverifcation = false;

  var verificationType = '';

  Map _doverify = {};

  Map get doverify {
    return _doverify;
  }

  Future<void> getDoVerify(ctx, auth, userid, postdata) async {
    otpverifcation = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var mydata = json.encode(postdata);

    var url = Uri.https(lyoApiUrl, 'gift-card/send_verification_request');

    try {
      final response = await http.post(
        url,
        body: mydata,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '200') {
        otpverifcation = false;
        _doverify = responseData['data'];

        setverify(true);
        setgoolgeCode(_doverify['googleCode']);

        snackAlert(ctx, SnackTypes.success, responseData['msg']);

        return notifyListeners();
      } else {
        snackAlert(ctx, SnackTypes.warning, responseData['msg']);
        otpverifcation = false;
        _doverify = {};
        return notifyListeners();
      }
    } catch (error) {
      otpverifcation = false;
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  /// withDrawal///

  bool _iswithdrwal = false;
  bool get iswithdrwal {
    return _iswithdrwal;
  }

  Map _dowithdrawal = {};

  Map get dowithdrawal {
    return _dowithdrawal;
  }

  Future<bool> getDoWithDrawal(ctx, auth, userid, postdata) async {
    _iswithdrwal = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';
    var mydata = json.encode(postdata);

    var url = Uri.https(lyoApiUrl, 'gift-card/withdraw');

    try {
      final response = await http.post(
        url,
        body: mydata,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '0' || responseData['code'] == 0) {
        _iswithdrwal = false;
        _dowithdrawal = responseData;
        paymentstatus = 'Card is Processing';

        snackAlert(ctx, SnackTypes.success, responseData['msg']);

        notifyListeners();
        return true;
      } else {
        snackAlert(ctx, SnackTypes.warning, responseData['msg']);
        _iswithdrwal = false;
        _doverify = {};
        notifyListeners();
        return false;
      }
    } catch (error) {
      _iswithdrwal = false;
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      notifyListeners();
      return false;
    }
  }
  //// Do Transaction////

  bool dotransactionloading = false;

  Map _doTransaction = {};

  Map get doTransaction {
    return _doTransaction;
  }

  Future<void> getDoTransaction(ctx, auth, userid, postdata) async {
    dotransactionloading = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var mydata = json.encode(postdata);

    var url = Uri.https(lyoApiUrl, 'gift-card/transaction');

    try {
      final response = await http.post(
        url,
        body: mydata,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '200' || responseData['code'] == 200) {
        dotransactionloading = false;
        _doTransaction = responseData;
        paymentstatus = 'Completed';

        snackAlert(ctx, SnackTypes.success, responseData['msg']);

        return notifyListeners();
      } else {
        snackAlert(ctx, SnackTypes.warning, responseData['msg']);
        dotransactionloading = false;
        _doTransaction = {};
        paymentstatus = 'Failed to process a Gift Card, Please Contact Admin.';
        return notifyListeners();
      }
    } catch (error) {
      dotransactionloading = false;
      paymentstatus = 'Failed to process a Gift Card, Please Contact Admin.';
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  /// Get All Gift Card Transaction ///

  bool istransactionloading = false;

  List _transaction = [];

  List get transaction {
    return _transaction;
  }

  Future<void> getAllTransaction(
    ctx,
    auth,
    userid,
  ) async {
    istransactionloading = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var url = Uri.https(lyoApiUrl, 'gift-card/transaction');

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == '200' || responseData['code'] == 200) {
        istransactionloading = false;
        _transaction = responseData['data'].reversed.toList();

        return notifyListeners();
      } else {
        snackAlert(ctx, SnackTypes.warning, responseData['msg']);
        istransactionloading = false;
        _transaction = [];
        return notifyListeners();
      }
    } catch (error) {
      istransactionloading = false;
      print(error);
      snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  //// get redeem deatils
  bool isredeemloading = false;
  Map _redeem = {};

  Map get redeem {
    return _redeem;
  }

  Future<void> getRedeem(
    ctx,
    auth,
    userid,
    transactionId,
    brandId,
  ) async {
    isredeemloading = true;
    notifyListeners();
    headers['token'] = auth.loginVerificationToken;
    headers['userid'] = '${userid}';

    var url =
        Uri.https(lyoApiUrl, 'gift-card/redeem/${brandId}/${transactionId}');
    print(url);
    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['code'] == 200) {
        _redeem = responseData['data'];
        isredeemloading = false;
        return notifyListeners();
      } else {
        _redeem = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }

  /// Get Account balance //

  Map _accountBalance = {};

  Map get accountBalance {
    return _accountBalance;
  }

  Future<void> getaccountBalance(
    ctx,
    auth,
    userid,
  ) async {
    notifyListeners();

    headers['provider'] = providerid;

    var url = Uri.https(lyoApiUrl, 'gift-card/account/balance');

    try {
      final response = await http.get(url, headers: headers);

      final responseData = json.decode(response.body);

      if (responseData['code'] == 200) {
        _accountBalance = responseData['data'];
        return notifyListeners();
      } else {
        _accountBalance = {};
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return notifyListeners();
    }
  }
}
