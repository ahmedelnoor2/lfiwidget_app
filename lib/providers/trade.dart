import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Translate.utils.dart';

class Trading with ChangeNotifier {
  Map<String, String> headers = {
    'Content-type': 'application/json;charset=utf-8',
    'Accept': 'application/json',
  };

  List _openOrders = [];
  List _orderHistory = [];
  List _transactionHistory = [];

  List get openOrders {
    return _openOrders;
  }

  List get orderHistory {
    return _orderHistory;
  }

  List get transactionHistory {
    return _transactionHistory;
  }

  void clearOpenOrders() {
    _openOrders = [];
    notifyListeners();
  }

  Future<void> getOpenOrders(ctx, auth, formData) async {
    /**
     * params:
      "entrust": 1,
      "isShowCanceled": 0,
      "orderType": 1, 1 = Spot and 2 = Margin
      "page": 1,
      "pageSize": 10,
      "symbol": "",
     */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/order/entrust_search',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == 0) {
        _openOrders = responseData['data']['orders'];
        return notifyListeners();
      } else {
        _openOrders = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  Future<void> getOrderHistory(ctx, auth, formData) async {
    /**
     * params:
      "entrust": 2,
      "isShowCanceled": 1,
      "orderType": 1,
      "page": 1,
      "pageSize": 10,
      "symbol": "",
      "status": null,
     */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/order/entrust_search',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (responseData['code'] == 0) {
        _orderHistory = responseData['data']['orders'];
        return notifyListeners();
      } else {
        _orderHistory = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  Future<void> getTransactionHistory(ctx, auth, formData) async {
    /**
     * params:
      "endTime": "",
      "orderType": "1",
      "page": 1,
      "pageSize": 10,
      "startTime": "",
      "symbol": "",
     */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/order/trade_info_search',
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
        _transactionHistory = responseData['data']['list'];

        return notifyListeners();
      } else {
        _transactionHistory = [];
        return notifyListeners();
      }
    } catch (error) {
      print(error);
      // snackAlert(ctx, SnackTypes.errors, 'Failed to update, please try again.');
      return;
    }
  }

  Future<void> createMarginOrder(ctx, auth, formData) async {
    /**
     * params:
      price: "29695.06" (Price only for LIMIT orders null for MARKET)
      side: "BUY" (BUY or SELL)
      symbol: "btcusdt"
      type: 1 = LIMIT and 2 = MARKET
      volume: "1.000000" (Amount)
    */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/lever/order/create',
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
        snackAlert(ctx, SnackTypes.success,
            getTranslate('Order successfully created.'));
        return;
      } else {
        snackAlert(ctx, SnackTypes.errors, getTranslate(responseData['msg']));
        return;
      }
    } catch (error) {
      snackAlert(
        ctx,
        SnackTypes.errors,
        'Error on placing order, please try again',
      );
      return;
      // throw error;
    }
  }

  Future<void> createOrder(ctx, auth, formData) async {
    /**
     * params:
      price: "29695.06" (Price only for LIMIT orders null for MARKET)
      side: "BUY" (BUY or SELL)
      symbol: "btcusdt"
      type: 1 = LIMIT and 2 = MARKET
      volume: "1.000000" (Amount)
    */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/order/create',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      print(responseData);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success,
            getTranslate('Order successfully created.'));
        return;
      } else {
        snackAlert(ctx, SnackTypes.errors, getTranslate(responseData['msg']));
        return;
      }
    } catch (error) {
      snackAlert(
        ctx,
        SnackTypes.errors,
        'Error on placing order, please try again',
      );
      return;
      // throw error;
    }
  }

  Future<void> cancellAllOrders(ctx, auth, formData) async {
    /**
     * params:
      symbol: "btcusdt"
      orderType: 1 = LIMIT and 2 = MARKET
    */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/order/cancel_all',
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
        snackAlert(ctx, SnackTypes.success, getTranslate(responseData['msg']));
        return;
      } else {
        snackAlert(ctx, SnackTypes.errors, getTranslate(responseData['msg']));
        return;
      }
    } catch (error) {
      snackAlert(
        ctx,
        SnackTypes.errors,
        'Error on cancelling orders, please try again',
      );
      return;
      // throw error;
    }
  }

  Future<void> cancelOrder(ctx, auth, formData) async {
    /**
     * params:
      orderId: "34523454654645",
      symbol: "btcusdt"
    */
    headers['exchange-token'] = auth.loginVerificationToken;

    var url = Uri.https(
      apiUrl,
      '$exApi/order/cancel',
    );

    var postData = json.encode(formData);

    try {
      final response = await http.post(
        url,
        body: postData,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      print(responseData);

      if (responseData['code'] == '0') {
        snackAlert(ctx, SnackTypes.success,
            getTranslate('Order successfully cancelled'));
        return;
      } else {
        snackAlert(ctx, SnackTypes.errors, getTranslate(responseData['msg']));
        return;
      }
    } catch (error) {
      snackAlert(
        ctx,
        SnackTypes.errors,
        'Error on cancelling orders, please try again',
      );
      return;
      // throw error;
    }
  }
}
