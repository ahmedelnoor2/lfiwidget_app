import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/trade.dart';
import 'package:lyotrade/screens/trade/common/percentage_indicator.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/ScreenControl.utils.dart';
import 'package:provider/provider.dart';

class OpenOrders extends StatefulWidget {
  const OpenOrders({Key? key}) : super(key: key);

  @override
  State<OpenOrders> createState() => _OpenOrdersState();
}

class _OpenOrdersState extends State<OpenOrders>
    with SingleTickerProviderStateMixin {
  late final TabController _tabOpenOrderController =
      TabController(length: 2, vsync: this);

  bool _hideOtherPairs = false;

  @override
  void initState() {
    getOpenOrders();
    getfunds();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getfunds() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var public = Provider.of<Public>(context, listen: false);
    var trading = Provider.of<Trading>(context, listen: false);

    if (auth.isAuthenticated) {
      await trading.getFunds(context, auth, {
        "coinSymbols": public.activeMarket['name']
            .replaceAll(new RegExp(r"\p{P}", unicode: true), ","),
      });
    }
  }

  String getOrderType(orderType) {
    return '$orderType' == '1' ? 'Limit' : 'Market';
  }

  Future<void> getOpenOrders() async {
    var trading = Provider.of<Trading>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);

    if (auth.isAuthenticated) {
      await trading.getOpenOrders(context, auth, {
        "entrust": 1,
        "isShowCanceled": 0,
        "orderType": 1,
        "page": 1,
        "pageSize": 10,
        "symbol": "",
      });
    }
  }

  Future<void> cancelOrder(formData) async {
    var trading = Provider.of<Trading>(context, listen: false);

    var auth = Provider.of<Auth>(context, listen: false);

    await trading.cancelOrder(
      context,
      auth,
      formData,
    );
    getOpenOrders();
  }

  Future<void> cancelAllOrders() async {
    var trading = Provider.of<Trading>(context, listen: false);

    var auth = Provider.of<Auth>(context, listen: false);

    await trading.cancellAllOrders(context, auth, {
      "orderType": "1",
      "symbol": "",
    });
    getOpenOrders();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var auth = Provider.of<Auth>(context, listen: true);
    var trading = Provider.of<Trading>(context, listen: true);
    var public = Provider.of<Public>(context, listen: true);
    var languageprovider = Provider.of<LanguageChange>(context, listen: true);

    return Column(
      children: [
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                // height: 100,
                width: width * 0.5,
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.label,
                  isScrollable: true,
                  onTap: (value) => setState(() {
                    // _tabIndicatorColor = value == 0 ? Colors.green : Colors.red;
                  }),
                  tabs: <Tab>[
                    Tab(text: 'Open Orders(${trading.openOrders.length})'),
                    Tab(
                        text: languageprovider.getlanguage['trade']['funds']
                                ['title'] ??
                            'Funds'),
                  ],
                  controller: _tabOpenOrderController,
                ),
              ),
              IconButton(
                onPressed: () {
                  auth.isAuthenticated
                      ? Navigator.pushNamed(context, '/trade_history')
                      : Navigator.pushNamed(context, '/authentication');
                },
                icon: Icon(
                  Icons.insert_drive_file,
                  color: secondaryTextColor400,
                ),
              )
            ],
          ),
        ),
        Divider(height: 0),
        Expanded(
          // width: width,
          // height: height,
          child: TabBarView(
            controller: _tabOpenOrderController,
            children: [
              Container(
                child: auth.isAuthenticated
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 10),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _hideOtherPairs = !_hideOtherPairs;
                                          });
                                        },
                                        child: Icon(
                                          Icons.check_circle,
                                          color: _hideOtherPairs
                                              ? greenIndicator
                                              : secondaryTextColor400,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    Text('Hide Other Pairs'),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    cancelAllOrders();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 12, right: 12, top: 6, bottom: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xff292C51),
                                      ),
                                      color: Color(0xff292C51),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(2),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel All',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 0),
                          (trading.openOrders.length <= 0)
                              ? noData()
                              : openOrderList(
                                  context, trading.openOrders, trading, auth),
                        ],
                      )
                    : noAuth(context),
              ),
              //auth.isAuthenticated ? noData() : noAuth(context),
              auth.isAuthenticated
                  ? SizedBox(
                      height: height * 0.5,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Text(
                                  'Current active pair',
                                  style: TextStyle(color: greyTextColor),
                                )
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              trading.isfundsLoading
                                  ? CircularProgressIndicator()
                                  : Container(
                                      child: ListTile(
                                        leading: ClipOval(
                                          child: public.publicInfoMarket[
                                                          'market']['coinList'][
                                                      '${public.activeMarket['name'].split('/')[0]}'] !=
                                                  null
                                              ? Image.network(
                                                  public.publicInfoMarket[
                                                          'market']['coinList'][
                                                          '${public.activeMarket['name'].split('/')[0]}']
                                                          ['icon']
                                                      .toString(),
                                                  width: width * 0.09,
                                                  height: width * 0.09,
                                                  fit: BoxFit.fill,
                                                )
                                              : Container(),
                                        ),
                                        trailing: Text(
                                          trading.funds['allCoinMap'][
                                                      '${public.activeMarket['name'].split('/')[0]}'] !=
                                                  null
                                              ? trading.funds['allCoinMap'][
                                                      '${public.activeMarket['name'].split('/')[0]}']
                                                      ['normal_balance']
                                                  .toString()
                                              : '',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        title: Text(
                                          '${public.activeMarket['showName'].split('/')[0]}'
                                              .toString(),
                                        ),
                                        subtitle: Text(
                                          public.publicInfoMarket['market']
                                                          ['coinList'][
                                                      public
                                                          .activeMarket['name']
                                                          .split('/')[0]] !=
                                                  null
                                              ? '${public.publicInfoMarket['market']['coinList'][public.activeMarket['name'].split('/')[0]]['longName']}'
                                              : '',
                                        ),
                                      ),
                                    ),
                              trading.isfundsLoading
                                  ? Container()
                                  : Container(
                                      child: ListTile(
                                        leading: ClipOval(
                                          child: Image.network(
                                            public.publicInfoMarket['market']
                                                    ['coinList'][
                                                    '${public.activeMarket['showName'].split('/')[1]}']
                                                    ['icon']
                                                .toString(),
                                            width: width * 0.09,
                                            height: width * 0.09,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        trailing: Text(
                                          trading.funds['allCoinMap'][
                                                      '${public.activeMarket['showName'].split('/')[1]}']
                                                  ['normal_balance'] ??
                                              ''.toString(),
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        title: Text(
                                          '${public.activeMarket['showName'].split('/')[1]}'
                                              .toString(),
                                        ),
                                        subtitle: Text(
                                          '${public.publicInfoMarket['market']['coinList'][public.activeMarket['name'].split('/')[1]]['longName']}',
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        ],
                      ),
                    )
                  : noAuth(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget noData() {
    return Container(
      padding: EdgeInsets.only(top: 50),
      child: Column(
        children: [
          Icon(
            Icons.folder_off,
            size: 50,
            color: secondaryTextColor,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Text(
              'No Data',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget openOrderList(context, openOrders, trading, auth) {
    var public = Provider.of<Public>(context, listen: true);
    return Container(
      padding: EdgeInsets.all(15),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: openOrders.length,
        itemBuilder: (BuildContext context, int index) {
          var openOrder = openOrders[index];
          double filledVolume = double.parse(openOrder['volume']) -
              double.parse(openOrder['remain_volume']);
          var orderFilled = filledVolume * 100;

          if (_hideOtherPairs) {
            if (openOrder['symbol'] ==
                public.activeMarket['symbol'].toUpperCase()) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: width * 0.65,
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '${getOrderType(openOrder['type'])}/${openOrder['side']}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: openOrder['side'] == 'BUY'
                                          ? greenIndicator
                                          : redIndicator,
                                    ),
                                  ),
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: secondaryTextColor400,
                                          width: 4,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        // shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$orderFilled%',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.only(left: 20, top: 20),
                                      child: SemiCircleWidget(
                                        diameter: 0,
                                        sweepAngle:
                                            (100.0).clamp(0.0, orderFilled),
                                        color: greenIndicator,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      '${openOrder['symbol']}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsets.only(right: 20),
                                              child: Text(
                                                'Amount',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  EdgeInsets.only(right: 20),
                                              child: Text(
                                                'Price',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsets.only(right: 20),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '${double.parse(openOrder['remain_volume']).toStringAsFixed(4)} / ',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${double.parse(openOrder['volume']).toStringAsFixed(4)}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: secondaryTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  EdgeInsets.only(right: 20),
                                              child: Text(
                                                '${double.parse(openOrder['price']).toStringAsPrecision(6)}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Text(
                                '${DateFormat('yyy-mm-dd hh:mm:ss').format(DateTime.parse('${openOrder['created_at']}'))}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                cancelOrder({
                                  "orderId": openOrder['id'],
                                  "symbol": openOrder['symbol'].toLowerCase(),
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 12, right: 12, top: 6, bottom: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xff292C51),
                                  ),
                                  color: Color(0xff292C51),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(2),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Divider(),
                ],
              );
            } else {
              return Container();
            }
          } else {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: width * 0.65,
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '${getOrderType(openOrder['type'])}/${openOrder['side']}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: openOrder['side'] == 'BUY'
                                        ? greenIndicator
                                        : redIndicator,
                                  ),
                                ),
                              ),
                              Stack(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: secondaryTextColor400,
                                        width: 4,
                                      ),
                                      borderRadius: BorderRadius.circular(100),
                                      // shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$orderFilled%',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 20, top: 20),
                                    child: SemiCircleWidget(
                                      diameter: 0,
                                      sweepAngle:
                                          (100.0).clamp(0.0, orderFilled),
                                      color: greenIndicator,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    '${openOrder['symbol']}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(right: 20),
                                            child: Text(
                                              'Amount',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(right: 20),
                                            child: Text(
                                              'Price',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(right: 20),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${double.parse(openOrder['remain_volume']).toStringAsFixed(4)} / ',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                Text(
                                                  '${double.parse(openOrder['volume']).toStringAsFixed(4)}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: secondaryTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(right: 20),
                                            child: Text(
                                              '${double.parse(openOrder['price']).toStringAsPrecision(6)}',
                                              style: TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              '${DateFormat('yyy-mm-dd hh:mm:ss').format(DateTime.parse('${openOrder['created_at']}'))}',
                              style: TextStyle(
                                fontSize: 11,
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              // cancelAllOrders();
                              cancelOrder({
                                "orderId": openOrder['id'],
                                "symbol": openOrder['symbol'].toLowerCase(),
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 12, right: 12, top: 6, bottom: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xff292C51),
                                ),
                                color: Color(0xff292C51),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Divider(),
              ],
            );
          }
        },
      ),
    );
  }
}
