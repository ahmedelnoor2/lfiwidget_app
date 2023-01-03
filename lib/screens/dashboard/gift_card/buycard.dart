import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/dex_provider.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/dex_swap/common/exchange_now.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/ScreenControl.utils.dart';
import 'package:provider/provider.dart';

class BuyCard extends StatefulWidget {
  static const routeName = '/buy_card';
  const BuyCard(
      {Key? key,
      this.amount,
      this.totalprice,
      this.defaultcoin,
      this.productID})
      : super(key: key);

  final String? amount;
  final double? totalprice;
  final String? defaultcoin;
  final String? productID;

  @override
  State<BuyCard> createState() => _BuyCardState();
}

class _BuyCardState extends State<BuyCard> {
  final _formKey = GlobalKey<FormState>();
  final _optcontroller = TextEditingController();
  final _googlecodecontroller = TextEditingController();
   bool _startTimer = false;
   late Timer _timer;
  int _start = 90;
  @override
  void initState() {
    super.initState();
    changeverifystatus();
  }

  @override
  void dispose() async {
    super.dispose();
  }
  void startTimer(coin) {
    setState(() {
      _startTimer = true;
    });
    optVerify(coin);
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            _startTimer = false;
            _timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future changeverifystatus() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    giftcardprovider.setverify(false);
    giftcardprovider.setgoolgeCode(false);
  }

  Future<void> optVerify(coin) async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];

    await giftcardprovider.getDoVerify(context, auth, userid, {
      "address": "0x11f4D6a5a90d830023E01489D7c74552FC00D1c4",
      "symbol": 'LYO'
    });
  }

  Future<void> withDrawal(coin, amount, verifitypre) async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];

    print(verifitypre);

    await giftcardprovider.getDoWithDrawal(context, auth, userid, {
      "address": "16jSX1dKCc2NAPp3tVxLDff3sh4kTWhfE2",
      "symbol": '$coin',
      "fee": "1",
      "amount": "$amount",
      "verificationType": "$verifitypre",
      "emailValidCode":
          verifitypre == 'emailValidCode' ? _optcontroller.text : "",
      "smsValidCode": verifitypre == 'smsValidCode' ? _optcontroller.text : "",
      "googleCode": _googlecodecontroller.text
    });
  }

  Future<void> dotransaction(productid, amount) async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];

    await giftcardprovider.getDoTransaction(context, auth, userid, {
      "productID": "$productid",
      "amount": "$amount",
      "firstName": "Ivan",
      "lastName": "Begumisa",
      "email": "i.b@lyopay.com",
      "orderId": "0213457",
      "quantity": " 1"
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var giftcardprovider = Provider.of<GiftCardProvider>(context, listen: true);
    final args = ModalRoute.of(context)!.settings.arguments as BuyCard;

    print(giftcardprovider.isverify);
    // print(args.productID);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.chevron_left),
          ),
          title: Text(
            'Buy Card',
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: 10,
                ),
                padding: EdgeInsets.only(bottom: 10),
                child: Text(giftcardprovider.paymentstatus ==
                                  'Waiting for payment'
                              ? 'Waiting for payment'
                              : giftcardprovider.paymentstatus ==
                                      'Card is Processing'
                                  ? 'Card is Processing'
                                  :'Waiting for payment',),
              ),
              Container(
                margin: EdgeInsets.only(left: 8, right: 16, bottom: 15),
                child: Stack(
                  children: [
                    Container(
                      width: width,
                      height: 16,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 0.5),
                          color: Colors.white),
                      child: Container(),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 0.5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        child: Container(
                          width: giftcardprovider.paymentstatus ==
                                  'Waiting for payment'
                              ? width * 0.3
                              : giftcardprovider.paymentstatus ==
                                      'Card is Processing'
                                  ? width * 0.5
                                  : width * 0.3,
                          // width: dexPro

                          height: 15,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.green.shade500,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Container(
                        padding: EdgeInsets.only(top: 20, bottom: 5),
                        child: Text(
                          '${double.parse(args.totalprice.toString()).toStringAsPrecision(7)}' +
                              ' ' +
                              args.defaultcoin.toString(),
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        )),
                    Container(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Text('Amount')),
                  ],
                ),
              ),
              Card(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          'Payment',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          args.amount.toString() +
                              ' ' +
                              giftcardprovider.toActiveCountry['currency']
                                  ['code'],
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _optcontroller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Code';
                            }

                            return null;
                          },
                          onChanged: ((value) {}),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 0.5,
                                  color: secondaryTextColor400), //<-- SEE HERE
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: secondaryTextColor400, width: 0.5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            hintText: 'Please Enter Code',
                            suffixIcon: InkWell(
                              onTap:_startTimer
                                ? null
                                : () {
                                    setState(() {
                                      _start = 90;
                                    });
                                    startTimer(args.defaultcoin);
                                  }, 
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 15,
                                    right: 10,
                                  ),
                                  child:Text(_startTimer
                                ? '${_start}s Get it again'
                                : 'Click to send'),
                                  ),
                                ),
                              ),
                            ),
                            // errorText: _errorText,
                          ),
                      
                        SizedBox(
                          height: 20,
                        ),
                        giftcardprovider.isgoogleCode == true
                            ? TextFormField(
                                controller: _googlecodecontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Google Code';
                                  }

                                  return null;
                                },
                                onChanged: ((value) {}),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 0.5,
                                        color:
                                            secondaryTextColor400), //<-- SEE HERE
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: secondaryTextColor400,
                                        width: 0.5),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  hintText: 'Please Google Code',

                                  // errorText: _errorText,
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  giftcardprovider.isverify == true
                      ? Container(
                          padding: EdgeInsets.only(top: 50, right: 4, left: 4),
                          child: LyoButton(
                            onPressed: (() async {
                              if (_formKey.currentState!.validate()) {
                                await withDrawal(
                                    args.defaultcoin,
                                    args.totalprice,
                                    giftcardprovider
                                        .doverify['verificationType']);
                              }
                            }),
                            text: 'Buy Now',
                            active: true,
                            isLoading: giftcardprovider.iswithdrwal,
                            activeColor: linkColor,
                            activeTextColor: Colors.black,
                          ),
                        )
                      : Container()
                ],
              ),
            ],
          ),
        ));
  }
}
