import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/assets/skeleton/deposit_skull.dart';
import 'package:lyotrade/screens/common/drawer.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/common/types.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Coins.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

import 'package:screenshot/screenshot.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class DepositAssets extends StatefulWidget {
  static const routeName = '/deposit_assets';
  const DepositAssets({Key? key}) : super(key: key);

  @override
  State<DepositAssets> createState() => _DepositAssetsState();
}

class _DepositAssetsState extends State<DepositAssets> {
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loadingAddress = false;
  String _defaultNetwork = 'USDTBSC';
  String _defaultCoin = 'USDT';
  List _allNetworks = [];
  Image? _qrCode;
  bool _tagType = false;

  @override
  void initState() {
    getDigitalBalance();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadQrCode() async {
    var asset = Provider.of<Asset>(context, listen: false);

    setState(() {
      _qrCode = Image.memory(
        base64Decode(
          asset.changeAddress['addressQRCode']
              .split(',')[1]
              .replaceAll("\n", ""),
        ),
      );
    });
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
      _loadingAddress = true;
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
        if (v['followCoinDepositOpen'] == 1) {
          setState(() {
            _allNetworks.add(v);
            _defaultCoin = netwrkType;
            _defaultNetwork = '${v['name']}';
          });

          if (v['tagType'] == 0) {
            print(v['tagType']);
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
      print('check....');
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
      });
    }

    await asset.getCoinCosts(auth, _defaultNetwork);
    await asset.getChangeAddress(context, auth, _defaultNetwork);

    List _digitialAss = [];
    asset.accountBalance['allCoinMap'].forEach((k, v) {
      if (v['depositOpen'] == 1) {
        _digitialAss.add({
          'coin': k,
          'values': v,
        });
      }
    });
    loadQrCode();

    setState(() {
      _loadingAddress = false;
    });
    asset.setDigAssets(_digitialAss);
  }

  Future<void> share(title, text) async {
    await FlutterShare.share(
      title: '$title',
      text: '$text',
    );
  }

  Future<void> captureScreen() async {
    screenshotController.capture().then((image) async {
      final String dir = (await getApplicationDocumentsDirectory()).path;
      final String fullPath = '$dir/${DateTime.now().millisecond}.png';
      File capturedFile = File(fullPath);
      await capturedFile.writeAsBytes(image!);

      GallerySaver.saveImage(capturedFile.path).then((path) {
        // print('saved');
      });
    }).catchError((onError) {
      // print(onError);
    });
  }

  Future<void> changeCoinType(netwrk) async {
    setState(() {
      _loadingAddress = true;
    });
    if (netwrk['tagType'] == 0) {
      print(netwrk['tagType']);
      setState(() {
        _tagType = false;
      });
    } else {
      setState(() {
        _tagType = true;
      });
    }
    var auth = Provider.of<Auth>(context, listen: false);
    var asset = Provider.of<Asset>(context, listen: false);

    setState(() {
      _defaultNetwork = netwrk['name'];
    });
    await asset.getCoinCosts(auth, netwrk['name']);
    await asset.getChangeAddress(context, auth, netwrk['name']);

    loadQrCode();
    setState(() {
      _loadingAddress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var asset = Provider.of<Asset>(context, listen: true);
    var public = Provider.of<Public>(context, listen: true);
    var languageprovider = Provider.of<LanguageChange>(context, listen: true);

    return Scaffold(
      key: _scaffoldKey,
      appBar: hiddenAppBar(),
      drawer: drawer(
        context,
        width,
        height,
        asset,
        public,
        _searchController,
        getCoinCosts,
        null,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            right: 15,
            left: 15,
            bottom: 15,
          ),
          child: Screenshot(
            controller: screenshotController,
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 20),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.chevron_left),
                              ),
                            ),
                            Text(
                         languageprovider.getlanguage['deposit_detail']['title'] ??    'Deposit',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/transactions');
                          },
                          icon: Icon(Icons.history),
                        )
                      ],
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
                                  '${getCoinName(_defaultCoin)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${public.publicInfoMarket['market']['coinList'][_defaultCoin]['showName']}',
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
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Text(languageprovider.getlanguage['deposit_detail']['cname']??'Chain name'),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.help_outline,
                            size: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Text('Fee:'),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Text(
                            '${asset.getCost['defaultFee']}',
                            style: TextStyle(
                              color: linkColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Text(getCoinName(_defaultCoin)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    height: 45,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _allNetworks.length,
                        itemBuilder: (BuildContext context, int index) {
                          var network = _allNetworks[index];
                          return GestureDetector(
                            onTap: () async {
                              changeCoinType(network);

                              ///  getDigitalBalance();
                            },
                            child: Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: (network['name'] == _defaultNetwork)
                                      ? Color(0xff01FEF5)
                                      : Color(0xff5E6292),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Container(
                                  width: 62,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${network['mainChainName']}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                            languageprovider.getlanguage['deposit_detail']['deposit_addr']??  'Deposit Address',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                style: BorderStyle.solid,
                                width: 0.3,
                                color: Color(0xff5E6292),
                              ),
                            ),
                            width: width * 0.45,
                            height: width * 0.45,
                            child: _loadingAddress
                                ? depositQrSkull(context)
                                : (asset.changeAddress['addressQRCode'] !=
                                            null &&
                                        _qrCode != null)
                                    ? _qrCode
                                    : const CircularProgressIndicator
                                        .adaptive(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: Text(languageprovider.getlanguage['deposit_detail']['wallet_addr']?? 'Wallet Address:'),
                  ),
                  Container(
                    width: width,
                    padding: EdgeInsets.only(
                      top: 5,
                      bottom: 5,
                    ),
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: _defaultNetwork == 'XRP'
                                ? asset.changeAddress['addressStr']
                                    .split('_')[0]
                                : asset.changeAddress['addressStr'],
                          ),
                        );
                        snackAlert(context, SnackTypes.success, 'Copied');
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            style: BorderStyle.solid,
                            width: 0.3,
                            color: Color(0xff5E6292),
                          ),
                        ),
                        child: _loadingAddress
                            ? depositAddressSkull(context)
                            : Row(
                                children: [
                                  SizedBox(
                                    width: width * 0.8,
                                    child: Text(
                                      '${_defaultNetwork == 'XRP' ? asset.changeAddress['addressStr'].split('_')[0] : asset.changeAddress['addressStr']}',
                                      style: TextStyle(
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: _defaultNetwork == 'XRP'
                                              ? asset
                                                  .changeAddress['addressStr']
                                                  .split('_')[0]
                                              : asset
                                                  .changeAddress['addressStr'],
                                        ),
                                      );
                                      snackAlert(context, SnackTypes.success,
                                          'Copied');
                                    },
                                    child: Image.asset(
                                      'assets/img/copy.png',
                                      width: 18,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  ///Tag memo
                  _tagType == false
                      ? Container()
                      : _loadingAddress
                          ? CircularProgressIndicator()
                          : Container(
                              padding: EdgeInsets.only(
                                top: 10,
                                bottom: 10,
                              ),
                              child: Text('Tag(Memo)'),
                            ),
                  _tagType == false
                      ? Container()
                      : _loadingAddress
                          ? Container()
                          : Container(
                              width: width,
                              padding: EdgeInsets.only(
                                top: 5,
                                bottom: 5,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                        text: asset.changeAddress['addressStr']
                                            .split('_')[1]),
                                  );
                                  snackAlert(
                                      context, SnackTypes.success, 'Copied');
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      style: BorderStyle.solid,
                                      width: 0.3,
                                      color: Color(0xff5E6292),
                                    ),
                                  ),
                                  child: _loadingAddress
                                      ? depositAddressSkull(context)
                                      : Row(
                                          children: [
                                            SizedBox(
                                              width: width * 0.8,
                                              child: Text(
                                                asset
                                                    .changeAddress['addressStr']
                                                    .split('_')[1],
                                                style: TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                      text: asset.changeAddress[
                                                              'addressStr']
                                                          .split('_')[1]),
                                                );
                                                snackAlert(
                                                    context,
                                                    SnackTypes.success,
                                                    'Copied');
                                              },
                                              child: Image.asset(
                                                'assets/img/copy.png',
                                                width: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),

                  // //
                  // _defaultNetwork == 'XRP'
                  //     ? Container(
                  //         width: width,
                  //         height: height * 0.09,
                  //         padding: EdgeInsets.only(
                  //           top: 5,
                  //           bottom: 5,
                  //         ),
                  //         child: Row(mainAxisAlignment: MainAxisAlignment.start,
                  //           children: [
                  //             Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text('Tag(Memo'),
                  //                 Container(
                  //                   padding: EdgeInsets.all(10),
                  //                   decoration: BoxDecoration(
                  //                     border: Border.all(
                  //                       style: BorderStyle.solid,
                  //                       width: 0.3,
                  //                       color: Color(0xff5E6292),
                  //                     ),
                  //                   ),
                  //                   child: _loadingAddress
                  //                       ? depositAddressSkull(context)
                  //                       : Row(
                  //                           children: [
                  //                             SizedBox(
                  //                               width: width * 0.8,
                  //                               child: Text(
                  //                                 '${_defaultNetwork == 'XRP' ? asset.changeAddress['addressStr'].split('_')[1] : asset.changeAddress['addressStr']}',
                  //                               ),
                  //                             ),
                  //                             GestureDetector(
                  //                               onTap: () {
                  //                                 Clipboard.setData(
                  //                                   ClipboardData(
                  //                                     text: _defaultNetwork == 'XRP'
                  //                                         ? asset.changeAddress[
                  //                                                 'addressStr']
                  //                                             .split('_')[1]
                  //                                         : asset.changeAddress[
                  //                                             'addressStr'],
                  //                                   ),
                  //                                 );
                  //                                 snackAlert(context,
                  //                                     SnackTypes.success, 'Copied');
                  //                               },
                  //                               child: Image.asset(
                  //                                 'assets/img/copy.png',
                  //                                 width: 18,
                  //                               ),
                  //                             ),
                  //                           ],
                  //                         ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ],
                  //         ),
                  //       )
                  //     : Container(),
                  Container(
                    padding: EdgeInsets.only(
                      top: 20,
                      bottom: 10,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                           languageprovider.getlanguage['deposit_detail']['bal']??      'Balance',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${asset.accountBalance['allCoinMap'] != null ? asset.accountBalance['allCoinMap'][_defaultCoin]['total_balance'] : '--'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                               languageprovider.getlanguage['deposit_detail']['available']??    'Available',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${asset.accountBalance['allCoinMap'] != null ? asset.accountBalance['allCoinMap'][_defaultCoin]['normal_balance'] : '--'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                              languageprovider.getlanguage['deposit_detail']['freeze']??     'Freeze',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${asset.accountBalance['allCoinMap'] != null ? asset.accountBalance['allCoinMap'][_defaultCoin]['lock_balance'] : '--'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  kIsWeb
                      ? Container()
                      : Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            // padding: const EdgeInsets.all(40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: width * 0.44,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      captureScreen();
                                      snackAlert(context, SnackTypes.success,
                                          'Address saved to Gallery or Photos.');
                                    },
                                    child:  Text(languageprovider.getlanguage['deposit_detail']['save_btn']??'Save Address'),
                                  ),
                                ),
                                SizedBox(
                                  width: width * 0.44,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      share(
                                        '${asset.getCost['withdrawLimitSymbol']} Address',
                                        asset.changeAddress['addressStr'],
                                      );
                                    },
                                    child:  Text(languageprovider.getlanguage['deposit_detail']['share_btn']??'Share Address'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
