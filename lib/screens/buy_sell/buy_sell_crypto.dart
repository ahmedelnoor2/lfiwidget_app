import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/buy_sell/common/crypto_coin_drawer.dart';
import 'package:lyotrade/screens/buy_sell/common/fiat_coin_drawer.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

import 'package:flutter_svg/flutter_svg.dart';

class BuySellCrypto extends StatefulWidget {
  static const routeName = '/buy_sell_crypto';
  const BuySellCrypto({Key? key}) : super(key: key);

  @override
  State<BuySellCrypto> createState() => _BuySellCryptoState();
}

class _BuySellCryptoState extends State<BuySellCrypto> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fiatController = TextEditingController();
  final TextEditingController _cryptoController = TextEditingController();

  bool _loadingCoins = false;
  String _defaultNetwork = '';
  String _currentAddress = '';

  @override
  void initState() {
    getCurrencies();
    super.initState();
  }

  @override
  void dispose() async {
    _fiatController.dispose();
    _cryptoController.dispose();
    super.dispose();
  }

  Future<void> getDigitalBalance() async {
    var payments = Provider.of<Payments>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    await asset.getAccountBalance(context, auth, "");
    if (public.publicInfoMarket['market']['followCoinList']
            [payments.selectedCryptoCurrency['current_ticker'].toUpperCase()] !=
        null) {
      public.publicInfoMarket['market']['followCoinList']
              [payments.selectedCryptoCurrency['current_ticker'].toUpperCase()]
          .forEach((k, v) {
        if (payments.selectedCryptoCurrency['network'].toUpperCase() ==
            v['tokenBase']) {
          setState(() {
            _defaultNetwork = '${v['name']}';
          });
        }
      });
    }

    if (_defaultNetwork.isNotEmpty) {
      await asset.getChangeAddress(context, auth, _defaultNetwork);
      if (asset.changeAddress['addressStr'] != null) {
        setState(() {
          _currentAddress = asset.changeAddress['addressStr'];
        });
      }
    }
  }

  Future<void> estimateCrypto(payments) async {
    var auth = Provider.of<Auth>(context, listen: false);
    await payments.getEstimateRate(context, auth, {
      'from_currency': payments.selectedFiatCurrency['ticker'],
      'from_amount': _fiatController.text,
      'to_currency': payments.selectedCryptoCurrency['current_ticker'],
      'to_network': payments.selectedCryptoCurrency['network'],
      'to_amount': _cryptoController.text,
    });
    getDigitalBalance();
    return;
  }

  Future<void> getCurrencies() async {
    setState(() {
      _fiatController.text = '1500';
      _cryptoController.text = '1';
      _loadingCoins = true;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var payments = Provider.of<Payments>(context, listen: false);

    await payments.getFiatCurrencies(context, auth);
    await payments.getCryptoCurrencies(context, auth);
    await estimateCrypto(payments);
    if (payments.estimateRate.isNotEmpty) {
      setState(() {
        _cryptoController.text = payments.estimateRate['value'];
      });
    }
    getDigitalBalance();
    setState(() {
      _loadingCoins = false;
    });
  }

  Future<void> processBuy() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var payments = Provider.of<Payments>(context, listen: false);

    await payments.createTransaction(context, auth, {
      'from_currency': payments.selectedFiatCurrency['ticker'],
      'from_amount': _fiatController.text,
      'to_currency': payments.selectedCryptoCurrency['current_ticker'],
      'to_network': payments.selectedCryptoCurrency['network'],
      'to_amount': payments.estimateRate['value'],
      'payout_address': _currentAddress,
      'deposit_type': 'SEPA_2',
      'payout_type': 'CRYPTO_THROUGH_CN',
    });

    if (payments.changenowTransaction.isNotEmpty) {
      if (payments.changenowTransaction['redirect_url'] != null) {
        Navigator.pushNamed(context, '/process_payment');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var payments = Provider.of<Payments>(context, listen: true);

    return Scaffold(
      appBar: hiddenAppBar(),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.chevron_left),
                          ),
                        ),
                        Text(
                          'Buy Crypto',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.history),
                    )
                  ],
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xff292C51),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        style: BorderStyle.solid,
                        width: 0.3,
                        color: Color(0xff5E6292),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                SizedBox(
                                  width: width * 0.5,
                                  child: TextFormField(
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        if (double.parse(value) > 50) {
                                          estimateCrypto(payments);
                                        }
                                      }
                                    },
                                    controller: _fiatController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    style: const TextStyle(fontSize: 22),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      hintStyle: TextStyle(
                                        fontSize: 22,
                                      ),
                                      hintText: "0.00",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: width * 0.30,
                              child: InkWell(
                                onTap: () {
                                  showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return Scaffold(
                                            appBar:
                                                hiddenAppBarWithDefaultHeight(),
                                            body: selectFiatCoin(
                                              context,
                                              setState,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 10),
                                      child: CircleAvatar(
                                        radius: 14,
                                        child: payments
                                                .selectedFiatCurrency.isNotEmpty
                                            ? SvgPicture.network(
                                                '$changeNowApi${payments.selectedFiatCurrency['icon']['url']}',
                                                width: 50,
                                              )
                                            : Container(),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(right: 10),
                                      child: payments
                                              .selectedFiatCurrency.isNotEmpty
                                          ? Text(
                                              '${payments.selectedFiatCurrency['ticker'].toUpperCase()}',
                                              style: TextStyle(fontSize: 16),
                                            )
                                          : Container(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'To',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                payments.estimateLoader
                                    ? const CircularProgressIndicator.adaptive()
                                    : Text(
                                        '${payments.estimateRate.isNotEmpty ? payments.estimateRate['value'] : 0.00}',
                                        style: TextStyle(fontSize: 22),
                                      ),
                              ],
                            ),
                            SizedBox(
                              width: width * 0.30,
                              child: InkWell(
                                onTap: () {
                                  showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return Scaffold(
                                            appBar:
                                                hiddenAppBarWithDefaultHeight(),
                                            body: selectCryptoCoin(
                                              context,
                                              setState,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 10),
                                      child: CircleAvatar(
                                        radius: 14,
                                        child: payments.selectedCryptoCurrency
                                                .isNotEmpty
                                            ? SvgPicture.network(
                                                '$changeNowApi${payments.selectedCryptoCurrency['icon']['url']}',
                                                width: 50,
                                              )
                                            : Container(),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(right: 10),
                                      child: payments
                                              .selectedCryptoCurrency.isNotEmpty
                                          ? Text(
                                              '${payments.selectedCryptoCurrency['current_ticker'].toUpperCase()}',
                                              style: TextStyle(fontSize: 16),
                                            )
                                          : Container(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estimated rate',
                        style: TextStyle(
                          color: secondaryTextColor,
                        ),
                      ),
                      payments.estimateRate.isEmpty
                          ? Container()
                          : Text(
                              '1 ${payments.selectedCryptoCurrency['current_ticker'].toUpperCase()} ~ ${(double.parse(_fiatController.text) / double.parse(payments.estimateRate['value'])).toStringAsFixed(4)} ${payments.selectedFiatCurrency['ticker'].toUpperCase()}'),
                    ],
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                processBuy();
              },
              child: Container(
                width: width,
                padding: EdgeInsets.only(
                  top: 10,
                  right: 10,
                  left: 10,
                  bottom: 30,
                ),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // color: Color(0xff5E6292),
                    color: payments.estimateLoader
                        ? Color(0xff292C51)
                        : Color(0xff5E6292),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      // style: BorderStyle.solid,
                      width: 0,
                      // color: Color(0xff5E6292),
                      color: payments.estimateLoader
                          ? Colors.transparent
                          : Color(0xff5E6292),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Buy',
                      style: TextStyle(
                        fontSize: 15,
                        color: payments.estimateLoader
                            ? secondaryTextColor
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget selectFiatCoin(context, setState) {
    return FiatCoinDrawer(
      fiatController: _fiatController,
    );
  }

  Widget selectCryptoCoin(context, setState) {
    return CryptoCoinDrawer(
      fiatController: _fiatController,
      getDigitalBalance: getDigitalBalance,
    );
  }
}
