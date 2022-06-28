import 'package:flutter/material.dart';
import 'package:lyotrade/providers/future_market.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:lyotrade/utils/Number.utils.dart';
import 'package:provider/provider.dart';

class FutureOrderBook extends StatefulWidget {
  const FutureOrderBook({
    Key? key,
    this.asks,
    this.bids,
    this.lastPrice,
  }) : super(key: key);
  final List? asks;
  final List? bids;
  final String? lastPrice;

  @override
  State<FutureOrderBook> createState() => _FutureOrderBookState();
}

class _FutureOrderBookState extends State<FutureOrderBook> {
  // void setPriceField(public, value) {
  //   public.setAmountField(value);
  // }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    var futureMarket = Provider.of<FutureMarket>(context, listen: true);

    List? rasks = widget.asks!.isNotEmpty ? widget.asks!.sublist(0, 6) : [];
    List? asks = List.from(rasks.reversed);
    List? bids = widget.bids!.isNotEmpty ? widget.bids!.sublist(0, 6) : [];

    var bidMax = bids.isNotEmpty
        ? (bids.reduce((current, next) =>
            double.parse('${current[1]}') > double.parse('${next[1]}')
                ? current
                : next)[1])
        : 0;
    var askMax = asks.isNotEmpty
        ? (asks.reduce((current, next) =>
            double.parse('${current[1]}') > double.parse('${next[1]}')
                ? current
                : next)[1])
        : 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  'Price',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '(${futureMarket.activeMarket['quote']})',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  'Amount',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '(${futureMarket.activeMarket['base']})',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: asks.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                // setPriceField(public, asks[index][0]);
              },
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(
                      top: 1,
                      bottom: 1,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          double.parse('${asks[index][0]}')
                              .toStringAsPrecision(7),
                          style: TextStyle(
                            color: redIndicator,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          double.parse('${asks[index][1]}') > 10
                              ? double.parse('${asks[index][1]}')
                                  .toStringAsFixed(2)
                              : double.parse('${asks[index][1]}')
                                  .toStringAsPrecision(4),
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      color: Color.fromARGB(73, 175, 86, 76),
                      width: ((double.parse('${asks[index][1]}') /
                                  double.parse('$askMax')) *
                              2) *
                          100,
                      height: 21,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              double.parse('${widget.lastPrice}').toStringAsPrecision(7),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              '≈ ${getNumberFormat(context, double.parse(widget.lastPrice ?? '0'))}',
              style: TextStyle(fontSize: 12, color: secondaryTextColor),
            ),
          ],
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: bids.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                // setPriceField(public, bids[index][0]);
              },
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(
                      top: 1,
                      bottom: 1,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          double.parse('${bids[index][0]}')
                              .toStringAsPrecision(7),
                          style: TextStyle(
                            color: greenIndicator,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          double.parse('${bids[index][1]}') > 10
                              ? double.parse('${bids[index][1]}')
                                  .toStringAsFixed(2)
                              : double.parse('${bids[index][1]}')
                                  .toStringAsPrecision(4),
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      color: Color.fromARGB(71, 72, 163, 65),
                      width: ((double.parse('${bids[index][1]}') /
                                  double.parse('$bidMax')) *
                              2) *
                          100,
                      height: 21,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Container(
          padding: EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  print('Select preceision');
                },
                child: Container(
                  width: width * 0.31,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(67, 118, 118, 118),
                    ),
                    color: Color.fromARGB(67, 118, 118, 118),
                    borderRadius: BorderRadius.all(
                      Radius.circular(2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          '0.1',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      Icon(
                        Icons.expand_more,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  print('Select preceision');
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(67, 118, 118, 118),
                    ),
                    color: Color.fromARGB(67, 118, 118, 118),
                    borderRadius: BorderRadius.all(
                      Radius.circular(2),
                    ),
                  ),
                  child: Icon(
                    Icons.dashboard,
                    color: secondaryTextColor,
                    size: 19,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}