import 'package:flutter/material.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/user.dart';

import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

import 'package:provider/provider.dart';

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool _payWithLyoCred = false;

  @override
  void initState() {
    checkFeeCoinStatus();
    super.initState();
  }

  void checkFeeCoinStatus() {
    var auth = Provider.of<Auth>(context, listen: false);
    if (auth.userInfo.isNotEmpty) {
      setState(() {
        _payWithLyoCred = auth.userInfo['useFeeCoinOpen'] == 1 ? true : false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    var public = Provider.of<Public>(context, listen: true);
    var auth = Provider.of<Auth>(context, listen: true);
    var user = Provider.of<User>(context, listen: true);

    return SizedBox(
      width: width,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: width * 0.46,
              child: DrawerHeader(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    auth.userInfo.isEmpty
                        ? ListTile(
                            onTap: () {
                              Navigator.pushNamed(context, '/authentication');
                            },
                            leading: const CircleAvatar(
                              child: Icon(Icons.account_circle),
                            ),
                            title: const Text(
                              'Login',
                              style: TextStyle(fontSize: 20),
                            ),
                            subtitle: const Text('Welcome to LYOTrade'),
                            trailing: const Icon(
                              Icons.chevron_right,
                            ),
                          )
                        : ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              '${auth.userInfo['userAccount']}',
                              style: const TextStyle(fontSize: 20),
                            ),
                            subtitle: Text(
                              'Account Status: ${auth.userInfo['accountStatus'] == 0 ? 'Normal' : '-'}',
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('Referral Program'),
                subtitle: Text(
                  'Refer friends and get rewards',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                trailing: Icon(
                  Icons.star_border_outlined,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      if (auth.isAuthenticated) {
                        Navigator.pushNamed(context, '/transactions');
                      } else {
                        Navigator.pushNamed(context, '/authentication');
                      }
                    },
                    leading: const Icon(Icons.list_alt),
                    title: const Text('History'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    leading: const Icon(Icons.percent),
                    title: const Text('Trading Fee Level'),
                    trailing: Text(
                      'Current Level: ${auth.userInfo['accountStatus'] ?? '--'}',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.percent),
                    title: const Text('Pay with your LYO Credit'),
                    subtitle: Text(
                      'Used as an exchange market, trading currency unit',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Switch(
                      value: auth.userInfo.isEmpty ? false : _payWithLyoCred,
                      onChanged: (val) async {
                        if (auth.isAuthenticated) {
                          setState(() {
                            _payWithLyoCred = val;
                          });
                          await user.toggleFeeCoinOpen(
                              context, auth, val ? 1 : 0);
                          await auth.getUserInfo();
                        } else {
                          Navigator.pushNamed(context, '/authentication');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Security'),
                    trailing: Text(
                      'Payment and Password',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      if (auth.isAuthenticated) {
                        Navigator.pushNamed(context, '/security');
                      } else {
                        Navigator.pushNamed(context, '/authentication');
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: const Text('Currency'),
                    trailing: DropdownButton<String>(
                      icon: Container(),
                      isDense: true,
                      underline: Container(),
                      value: public.activeCurrency['fiat_symbol'],
                      // icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      onChanged: (newCurrency) async {
                        await public.changeCurrency(newCurrency);
                        await public.assetsRate();
                      },
                      items: public.currencies
                          .map<DropdownMenuItem<String>>((currency) {
                        return DropdownMenuItem<String>(
                          value: currency['fiat_symbol'],
                          child: Text(
                            '${currency['fiat_icon']} ${currency['fiat_symbol'].toUpperCase()}',
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                ],
              ),
            ),
            auth.userInfo.isNotEmpty
                ? SizedBox(
                    width: width * 0.5,
                    child: ElevatedButton(
                      onPressed: () {
                        auth.logout(context);
                      },
                      child: const Text(
                        'Logout',
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}