import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import '../../models/user.dart';
import '../../widgets/profile_widgets.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key, this.user});

  final UserModel? user;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        leading: IconButton.filledTonal(
        style: IconButton.styleFrom(backgroundColor: greyColor),
        onPressed: ()=>Get.back(),
        icon: Icon(IconlyLight.arrowLeft2),
      ),
      title: Text("Personal Info",style: titleTextStyle(),),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.only(right: 8.0),
      //     child: Text("Edit",style: subTitleTextStyle(color: primaryColor),),
      //   ),
      // ],
      ),
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
                        user!.image ?? 'https://www.treasury.gov.ph/wp-content/uploads/2022/01/male-placeholder-image.jpeg',
                      ),
                      backgroundColor: primaryLightColor,
                    ),
                    SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    const SizedBox(height: 10),
                    Text(
                      user!.name ?? 'Loading...',
                      style: titleTextStyle(size: 24)
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
            buildListTile2(title: "Full Name", subttile: user!.name??"Guest",icon:IconlyLight.profile,color: Colors.orange),
            buildListTile2(title: "Email", subttile: user!.email??"guest@example.com",icon:IconlyLight.message,color: Colors.purple),
            buildListTile2(title: "Phone Number", subttile: user!.phone??"N/A",icon:IconlyLight.call,color: Colors.blue),
            
          ]),
        ],
      ),
    );
  }
}
