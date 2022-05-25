import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/bottomnav.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/trade/common/header.dart';
import 'package:lyotrade/screens/trade/common/market_drawer.dart';
import 'package:lyotrade/screens/trade/market_header.dart';
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
    // for (int i = 0; i < public.headerSymbols.length; i++) {
    //   _channel.sink.add(jsonEncode({
    //     "event": "sub",
    //     "params": {
    //       "channel": "market_${marketCoin}_trade_ticker",
    //       "cb_id": marketCoin,
    //       "top": 100
    //     }
    //   }));
    // }
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

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var public = Provider.of<Public>(context, listen: true);

    return Scaffold(
      key: _scaffoldKey,
      appBar: appHeader(context, _tabController),
      drawer: MarketDrawer(
        scaffoldKey: _scaffoldKey,
        updateMarket: updateMarket,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MarketHeader(scaffoldKey: _scaffoldKey),
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                    width: width * 0.45,
                    child: OrderBook(
                      asks: public.asks,
                      bids: public.bids,
                      lastPrice: public.lastPrice,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    width: width * 0.5,
                    child: TradeForm(
                      scaffoldKey: _scaffoldKey,
                      lastPrice: public.lastPrice,
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: SizedBox(
                height: height,
                child: OpenOrders(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNav(context),
    );
  }
}
