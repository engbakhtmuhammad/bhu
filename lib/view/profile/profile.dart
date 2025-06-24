import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import 'package:bhu/view/profile/address.dart';
import 'package:bhu/view/profile/personal_info.dart';
import '../../models/user.dart';
import '../../widgets/profile_widgets.dart';
import '../../controller/auth_controller.dart';
import '../../controller/app_controller.dart';
import 'database_viewer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  final AppController appController = Get.find<AppController>();
  UserModel? user;

  late int totalCoins=0;

 @override
void initState() {
  super.initState();
  // Use real user data from auth controller
  final currentUser = authController.currentUser.value;
  if (currentUser != null) {
    user = UserModel(
      id: currentUser.id.toString(),
      userName: currentUser.userName,
      email: currentUser.email,
      image: 'https://img.freepik.com/free-photo/bearded-doctor-glasses_23-2147896187.jpg',
      bio: currentUser.designation,
      phoneNo: currentUser.phoneNo,
    );
  } else {
    // Fallback dummy user
    user = UserModel(
      id: '123',
      userName: 'Doctor',
      email: 'doctor@bhu.com',
      image: 'https://img.freepik.com/free-photo/bearded-doctor-glasses_23-2147896187.jpg',
      bio: 'Medical Professional',
      phoneNo: '1234567890',
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Row(
              children: [
                CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        user?.image ?? 'https://www.treasury.gov.ph/wp-content/uploads/2022/01/male-placeholder-image.jpeg',
                      ),
                      backgroundColor: primaryLightColor,
                    ),
                    SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 10),
                    Text(
                      user?.name ?? 'Loading...',
                      style: titleTextStyle()
                    ),
                    Text(
                      user!.bio ?? 'Loading...',
                      style: subTitleTextStyle(size: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          buildSection([
            buildListTile(title: "Personal Info", icon: IconlyLight.profile,color: Colors.orange,onTap: () => Get.to(()=>PersonalInfoScreen(user: user!,)),),
            buildListTile(title: "Addresses",icon:  IconlyLight.location,color: Colors.purple,onTap: () => Get.to(()=>AddressScreen(user: user!)),),
          ]),
          // buildSection([
          //   buildListTile(title: "Cart",icon: Icons.shopping_cart_outlined,color: Colors.blue),
          //   buildListTile(title: "Favourite",icon:  IconlyLight.heart,color: Colors.red),
          //   buildListTile(title: "Notifications",icon:  IconlyLight.notification,color: Colors.amber),
          //   buildListTile(title: "Payment Method",icon:  IconlyLight.wallet,color: Colors.green),
          // ]),
          // buildSection([
          //   buildListTile(title: "FAQs",icon:  Icons.help_outline,color: Colors.orangeAccent),
          //   buildListTile(title: "User Reviews",icon:  Icons.reviews_outlined,color: Colors.lightGreen),
          //   buildListTile(title: "Settings",icon:  IconlyLight.setting,color: Colors.deepPurple),
          // ]),
          // buildSection([
          //   buildListTile(title: "Settings",icon:  IconlyLight.setting,color: Colors.green),
          //   buildListTile(
          //     title: "Database Tables",
          //     icon: IconlyLight.folder,
          //     color: Colors.blue,
          //     onTap: () => Get.to(() => DatabaseViewerScreen()),
          //   ),
          // ]),
          const SizedBox(height: 10),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text("Log Out", style: TextStyle(color: Colors.red)),
      onTap: () async {
        // Show confirmation dialog
        final shouldLogout = await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: whiteColor,
            title: Text('Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (shouldLogout == true) {
          await authController.logout();
          appController.onLogout();
        }
      },
    );
  }
}
