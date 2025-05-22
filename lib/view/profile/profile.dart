import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import 'package:bhu/view/profile/address.dart';
import 'package:bhu/view/profile/personal_info.dart';
import '../../models/user.dart';
import '../../widgets/profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;

  late int totalCoins=0;

 @override
void initState() {
  super.initState();
  // Temporary dummy user
  user = UserModel(
    id: '123',
    name: 'John Doe',
    email: 'johndoe@example.com',
    image: 'https://img.freepik.com/free-photo/bearded-doctor-glasses_23-2147896187.jpg',
    bio: 'A passionate developer',
    phone: '1234567890',
  );
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
          buildSection([
            buildListTile(title: "Cart",icon: Icons.shopping_cart_outlined,color: Colors.blue),
            buildListTile(title: "Favourite",icon:  IconlyLight.heart,color: Colors.red),
            buildListTile(title: "Notifications",icon:  IconlyLight.notification,color: Colors.amber),
            buildListTile(title: "Payment Method",icon:  IconlyLight.wallet,color: Colors.green),
          ]),
          buildSection([
            buildListTile(title: "FAQs",icon:  Icons.help_outline,color: Colors.orangeAccent),
            buildListTile(title: "User Reviews",icon:  Icons.reviews_outlined,color: Colors.lightGreen),
            buildListTile(title: "Settings",icon:  IconlyLight.setting,color: Colors.deepPurple),
          ]),
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
      onTap: () => {},
    );
  }
}
