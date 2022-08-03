import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/referral.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class Myinvitation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyinvitationState();
}

class _MyinvitationState extends State<Myinvitation> {
  @override
  void initState() {
    getMyinvitation();
    super.initState();
  }

  Future<void> getMyinvitation() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var referalprovider = Provider.of<ReferralProvider>(context, listen: false);

    await referalprovider.getmyInvitation(context, auth);
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    var referalprovider = Provider.of<ReferralProvider>(context, listen: true);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 30, left: 16, right: 16, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Friend’s user ID',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
              ),
              Text(
                'Registerred Account',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: referalprovider.isinvitation
              ? SizedBox(
                  height: MediaQuery.of(context).size.height / 1.3,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: referalprovider.invitationlist.length,
                  itemBuilder: (context, index) {
                    return referalprovider.invitationlist.isEmpty? Center(child: noData('No Invitation')): Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 8, bottom: 8),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              referalprovider.invitationlist[index]
                                      ['levelZeroRegisterUid']
                                  .toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  DateFormat('yyy-mm-dd hh:mm:ss').format(DateTime.fromMicrosecondsSinceEpoch(referalprovider.invitationlist[index]['registerTime'])),
                                  
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: natuaraldark,
                                  ),
                                ),
                                Text(
                                  referalprovider.invitationlist[index]['email']
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ]),
                    );
                  }),
        ),
      ],
    );
  }
}
