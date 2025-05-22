
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import 'package:bhu/widgets/ads_widget.dart';
import 'package:bhu/widgets/widget_card.dart';
import 'package:bhu/widgets/search_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';

import '../../controller/patient_controller.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var isSearching = false;
  final PatientController patientController = Get.put(PatientController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: ListView(
        padding: EdgeInsets.all(defaultPadding),
        children: freeSupportAdsWidget,
      ),
    );
  }

  List<Widget> get freeSupportAdsWidget {
    return [
      // 🔍 Search Box
      Padding(
        padding: EdgeInsets.only(bottom: defaultPadding),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(containerRoundCorner),
          ),
          child: TextField(
            onChanged: (query) {
              setState(() => isSearching = query.isNotEmpty);
              // optionally filter
            },
            decoration: InputDecoration(
              hintText: "Search Doctor, activities",
              hintStyle: descriptionTextStyle(size: 14, fontWeight: FontWeight.w600),
              isDense: true,
              contentPadding: const EdgeInsets.all(12.0),
              border: InputBorder.none,
              prefixIcon: const Icon(IconlyLight.search),
            ),
          ),
        ),
      ),

      // 🔄 Search Mode
      if (isSearching)
        Obx(() => Column(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: PlantSearchItemWidget(plant: 1),
                ),
              ),
            ))
      else
        AdsWidget(onPressed: () {}),

      SizedBox(height: 10),

      // 🧑‍⚕️ Patients Header
      Text(
        "Patients",
        style: titleTextStyle(fontWeight: FontWeight.w600, size: 18),
      ),

      // 📋 Patients List
      Obx(() {
        final patients = patientController.patients;
        if (patients.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text("No patients found", style: descriptionTextStyle()),
          );
        }

        return Column(
          children: patients.map((patient) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CardWidget(
                title: patient.fullName,
                subtitle: "${patient.contact} (${patient.gender})",
                description: "CNIC: ${patient.relationCnic}\n"
                    "Type: ${patient.relationType}\n"
                    "Blood Group: ${patient.bloodGroup}\n"
                    "Address: ${patient.address}",
              ),
            );
          }).toList(),
        );
      }),
    ];
  }
}
