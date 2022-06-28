import 'package:flutter/material.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

appHeader(context, tabController, onTabChange) {
  return AppBar(
    shadowColor: Colors.transparent,
    toolbarHeight: 0,
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(48),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 30,
          child: TabBar(
            onTap: (value) {
              onTabChange();
            },
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            tabs: <Tab>[
              Tab(text: 'Spot'),
              Tab(text: 'Cross Margin'),
            ],
            controller: tabController,
          ),
        ),
      ),
    ),
  );
}

klineHeader(context, scaffoldKey, market) {
  var _currentRoute = ModalRoute.of(context)!.settings.name;

  return AppBar(
    shadowColor: Colors.transparent,
    // toolbarHeight: 1,
    centerTitle: true,
    leading: _currentRoute == '/market'
        ? Container()
        : IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.chevron_left),
          ),
    title: InkWell(
      onTap: () {
        scaffoldKey!.currentState.openDrawer();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(right: 2),
            child: Icon(
              Icons.sync,
              size: 20,
            ),
          ),
          Text(
            '$market',
            style: TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.normal,
            ),
          ),
        ],
      ),
    ),
    actions: [
      IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.star,
          color: secondaryTextColor,
        ),
      )
    ],
  );
}