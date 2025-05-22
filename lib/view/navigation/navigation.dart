
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import 'package:bhu/view/auth/signin.dart';
import 'package:bhu/view/chat/chat.dart';
import 'package:bhu/view/notification/notification.dart';
import 'package:bhu/view/home/home.dart';
import 'package:bhu/view/patient/patient_form.dart';
import 'package:bhu/view/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;


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
                    "HI, Hammad 👋🏾",
                    style: descriptionTextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        size: 12),
                  ),
                  Text("Love to code? Let's grow together",
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
                        "Chat",
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
                  // cartController.cartItems.isNotEmpty
                  //     ? cartController.cartItems.length.toString()
                  //     : '',
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
        return PatientForm();
      case 2:
        return const ChatScreen();
      case 3:
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
        icon: Icon(IconlyLight.folder),
        label: "",
        activeIcon: Icon(IconlyBold.folder),
      ),
      const BottomNavigationBarItem(
        icon: Icon(IconlyLight.chat),
        label: "",
        activeIcon: Icon(IconlyBold.chat),
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
            accountName: Text('Guest'),
            accountEmail: Text('guest@example.com'),
            currentAccountPicture: CircleAvatar(
                backgroundImage:
                    AssetImage('assets/default_profile.png') as ImageProvider,
                backgroundColor: Colors.white,
                child: Text(
                  'G',
                  style: const TextStyle(fontSize: 40.0),
                )),
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
              Icons.group_outlined,
              color: Colors.green[900],
            ),
            title: const Text('Community'),
            onTap: () {
              setState(() {
                currentPageIndex = 1;
                Navigator.pop(context);
              });
            },
          ),
          ListTile(
            leading: const Icon(
              IconlyLight.chat,
              color: Colors.lime,
            ),
            title: const Text('Chat'),
            onTap: () {
              setState(() {
                currentPageIndex = 2;
                Navigator.pop(context);
              });
            },
          ),
          ListTile(
            leading: const Icon(
              IconlyLight.profile,
              color: Colors.blue,
            ),
            title: const Text('Profile'),
            onTap: () {
              if ("user!.userType" == 'Guest') {
                Get.to(() => LoginScreen());
              } else {
                setState(() {
                  currentPageIndex = 3;
                  Navigator.pop(context);
                });
              }
            },
          ),
          ListTile(
              leading: const Icon(Icons.add, color: Colors.orange),
              title: const Text('Add Plant'),
            ),
          ListTile(
              leading: const Icon(Icons.park_outlined, color: Colors.green),
              title: const Text('My Plants'),
              onTap: () {
              },
            ),
          const Divider(),
          ListTile(
            leading: Icon(
              "firebaseUser" != null && "user?.userType" != "Guest"
                  ? IconlyLight.logout
                  : IconlyLight.login,
              color: "firebaseUser" != null && "user?.userType" != "Guest"
                  ? Colors.red
                  : Colors.green,
            ),
            title: Text(
              "firebaseUser" != null &&"user?.userType" != "Guest"
                  ? 'Logout'
                  : 'Sign In',
            ),
            onTap: () async {
            },
          ),
        ],
      ),
    );
  }
}
