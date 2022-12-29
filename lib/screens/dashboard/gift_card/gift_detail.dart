import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/giftcard.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/drawer.dart';

import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class GiftDetail extends StatefulWidget {
  static const routeName = '/gift_detail';
  const GiftDetail({Key? key}) : super(key: key);

  @override
  State<GiftDetail> createState() => _GiftDetailState();
}

class _GiftDetailState extends State<GiftDetail> {
  String _defaultCoin = 'USDT';
  double _selectedPercentage = 0;
  List _allNetworks = [];
  String _defaultNetwork = 'USDTBSC';
  String _coinShowName = 'EUSDT';
  double? estimateprice;
  double estprice = 0.0;

  final TextEditingController _searchController = TextEditingController();
  bool _tagType = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _amountcontroller = TextEditingController();
  @override
  void initState() {
    super.initState();
    getDigitalBalance();
  }

  Future<void> getDigitalBalance() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    if (asset.selectedAsset.isNotEmpty) {
      setState(() {
        _defaultCoin =
            '${public.publicInfoMarket['market']['coinList'][asset.selectedAsset['coin']]['name']}';
      });
    }
    await asset.getAccountBalance(context, auth, "");
    getCoinCosts(_defaultCoin);
  }

  Future<void> getCoinCosts(netwrkType) async {
    setState(() {
      _defaultCoin = netwrkType;
    });
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);

    if (public.publicInfoMarket['market']['followCoinList'][netwrkType] !=
        null) {
      setState(() {
        _allNetworks.clear();
      });

      public.publicInfoMarket['market']['followCoinList'][netwrkType]
          .forEach((k, v) {
        if (v['followCoinWithdrawOpen'] == 1) {
          setState(() {
            _allNetworks.add(v);
            _defaultCoin = netwrkType;
            _defaultNetwork = '${v['name']}';
            _coinShowName = '${v['name']}';
          });

          if (v['tagType'] == 0) {
            setState(() {
              _tagType = false;
            });
          } else {
            setState(() {
              _tagType = true;
            });
          }
        }
      });
    } else {
      if (public.publicInfoMarket['market']['coinList'][netwrkType]
              ['tagType'] ==
          0) {
        print(public.publicInfoMarket['market']['coinList'][netwrkType]
            ['tagType']);
        setState(() {
          _tagType = false;
        });
      } else {
        setState(() {
          _tagType = true;
        });
      }
      setState(() {
        _allNetworks.clear();
        _allNetworks
            .add(public.publicInfoMarket['market']['coinList'][netwrkType]);
        _defaultCoin = netwrkType;
        _defaultNetwork =
            '${public.publicInfoMarket['market']['coinList'][netwrkType]['name']}';
        _coinShowName =
            '${public.publicInfoMarket['market']['coinList'][netwrkType]['name']}';
      });
    }

    await asset.getCoinCosts(auth, _coinShowName);
    // await asset.getChangeAddress(context, auth, _defaultCoin);

    List _digitialAss = [];
    asset.accountBalance['allCoinMap'].forEach((k, v) {
      if (v['depositOpen'] == 1) {
        _digitialAss.add({
          'coin': k,
          'values': v,
        });
      }
    });
    asset.setDigAssets(_digitialAss);
  }

  Future<void> dotransaction() async {
    var giftcardprovider =
        Provider.of<GiftCardProvider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    var userid = await auth.userInfo['id'];

    await giftcardprovider.getDoTransaction(context, auth, userid, {
      "productID": "15009",
      "amount": "1.0",
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
    var asset = Provider.of<Asset>(context, listen: true);
    var public = Provider.of<Public>(context, listen: true);

    print(public.rate[public.activeCurrency['fiat_symbol'].toUpperCase()]
        [_defaultCoin]);

    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    return Scaffold(
      key: _scaffoldKey,
      drawer: drawer(
        context,
        width,
        height,
        asset,
        public,
        _searchController,
        getCoinCosts,
      ),
      appBar: hiddenAppBar(),
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/giftbg.png"),
                fit: BoxFit.cover,
              ),
            ),
            height: height * 0.20,
            child: Column(
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
                          'Gift Detail',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  child: Column(
                    children: [
                      Text(
                        arguments['data']['name'] ?? '',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text('Receive a reward of up to x times your entry fee!'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.topCenter,
              fit: StackFit.loose,
              children: <Widget>[
                Container(
                  height: height * 0.75,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Color(0xff25284A),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 80,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            child: Row(children: [
                              Text(
                                'Buy',
                              ),
                            ]),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _scaffoldKey.currentState!.openDrawer();
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                style: BorderStyle.solid,
                                width: 0.3,
                                color: Color(0xff5E6292),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 10),
                                      child: CircleAvatar(
                                        radius: 12,
                                        child: Image.network(
                                          '${public.publicInfoMarket['market']['coinList'][_defaultCoin]['icon']}',
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Text(
                                        '$_defaultCoin',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${public.publicInfoMarket['market']['coinList'][_defaultCoin]['longName']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.keyboard_arrow_down),
                              ],
                            ),
                            height: 60,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Container(
                            child: Row(children: [
                              Text(
                                'Amount',
                              ),
                            ]),
                          ),
                        ),
                        TextFormField(
                          controller: _amountcontroller,
                          onChanged: ((value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                estprice = double.parse(value);
                                var finalprice = estprice /
                                    public.rate[public
                                        .activeCurrency['fiat_symbol']
                                        .toUpperCase()][_defaultCoin];
                                estimateprice = finalprice;
                              });
                            } else {
                              estimateprice = 0.0;
                            }
                          }),
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
                            hintText: 'Amount',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Wallet Balance',
                                  style:
                                      TextStyle(color: secondaryTextColor400),
                                ),
                                Text(asset.accountBalance['totalBalance']
                                    .toString())
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Estimated Rate',
                                  style:
                                      TextStyle(color: secondaryTextColor400),
                                ),
                                Text(estimateprice.toString())
                              ]),
                        ),
                        arguments['data']['is_a_range']
                            ? Container(
                                padding: EdgeInsets.only(bottom: 30),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Min price: ${arguments['data']['min']}'),
                                    Text(
                                        'Min price: ${arguments['data']['max']}'),
                                  ],
                                ),
                              )
                            : Container(),
                        LyoButton(
                          onPressed: (() async {
                            Navigator.pushNamed(context,'/buy_card');
                           // dotransaction();
                          }),
                          text: 'Buy Now',
                          active: true,
                          isLoading: giftcardprovider.dotransactionloading,
                          activeColor: linkColor,
                          activeTextColor: Colors.black,
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                    top: -50,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            giftcardprovider.toActiveCatalog['card_image']
                                .toString(),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      height: 120,
                      width: 200,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
