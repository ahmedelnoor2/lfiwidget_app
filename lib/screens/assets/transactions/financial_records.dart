// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:lyotrade/utils/Colors.utils.dart';

// Widget financialRecords(context, width, height, allFinancialRecords) {
//   return Column(
//     children: [
//       SizedBox(
//         height: height * 0.60,
//         width: width,
//         child: ListView.builder(
//           itemCount: allFinancialRecords.length,
//           itemBuilder: (BuildContext context, int index) {
//             var financialRecord = allFinancialRecords[index];
//             return Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SizedBox(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Container(
//                             padding: EdgeInsets.only(left: 15),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Container(
//                                       padding:
//                                           EdgeInsets.only(bottom: 8, right: 5),
//                                       child: Text(
//                                         '${financialRecord['gainCoin']}',
//                                         style: TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     SizedBox(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Container(
//                                             padding: EdgeInsets.only(bottom: 5),
//                                             child: Text(
//                                               'Type',
//                                               style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: secondaryTextColor,
//                                               ),
//                                             ),
//                                           ),
//                                           Container(
//                                             padding: EdgeInsets.only(bottom: 5),
//                                             child: Text(
//                                               'Amount',
//                                               style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: secondaryTextColor,
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             child: Text(
//                                               'Status',
//                                               style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: secondaryTextColor,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Container(
//                             padding: EdgeInsets.only(bottom: 5),
//                             child: Text(
//                               '${DateFormat('yyy-mm-dd hh:mm:ss').format(DateTime.parse('${financialRecord['createTime']}'))}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: secondaryTextColor,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             padding: EdgeInsets.only(bottom: 5),
//                             child: Text(
//                               '${financialRecord['financialType']}',
//                               style:
//                                   TextStyle(fontSize: 12, color: redIndicator),
//                             ),
//                           ),
//                           Container(
//                             padding: EdgeInsets.only(bottom: 5),
//                             child: Row(
//                               children: [
//                                 Text(
//                                   '${financialRecord['amount']}',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             // padding: EdgeInsets.only(right: 20),
//                             child: Text(
//                               '${financialRecord['status']}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//                 Divider(),
//               ],
//             );
//           },
//         ),
//       ),
//     ],
//   );
// }
