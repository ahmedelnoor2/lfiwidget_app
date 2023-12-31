import 'package:flutter/material.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class MarketMarginHeader extends StatefulWidget {
  const MarketMarginHeader({
    Key? key,
    this.scaffoldKey,
  }) : super(key: key);

  final scaffoldKey;

  @override
  State<MarketMarginHeader> createState() => _MarketMarginHeaderState();
}

class _MarketMarginHeaderState extends State<MarketMarginHeader> {
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var public = Provider.of<Public>(context, listen: true);

    return Container(
      padding: EdgeInsets.only(
        top: width * 0.04,
        left: width * 0.04,
        right: width * 0.04,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.sync,
                  size: 20,
                ),
              ),
              InkWell(
                onTap: () {
                  widget.scaffoldKey!.currentState.openDrawer();
                },
                child: Container(
                  padding: EdgeInsets.only(right: 5),
                  child: Text(
                    public.activeMarket['showName'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  public.activeMarketTick.isNotEmpty
                      ? '${(double.parse(public.activeMarketTick['rose']) * 100) > 0 ? '+' : ''}${(double.parse(public.activeMarketTick['rose']) * 100).toStringAsFixed(2)}%'
                      : '0.00%',
                  style: TextStyle(
                      color: public.activeMarketTick.isEmpty
                          ? secondaryTextColor
                          : (double.parse(public.activeMarketTick['rose']) *
                                      100) >
                                  0
                              ? greenIndicator
                              : redIndicator,
                      fontSize: 12),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.only(left: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/kline_chart',
                    );
                  },
                  child: Icon(
                    Icons.candlestick_chart,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  snackAlert(context, SnackTypes.warning, 'Coming Soon...');
                },
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.monetization_on,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  snackAlert(context, SnackTypes.warning, 'Coming Soon...');
                },
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.more_horiz,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
