import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import 'package:bhu/view/auth/signin.dart';
import 'package:bhu/view/chat/chat.dart';
import 'package:bhu/view/notification/notification.dart';
import 'package:bhu/view/home/home.dart';
import 'package:bhu/view/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;

import '../forms/opd_visit.dart';
import '../forms/patient_registration.dart';
import '../forms/prescription_form.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int currentPageIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: whiteColor,
        centerTitle: false,
        leading: IconButton.filledTonal(
          style: IconButton.styleFrom(backgroundColor: greyColor),
          onPressed: () => currentPageIndex == 0
              ? _scaffoldKey.currentState!.openDrawer()
              : setState(() {
                  currentPageIndex = 0;
                }),
          icon: currentPageIndex == 0
              ? const Icon(Icons.menu)
              : const Icon(IconlyLight.arrowLeft2),
        ),
        title: currentPageIndex == 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "HI, Doctor 👋🏾",
                    style: descriptionTextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        size: 12),
                  ),
                  Text("Basic Health Unit Management",
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              )
            : currentPageIndex == 1
                ? Text(
                    "Patient Registration",
                    style: titleTextStyle(),
                  )
                : currentPageIndex == 2
                    ? Text(
                        "OPD Visit",
                        style: titleTextStyle(),
                      )
                    : currentPageIndex == 3
                        ? Text(
                            "Prescriptions",
                            style: titleTextStyle(),
                          )
                        : Text(
                            "Profile",
                            style: titleTextStyle(),
                          ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton.filledTonal(
              style: IconButton.styleFrom(backgroundColor: blackColor),
              onPressed: () => Get.to(() => NotificationScreen()),
              icon: badges.Badge(
                badgeContent: Text(
                  '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                position: badges.BadgePosition.topEnd(top: -15, end: -12),
                badgeStyle: badges.BadgeStyle(badgeColor: primaryColor),
                child: Icon(IconlyBroken.notification, color: whiteColor),
              ),
            ),
          ),
        ],
      ),
      body: _getPage(currentPageIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: blackColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
            backgroundColor: blackColor,
            selectedItemColor: whiteColor,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            currentIndex: currentPageIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            items: _buildBottomNavBarItems(),
          ),
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return PatientRegistrationForm();
      case 2:
        return OpdVisitForm();
      case 3:
        return PrescriptionForm();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  List<BottomNavigationBarItem> _buildBottomNavBarItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(IconlyLight.home),
        label: "",
        activeIcon: Icon(IconlyBold.home),
      ),
      const BottomNavigationBarItem(
        icon: Icon(IconlyLight.addUser),
        label: "",
        activeIcon: Icon(IconlyBold.addUser),
      ),
      const BottomNavigationBarItem(
        icon: Icon(IconlyLight.document),
        label: "",
        activeIcon: Icon(IconlyBold.document),
      ),
      const BottomNavigationBarItem(
        icon: Icon(IconlyLight.paper),
        label: "",
        activeIcon: Icon(IconlyBold.paper),
      ),
      const BottomNavigationBarItem(
        icon: Icon(IconlyLight.profile),
        label: "",
        activeIcon: Icon(IconlyBold.profile),
      ),
    ];
  }

  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: whiteColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Dr. Health'),
            accountEmail: Text('doctor@bhu.com'),
            currentAccountPicture: CircleAvatar(
                backgroundImage:
                    AssetImage('assets/default_profile.png') as ImageProvider,
                backgroundColor: Colors.white,
                child: Text(
                  'D',
                  style: const TextStyle(fontSize: 40.0),
                )),
            decoration: BoxDecoration(color: primaryColor),
          ),
          ListTile(
            leading: const Icon(
              IconlyLight.home,
              color: Colors.purple,
            ),
            title: const Text('Home'),
            onTap: () {
              setState(() {
                currentPageIndex = 0;
                Navigator.pop(context);
              });
            },
          ),
          ListTile(
            leading: Icon(
              IconlyLight.addUser,
              color: Colors.green[900],
            ),
            title: const Text('Patient Registration'),
            onTap: () {
              setState(() {
                currentPageIndex = 1;
                Navigator.pop(context);
              });
            },
          ),
          ListTile(
            leading: const Icon(
              IconlyLight.document,
              color: Colors.blue,
            ),
            title: const Text('OPD Visits'),
            onTap: () {
              setState(() {
                currentPageIndex = 2;
                Navigator.pop(context);
              });
            },
          ),
          ListTile(
            leading: const Icon(
              IconlyLight.paper,
              color: Colors.orange,
            ),
            title: const Text('Prescriptions'),
            onTap: () {
              setState(() {
                currentPageIndex = 3;
                Navigator.pop(context);
              });
            },
          ),
          ListTile(
            leading: const Icon(
              IconlyLight.profile,
              color: Colors.lime,
            ),
            title: const Text('Profile'),
            onTap: () {
              setState(() {
                currentPageIndex = 4;
                Navigator.pop(context);
              });
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: Text(
              'Logout',
            ),
            onTap: () async {
              Get.to(() => LoginScreen());
            },
          ),
        ],
      ),
    );
  }
}