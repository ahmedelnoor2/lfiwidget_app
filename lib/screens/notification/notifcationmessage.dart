import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/language_provider.dart';
import 'package:lyotrade/providers/notification_provider.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/screens/common/lyo_buttons.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/screens/common/snackalert.dart';
import 'package:lyotrade/screens/notification/widget.dart/notification_detail.dart';
import 'package:lyotrade/screens/notification/widget.dart/painter.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';

import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../common/types.dart';

class Notificationsscreen extends StatefulWidget {
  static const routeName = '/notification_screen';
  const Notificationsscreen({Key? key}) : super(key: key);

  @override
  State<Notificationsscreen> createState() => _NotificationsscreenState();
}

class _NotificationsscreenState extends State<Notificationsscreen>
    with SingleTickerProviderStateMixin {
  String dropdownValue = 'All';

  bool _isselected = false;

  String _messageType = '0';
  var pagesized = 15;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  GlobalKey _contentKey = GlobalKey();
  GlobalKey _refresherKey = GlobalKey();

  @override
  void initState() {
    getnotification();
    super.initState();
  }

  Future<void> getnotification() async {
    var notificationProvider =
        Provider.of<Notificationprovider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    await notificationProvider.getnotification(context, auth, {
      "page": "1",
      "pageSize": "$pagesized",
      "messageType": _messageType,
    });
  }

  Widget build(BuildContext context) {
    var notificationProvider =
        Provider.of<Notificationprovider>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: false);
    var languageprovider = Provider.of<LanguageChange>(context, listen: true);

    return Scaffold(
      appBar: hiddenAppBar(),
      body: SafeArea(
          child: Column(children: [
        Row(
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
               languageprovider.getlanguage['notification']['title']??   'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                InkWell(
                  onTap: (() {
                    _buildBottomSheet(
                      context,
                      notificationProvider,
                      auth,
                      setState,
                    );
                  }),
                  child: Container(
                    height: 50,
                    width: 70,
                    child: Image.asset('assets/img/filter_icon.png'),
                  ),
                ),
              ],
            )
          ],
        ),
        Divider(),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: <Widget>[
                      Checkbox(
                        activeColor: greyDarkTextColor,
                        value: _isselected,
                        onChanged: (value) {
                          setState(() {
                            _isselected = value ?? false;
                            if (_isselected == true) {
                              notificationProvider.userMessageList
                                  .map((e) =>
                                      notificationProvider.selectedItems.add(e))
                                  .toList();
                            } else {
                              notificationProvider.userMessageList
                                  .map((e) => notificationProvider.selectedItems
                                      .remove(e))
                                  .toList();
                            }
                          });
                        },
                      ),
                      Text( languageprovider.getlanguage['notification']['header1']??"Select All"),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () async {
                        await notificationProvider.markAllAsRead(context, auth);
                        getnotification();
                      },
                      child: Text(
                      languageprovider.getlanguage['notification']['read-button']??  'Mark all as read',
                        style: TextStyle(color: linkColor),
                        
                      ),
                    ),
                  ),
                  // Container(
                  //   height: 35,
                  //   width: 50,
                  //   child: Image.asset('assets/img/deleteicon.png'),
                  // ),
                ],
              ),
            ),
          ],
        ),
        notificationProvider.isLoading
            ? Center(child: CircularProgressIndicator())
            : Expanded(
                child: notificationProvider.userMessageList.isEmpty
                    ? Center(
                        child: noData('No messages'),
                      )
                    : SmartRefresher(
                        key: _refresherKey,
                        controller: _refreshController,
                        enablePullDown: false,
                        enablePullUp: true,
                        physics: BouncingScrollPhysics(),
                        footer: ClassicFooter(
                          loadStyle: LoadStyle.ShowWhenLoading,
                          completeDuration: Duration(milliseconds: 500),
                        ),
                        onLoading: (() async {
                          setState(() {
                            pagesized += 10;
                          });
                          return Future.delayed(
                            Duration(seconds: 2),
                            () async {
                              await notificationProvider
                                  .getnotification(context, auth, {
                                "page": "1",
                                "pageSize": "$pagesized",
                                "messageType": _messageType,
                              });

                              if (mounted) setState(() {});
                              _refreshController.loadComplete();
                            },
                          );
                        }),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              notificationProvider.userMessageList.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            
                            var item =
                                notificationProvider.userMessageList[index];
                            return Column(
                              children: [
                                Slidable(
                                  enabled: true,
                                  key: const ValueKey(0),
                                  endActionPane: ActionPane(
                                    extentRatio: 0.2,
                                    motion: ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (c) async {
                                          notificationProvider
                                              .deletebyidnotification(
                                                  context, auth, item['id'])
                                              .whenComplete(() {
                                            setState(() {
                                              notificationProvider
                                                  .getnotification(
                                                      context, auth, {
                                                "page": "1",
                                                "pageSize": "10",
                                                "messageType": _messageType,
                                              });
                                            });
                                          });
                                        },
                                        backgroundColor: Color(0xFFFE4A49),
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Delete',
                                      ),
                                    ],
                                  ),

                                  // The child of the Slidable is what the user sees when the
                                  // component is not dragged.
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Container(
                                      color: (notificationProvider.selectedItems
                                              .contains(item))
                                          ? tileseletedcoloue
                                          : Colors.transparent,
                                      child: ListTile(
                                        onTap: () {
                                          showModalBottomSheet(
                                              isScrollControlled: true,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  5),
                                                          topRight:
                                                              Radius.circular(
                                                                  5))),
                                              context: context,
                                              builder: (context) {
                                                return NotificationDetail(item,getnotification);
                                              });
                                          if (notificationProvider.selectedItems
                                              .contains(item)) {
                                            notificationProvider.selectedItems
                                                .removeWhere(
                                                    (val) => val == item);
                                            notificationProvider
                                                .notifyListeners();
                                          }
                                        },
                                        onLongPress: () {
                                          if (!notificationProvider
                                              .selectedItems
                                              .contains(item)) {
                                            notificationProvider.selectedItems
                                                .add(item);
                                            notificationProvider
                                                .notifyListeners();
                                          }
                                        },
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selectboxcolour,
                                          ),
                                          child: Align(
                                              alignment: Alignment.center,
                                              child: notificationProvider
                                                      .selectedItems
                                                      .contains(item)
                                                  ? Image.asset(
                                                      'assets/img/select.png',
                                                      width: 20,
                                                      fit: BoxFit.fill,
                                                    )
                                                  : Text(
                                                      notificationProvider
                                                                  .userMessageList[
                                                              index]
                                                          ['messageContent'][0],
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: item['status'] ==
                                                                2
                                                            ? seconadarytextcolour
                                                            : Colors.white,
                                                      ),
                                                    )),
                                        ),
                                        title: Text(
                                          notificationProvider
                                              .userMessageList[index]
                                                  ['messageContent']
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: item['status'] == 2
                                                ? secondaryTextColor
                                                : Colors.white,
                                          ),
                                        ),
                                        // subtitle: Text(
                                        //     notificationProvider.userMessageList[index]
                                        //             ['ctime']
                                        //         .toString(),
                                        // style:
                                        //     TextStyle(fontSize: 10, color: natuaraldark)),
                                        trailing: Text(
                                            '${DateFormat('yMMMMd').format(DateTime.fromMillisecondsSinceEpoch(notificationProvider.userMessageList[index]['ctime']))}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: secondaryTextColor,
                                            )),
                                        // trailing: Text(
                                        //     notificationProvider.userMessageList[index]
                                        //             ['ctime']
                                        //         .toString(),
                                        //     style: TextStyle(
                                        //         fontSize: 10, color: natuaraldark)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
              ),
      ])),
    );
  }

  Color getLinkColor(value) {
    var defaultColor = Colors.white;

    if (value == _messageType) {
      defaultColor = linkColor;
    }

    return defaultColor;
  }

  Future _buildBottomSheet(
      BuildContext context, notificationProvider, auth, setState) {
        var languageprovider = Provider.of<LanguageChange>(context, listen: false);
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: bottombuttoncolour,
        context: context,
        builder: (builder) {
          return Container(
            padding: EdgeInsets.only(top: 20),
            color: bottombuttoncolour,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '0';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "0",
                    });
                  },
                  child: Text(
                  languageprovider.getlanguage['notification']['filter']['option1']??  'All Notifications',
                    style: TextStyle(color: getLinkColor('0')),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '1';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "1",
                    });
                  },
                  child: Text(
                    languageprovider.getlanguage['notification']['filter']['option2']??'System MSG',
                    style: TextStyle(color: getLinkColor('1')),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '2';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "2",
                    });
                  },
                  child: Text(
                  languageprovider.getlanguage['notification']['filter']['option3']??  'Deposit/Withdraw',
                    style: TextStyle(color: getLinkColor('2')),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '3';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "3",
                    });
                  },
                  child: Text(
                    languageprovider.getlanguage['notification']['filter']['option4']??'Safety MSG',
                    style: TextStyle(color: getLinkColor('3')),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '4';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "4",
                    });
                  },
                  child: Text(
                   languageprovider.getlanguage['notification']['filter']['option5']?? 'KYC MSG',
                    style: TextStyle(color: getLinkColor('4')),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '7';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "7",
                    });
                  },
                  child: Text(
                 languageprovider.getlanguage['notification']['filter']['option6']??   'OTC message',
                    style: TextStyle(color: getLinkColor('7')),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '8';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "8",
                    });
                  },
                  child: Text(
                languageprovider.getlanguage['notification']['filter']['option7']??    'Mining Pool',
                    style: TextStyle(color: getLinkColor('8')),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _messageType = '9';
                    });
                    Navigator.pop(context);
                    await notificationProvider.getnotification(context, auth, {
                      "page": "1",
                      "pageSize": "10",
                      "messageType": "9",
                    });
                  },
                  child: Text(
                    languageprovider.getlanguage['notification']['filter']['option8']??'Loan MSG',
                    style: TextStyle(color: getLinkColor('9')),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    bottom: 30,
                    left: 15,
                    right: 15,
                  ),
                  child: LyoButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: languageprovider.getlanguage['notification']['filter']['cancel-button']??'Cancel',
                    active: true,
                    isLoading: false,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
