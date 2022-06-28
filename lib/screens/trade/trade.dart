import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/trade.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/trade/common/header.dart';
import 'package:lyotrade/screens/trade/common/market_drawer.dart';
import 'package:lyotrade/screens/trade/common/market_margin_drawer.dart';
import 'package:lyotrade/screens/trade/margin/margin_details.dart';
import 'package:lyotrade/screens/trade/margin/margin_open_orders.dart';
import 'package:lyotrade/screens/trade/margin/margin_trade_form.dart';
import 'package:lyotrade/screens/trade/market_header.dart';
import 'package:lyotrade/screens/trade/market_margin_header.dart';
import 'package:lyotrade/screens/trade/open_orders.dart';
import 'package:lyotrade/screens/trade/order_book.dart';
import 'package:lyotrade/screens/trade/trade_form.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Trade extends StatefulWidget {
  static const routeName = '/trade';
  const Trade({Key? key}) : super(key: key);

  @override
  State<Trade> createState() => _TradeState();
}

class _TradeState extends State<Trade> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _channel;

  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  @override
  void initState() {
    connectWebSocket();
    super.initState();
  }

  @override
  void dispose() async {
    if (_channel != null) {
      _channel.sink.close();
    }
    super.dispose();
  }

  Future<void> connectWebSocket() async {
    var public = Provider.of<Public>(context, listen: false);

    _channel = WebSocketChannel.connect(
      Uri.parse('${public.publicInfoMarket["market"]["wsUrl"]}'),
    );

    String marketCoin = public.activeMarket['symbol'];

    _channel.sink.add(jsonEncode({
      "event": "sub",
      "params": {
        "channel": "market_${marketCoin}_depth_step0",
        "cb_id": marketCoin
      }
    }));

    _channel.sink.add(jsonEncode({
      "event": "sub",
      "params": {
        "channel": "market_${marketCoin}_ticker",
        "cb_id": marketCoin,
      }
    }));

    _channel.stream.listen((message) {
      extractStreamData(message, public);
    });
  }

  void extractStreamData(streamData, public) async {
    String marketCoin = public.activeMarket['symbol'];
    if (streamData != null) {
      var inflated = zlib.decode(streamData as List<int>);
      var data = utf8.decode(inflated);
      if (json.decode(data)['channel'] != null) {
        var marketData = json.decode(data);
        if (marketData['channel'] == 'market_${marketCoin}_depth_step0') {
          public.setAsksAndBids(marketData['tick']);
        }
        // if (marketData['channel'] == 'market_${marketCoin}_trade_ticker') {
        //   public.setLastPrice('${marketData['tick']['data'][0]['price']}');
        // }

        if (marketData['channel'] == 'market_${marketCoin}_ticker') {
          public.setActiveMarketTick(marketData['tick'] ?? []);
          public.setLastPrice('${marketData['tick']['close']}');
        }
      }
    }
  }

  void updateMarket() {
    if (_channel != null) {
      _channel.sink.close();
    }
    connectWebSocket();
  }

  Future<void> onTabChange() async {
    var trading = Provider.of<Trading>(context, listen: false);
    if (_tabController.index == 1) {
      var public = Provider.of<Public>(context, listen: false);
      public.setActiveMarket(public.activeMarginMarket);
      updateMarket();
    }
    trading.clearOpenOrders();
    // await trading.getOpenOrders();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var public = Provider.of<Public>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);

    return Scaffold(
      key: _scaffoldKey,
      appBar: appHeader(context, _tabController, onTabChange),
      drawer: _tabController.index == 0
          ? MarketDrawer(
              scaffoldKey: _scaffoldKey,
              updateMarket: updateMarket,
            )
          : MarketMarginDrawer(
              scaffoldKey: _scaffoldKey,
              updateMarket: updateMarket,
            ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                MarketHeader(scaffoldKey: _scaffoldKey),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                      width: width * 0.4,
                      child: OrderBook(
                        asks: public.asks,
                        bids: public.bids,
                        lastPrice: public.lastPrice,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 10),
                      width: width * 0.58,
                      child: TradeForm(
                        scaffoldKey: _scaffoldKey,
                        lastPrice: public.lastPrice,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height,
                  child: OpenOrders(),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                MarketMarginHeader(scaffoldKey: _scaffoldKey),
                MarginDetails(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                      width: width * 0.4,
                      child: OrderBook(
                        asks: public.asks,
                        bids: public.bids,
                        lastPrice: public.lastPrice,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 10),
                      width: width * 0.58,
                      child: MarginTradeForm(
                        scaffoldKey: _scaffoldKey,
                        lastPrice: public.lastPrice,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height,
                  child: MarginOpenOrders(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNav(context, auth),
    );
  }
}