import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import 'package:bhu/widgets/ads_widget.dart';
import 'package:bhu/widgets/slider_widget.dart';
import 'package:bhu/widgets/widget_card.dart';
import 'package:bhu/widgets/search_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';

import '../../controller/patient_controller.dart';
import '../../controller/opd_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var isSearching = false;
  final PatientController patientController = Get.put(PatientController());
  final OpdController opdController = Get.put(OpdController());

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
              hintText: "Search Patients, OPD Visits",
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
      DashboardSlider(),
      SizedBox(height: 10),

      // 📊 Statistics Row
      Row(
        children: [
          Expanded(
            child: _buildStatCard(
              "Total Patients", 
              Obx(() => Text(
                patientController.patients.length.toString(),
                style: titleTextStyle(size: 24, color: primaryColor),
              )),
              Icons.people,
              primaryColor,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              "OPD Visits", 
              Obx(() => Text(
                opdController.opdVisits.length.toString(),
                style: titleTextStyle(size: 24, color: Colors.green),
              )),
              Icons.medical_services,
              Colors.green,
            ),
          ),
        ],
      ),

      SizedBox(height: 20),

      // 🧑‍⚕️ Recent Patients Header
      Text(
        "Recent Patients",
        style: titleTextStyle(fontWeight: FontWeight.w600, size: 18),
      ),

      // 📋 Patients List
      Obx(() {
        final patients = patientController.patients.take(5).toList();
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

      SizedBox(height: 20),

      // 🏥 Recent OPD Visits Header
      Text(
        "Recent OPD Visits",
        style: titleTextStyle(fontWeight: FontWeight.w600, size: 18),
      ),

      // 📋 OPD Visits List
      Obx(() {
        final visits = opdController.opdVisits.take(5).toList();
        if (visits.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text("No OPD visits found", style: descriptionTextStyle()),
          );
        }

        return Column(
          children: visits.map((visit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CardWidget(
                title: "Ticket: ${visit.opdTicketNo}",
                subtitle: "Patient: ${visit.patientId}",
                description: "Visit: ${visit.reasonForVisit}\n"
                    "Date: ${visit.visitDateTime.day}/${visit.visitDateTime.month}/${visit.visitDateTime.year}\n"
                    "Follow-up: ${visit.isFollowUp ? 'Yes' : 'No'}\n"
                    "Referred: ${visit.isReferred ? 'Yes' : 'No'}",
              ),
            );
          }).toList(),
        );
      }),
    ];
  }

  Widget _buildStatCard(String title, Widget value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(containerRoundCorner),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 10),
          value,
          SizedBox(height: 5),
          Text(
            title,
            style: descriptionTextStyle(size: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}