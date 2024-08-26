import 'dart:async';

import 'package:awesome_drawer_bar/awesome_drawer_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:driver/views/pages/order/assigned_orders.page.dart';
import 'package:driver/views/pages/profile/profile.page.dart';
import 'package:driver/views/pages/shared/map_page.dart';
import 'package:driver/views/pages/wallet/earning.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../constants/app_strings.dart';
import '../order/completed_orders.page.dart';
import '../shift/shifts.page.dart';
import 'widgets/home_menu.view.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final awesomeDrawerBarController = AwesomeDrawerBarController();

  bool canCloseApp = false;

  //
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          //
          if (!canCloseApp) {
            canCloseApp = true;
            Timer(const Duration(seconds: 1), () {
              canCloseApp = false;
            });
            //
            Fluttertoast.showToast(
              msg: "Press back again to close".tr(),
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: const Color(0xAA000000),
              textColor: Colors.white,
              fontSize: 14.0,
            );
            return false;
          }
          return true;
        },
        child: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: AppStrings.selectedIndex,
              onTap: (index) {
                setState(() {
                  AppStrings.selectedIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  label: 'home',
                  icon: Image.asset(
                    'assets/images/home.png',
                    height: 60,
                    width: 60,
                  ),
                ),
                BottomNavigationBarItem(
                  label: 'objectives',
                  icon: Image.asset(
                    'assets/images/objectives.png',
                    height: 60,
                    width: 60,
                  ).onInkTap(() {
                    context.nextPage(const ShiftsPage());
                    /*Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );*/
                  }),
                ),
                BottomNavigationBarItem(
                  label: 'money',
                  icon: Image.asset(
                    'assets/images/money.png',
                    height: 60,
                    width: 60,
                  ),
                ),
                BottomNavigationBarItem(
                  label: 'profile',
                  icon: Image.asset(
                    'assets/images/driverman.png',
                    height: 60,
                    width: 60,
                  ).onInkTap(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                    );
                  }),
                ),
              ],
            ),
            body: getMenuPage()));
  }

  Widget getMenuPage() {
    switch (AppStrings.selectedIndex) {
      case 0:
        return MapPage();
      case 2:
        return const EarningPage();
      default:
        return MapPage();
    }
  }

  void openMenuBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return HomeMenuView().h(context.percentHeight * 90);
      },
    );
  }
}

//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _selectedIndex = 0;
//   final List<Widget> _widgetOptions = <Widget>[
//     Container(color: Colors.red),
//     Container(color: Colors.green),
//     Container(color: Colors.blue),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Custom Bottom Navigation Bar'),
//       ),
//       body: Center(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         items: List.generate(
//           4,
//               (index) {
//             if (index == 3) {
//               return BottomNavigationBarItem(
//                 icon: IconButton(
//                   icon: Icon(Icons.add),
//                   onPressed: () {
//                     // Navigate to another screen when the 4th button is tapped
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => ProfilePage()),
//                     );
//                   },
//                 ),
//                 label: 'Add',
//               );
//             }
//             else {
//               return BottomNavigationBarItem(
//                 icon: IconButton(
//                   icon: Icon(Icons.star),
//                   onPressed: () {
//                     // Change the body section for the first 3 bottom tabs
//                     _onItemTapped(index);
//                   },
//                 ),
//                 label: 'Tab $index',
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
