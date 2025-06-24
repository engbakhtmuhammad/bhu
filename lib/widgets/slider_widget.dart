import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import 'package:bhu/view/forms/opd_visit.dart';
import 'package:bhu/view/forms/patient_registration.dart';
import 'package:bhu/view/patient/patient_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardSlider extends StatelessWidget {
  const DashboardSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Dashboard",
            style: titleTextStyle()
          ),
        ),
        SizedBox(
          height: 180,
          child: PageView(
            controller: PageController(viewportFraction: 0.4), // Set to 0.4 as requested
            padEnds: false, // This ensures no padding at the start
            children: [
              _buildDashBoardCard(
                title: "New Patient",
                subtitle: "Registration",
                imagePath: "assets/images/register.png",
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                ),
                onPressed: () => Get.to(() =>  PatientRegistrationForm()),
              ),
              _buildDashBoardCard(
                title: "View Patient",
                subtitle: "Records",
                imagePath: "assets/images/view.png",
                onPressed: () => Get.to(() =>  AllPatientsScreen()),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6B9D), Color(0xFFFF8E8E)],
                ),
              ),
              _buildDashBoardCard(
                title: "OPD",
                subtitle: "Visit",
                imagePath: "assets/images/doctor.png",
                onPressed: () => Get.to(() =>  OpdVisitForm()),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF74B9FF), Color(0xFF0984E3)],
                ),
              ),
            ],
          ),
        ),
        // Dots indicator
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                4,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  width: index == 0 ? 12 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index == 0 ? Colors.black54 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashBoardCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required Gradient gradient,VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed??(){},
      child: Container(
        margin: EdgeInsets.only(right: 12), // Changed from symmetric to only right margin
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Center Image
            Expanded(
              child: Center(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if image not found
                    return Icon(
                      Icons.health_and_safety,
                      size: 90,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
            
            SizedBox(height: 5),
            
            // Title and Subtitle at bottom
            Text(
              title,
              style: subTitleTextStyle(
                color: whiteColor,size: 15,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: subTitleTextStyle(color: whiteColor,size: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}