import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import 'package:bhu/widgets/ads_widget.dart';
import 'package:bhu/widgets/slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';

import '../../controller/patient_controller.dart';
import '../../controller/opd_controller.dart';
import '../../controller/sync_controller.dart';
import '../../controller/auth_controller.dart';
import '../patient/patient_details.dart';
import '../patient/patient_list.dart';
import '../../utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var isSearching = false;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  final PatientController patientController = Get.put(PatientController());
  final OpdController opdController = Get.put(OpdController());
  final SyncController syncController = Get.put(SyncController());
  final AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    // Make sure to load OPD visits when the home screen initializes
    patientController.loadPatients();
    opdController.loadOpdVisits();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Add debug print to check OPD visits count
    print('OPD Visits count: ${opdController.opdVisits.length}');
    
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
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(containerRoundCorner),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
                isSearching = value.isNotEmpty;
              });
            },
            decoration: InputDecoration(
              hintText: "Search Patients, OPD Visits",
              hintStyle: descriptionTextStyle(size: 14, fontWeight: FontWeight.w500),
              isDense: true,
              contentPadding: const EdgeInsets.all(15.0),
              border: InputBorder.none,
              prefixIcon: Icon(IconlyLight.search, color: Colors.grey.shade600),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey.shade600),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchQuery = '';
                          isSearching = false;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),

      // 🔄 Search Results
      if (isSearching) ...[
        _buildSearchResults(),
      ] else ...[
        AdsWidget(),
        SizedBox(height: 10),
        DashboardSlider(),
        SizedBox(height: 20),

        // 📊 Statistics Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Total Patients",
                Obx(() => Text(
                  patientController.patients.length.toString(),
                  style: titleTextStyle(size: 28, color: primaryColor),
                )),
                IconlyBold.user3,
                primaryColor,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                "OPD Visits",
                Obx(() => Text(
                  opdController.opdVisits.length.toString(),
                  style: titleTextStyle(size: 28, color: Colors.green),
                )),
                IconlyBold.activity,
                Colors.green,
              ),
            ),
          ],
        ),

        SizedBox(height: 20),

        // 🔄 Sync Section
        _buildSyncSection(),

        SizedBox(height: 30),

        // 🧑‍⚕️ Recent Patients Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Patients",
              style: titleTextStyle(fontWeight: FontWeight.w700, size: 20),
            ),
            TextButton(
              onPressed: () => Get.to(() => AllPatientsScreen()),
              child: Text(
                "View All",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 10),

        // 📋 Patients List
        Obx(() {
          final patients = patientController.patients.take(5).toList();
          if (patients.isEmpty) {
            return _buildEmptyState(
              icon: IconlyLight.user2,
              message: "No patients found",
            );
          }

          return Column(
            children: patients.map((patient) {
              return _buildPatientCard(patient);
            }).toList(),
          );
        }),

        SizedBox(height: 30),

        // 🏥 Recent OPD Visits Header
        Text(
          "Recent OPD Visits",
          style: titleTextStyle(fontWeight: FontWeight.w700, size: 20),
        ),

        SizedBox(height: 10),

        // 📋 OPD Visits List
        Obx(() {
          final visits = opdController.opdVisits.take(5).toList();
          if (visits.isEmpty) {
            return _buildEmptyState(
              icon: IconlyLight.document,
              message: "No OPD visits found",
            );
          }

          return Column(
            children: visits.map((visit) {
              return _buildOPDCard(visit);
            }).toList(),
          );
        }),
      ],
    ];
  }

  Widget _buildPatientCard(patient) {
    return GestureDetector(
      onTap: () => Get.to(() => PatientDetailScreen(patient: patient)),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    patient.fullName.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15),
              // Patient Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: titleTextStyle(size: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(IconlyLight.call, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          patient.contact,
                          style: descriptionTextStyle(size: 13),
                        ),
                        SizedBox(width: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: patient.gender == '1'
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.pink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            patient.gender== '1'?'Male':'Female',
                            style: TextStyle(
                              fontSize: 12,
                              color: patient.gender == '1'
                                ? Colors.blue
                                : Colors.pink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    /*SizedBox(height: 4),
                    Text(
                      'Blood Group: ${getBloodGroupName(patient.bloodGroup)}',
                      style: descriptionTextStyle(size: 12),
                    ),*/
                  ],
                ),
              ),
              // Arrow
              Icon(
                IconlyLight.arrowRight2,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOPDCard(visit) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                IconlyLight.ticket,
                color: Colors.green,
                size: 24,
              ),
            ),
            SizedBox(width: 15),
            // Visit Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Ticket: ${visit.opdTicketNo}',
                        style: titleTextStyle(size: 15, fontWeight: FontWeight.w600),
                      ),
                      if (visit.isFollowUp) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Follow-up',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    visit.reasonForVisit==1?'General OPD':'OBGYN',
                    style: descriptionTextStyle(size: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(IconlyLight.calendar, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${visit.visitDateTime.day}/${visit.visitDateTime.month}/${visit.visitDateTime.year}',
                        style: descriptionTextStyle(size: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, Widget value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 15),
          value,
          SizedBox(height: 5),
          Text(
            title,
            style: descriptionTextStyle(size: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 50, color: Colors.grey.shade300),
            SizedBox(height: 10),
            Text(
              message,
              style: descriptionTextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      // Filter patients
      final filteredPatients = patientController.patients.where((patient) {
        return patient.fullName.toLowerCase().contains(searchQuery) ||
               patient.contact.toLowerCase().contains(searchQuery) ||
               patient.cnic.toLowerCase().contains(searchQuery);
      }).toList();

      // Filter OPD visits
      final filteredVisits = opdController.opdVisits.where((visit) {
        return visit.opdTicketNo.toLowerCase().contains(searchQuery) ||
               visit.patientId.toLowerCase().contains(searchQuery);
      }).toList();

      if (filteredPatients.isEmpty && filteredVisits.isEmpty) {
        return Column(
          children: [
            SizedBox(height: 50),
            Icon(IconlyLight.search, size: 60, color: Colors.grey.shade300),
            SizedBox(height: 20),
            Text(
              'No results found for "$searchQuery"',
              style: titleTextStyle(size: 16, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              'Try searching with different keywords',
              style: descriptionTextStyle(color: Colors.grey),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filteredPatients.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Patients (${filteredPatients.length})',
                style: titleTextStyle(size: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ...filteredPatients.map((patient) => _buildPatientCard(patient)).toList(),
            SizedBox(height: 20),
          ],
          if (filteredVisits.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'OPD Visits (${filteredVisits.length})',
                style: titleTextStyle(size: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ...filteredVisits.map((visit) => _buildOPDCard(visit)).toList(),
          ],
        ],
      );
    });
  }

  Widget _buildSyncSection() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryLightColor,
              blurRadius: 20,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryLightColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(IconlyBold.upload, color: primaryColor, size: 24),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Sync',
                        style: titleTextStyle(size: 18, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        syncController.syncStatusText,
                        style: descriptionTextStyle(size: 13),
                      ),
                    ],
                  ),
                ),
                if (syncController.hasUnsyncedData.value)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Pending',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            if (syncController.isSyncing.value) ...[
              SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    syncController.syncStatus.value,
                    style: descriptionTextStyle(size: 12),
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: syncController.syncProgress.value,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${(syncController.syncProgress.value * 100).toInt()}% Complete',
                    style: descriptionTextStyle(size: 11),
                  ),
                ],
              ),
            ],

            SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: syncController.isSyncing.value
                        ? null
                        : () => syncController.syncData(),
                    icon: syncController.isSyncing.value
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(IconlyLight.upload, size: 18,color: whiteColor,),
                    label: Text(
                      syncController.isSyncing.value ? 'Syncing...' : 'Sync Now',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                if (!syncController.isSyncing.value) ...[
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: () => _showSyncInfo(),
                    icon: Icon(IconlyLight.infoSquare, color: Colors.grey),
                    tooltip: 'Sync Information',
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showSyncInfo() {
    Get.dialog(
      AlertDialog(
        backgroundColor: whiteColor,
        title: Text('Sync Information'),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last Sync: ${syncController.syncStatusText}'),
            SizedBox(height: 10),
            Text('Status: ${syncController.hasUnsyncedData.value ? "Has unsynced data" : "All data synced"}'),
            SizedBox(height: 10),
            if (syncController.lastSyncTime.value != null) ...[
              Text('Uploaded Patients: ${syncController.uploadedPatients.value}'),
              Text('Uploaded OPD Visits: ${syncController.uploadedOpdVisits.value}'),
              Text('Downloaded Data: ${syncController.downloadedData.value > 0 ? "Yes" : "No"}'),
            ],
          ],
        )),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
          if (!syncController.isSyncing.value)
            TextButton(
              onPressed: () {
                Get.back();
                syncController.forceSyncData();
              },
              child: Text('Force Sync'),
            ),
        ],
      ),
    );
  }
}
