import 'dart:convert';

import 'package:cached_memory_image/cached_memory_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:lyotrade/providers/payments.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class OnramperFiatCoins extends StatefulWidget {
  const OnramperFiatCoins({Key? key}) : super(key: key);

  @override
  State<OnramperFiatCoins> createState() => _OnramperFiatCoinsState();
}

class _OnramperFiatCoinsState extends State<OnramperFiatCoins>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var payments = Provider.of<Payments>(context, listen: true);

    return Container(
      height: height,
      padding: EdgeInsets.only(
        top: 10,
        right: 10,
        left: 10,
        bottom: 30,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select a currency from',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  size: 20,
                ),
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
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 15),
                    child: Icon(
                      Icons.search,
                      size: 15,
                      color: secondaryTextColor,
                    ),
                  ),
                  SizedBox(
                    width: width * 0.75,
                    child: TextFormField(
                      controller: _searchController,
                      onChanged: ((value) {
                        payments.runFilter(value);
                      }),
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(
                          fontSize: 15,
                        ),
                        hintText: "Type a currency",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: payments.onrampfoundlist.isNotEmpty
                ? Stack(
                    children: [
                      ListView.builder(
                        // shrinkWrap: true,
                        itemCount: payments.onrampfoundlist.length,
                        itemBuilder: (context, index) {
                          var _fiatCurrency = payments.onrampfoundlist[index];

                          return Column(
                            children: [
                              ListTile(
                                onTap: () async {
                                  // changeFiatCoin(payments, _fiatCurrency);
                                  payments.setSelectedOnrampFiatCurrency(
                                      _fiatCurrency);
                                  // payments.getOnRamperDetails(context);
                                  await payments
                                      .getOnrampEstimateRate(context, {
                                    "fromCurrency": payments
                                        .selectedOnrampFiatCurrency['code'],
                                    "toCurrency": payments
                                        .selectedOnrampCryptoCurrency['code'],
                                    "paymentMethod":
                                        payments.selectedpaymentmethod,
                                    "amount": payments.amount
                                  });
                                  Navigator.pop(context);
                                },
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: CachedMemoryImage(
                                    uniqueKey: _fiatCurrency.toString(),
                                    base64: payments.onRamperDetails['icons']
                                            [_fiatCurrency['code']]['icon']
                                        .split(',')[1]
                                        .replaceAll("\n", ""),
                                  ),
                                ),
                                title: Text(
                                  '${_fiatCurrency['code'].toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  '${_fiatCurrency['code']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ),
                              Divider(),
                            ],
                          );
                        },
                      ),
                      payments.isLoadingEstimate
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container()
                    ],
                  )
                : Align(
                    alignment: Alignment.topCenter,
                    child: const Text(
                      'No results found',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
