import 'package:bhu/view/forms/patient_registration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import '../../controller/patient_controller.dart';
import '../../utils/helpers.dart';
import 'patient_details.dart';

class AllPatientsScreen extends StatefulWidget {
  const AllPatientsScreen({super.key});

  @override
  State<AllPatientsScreen> createState() => _AllPatientsScreenState();
}

class _AllPatientsScreenState extends State<AllPatientsScreen> {
  final PatientController patientController = Get.find<PatientController>();
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedFilter = 'All';
  String selectedSort = 'Name';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        leading: IconButton.filledTonal(
          style: IconButton.styleFrom(backgroundColor: greyColor),
          onPressed: () => Get.back(),
          icon: const Icon(IconlyLight.arrowLeft2),
        ),
        backgroundColor: whiteColor,
        title: const Text("All Patients"),
        actions: [
          IconButton.filledTonal(
            style: IconButton.styleFrom(backgroundColor: greyColor),
            onPressed: () => Get.to(PatientRegistrationForm()),
            icon: const Icon(IconlyLight.plus),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: greyColor.withOpacity(0.5),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
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
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search by uniqueId, name, CNIC, or contact...",
                      hintStyle: descriptionTextStyle(
                          size: 14, fontWeight: FontWeight.w500),
                      isDense: true,
                      contentPadding: const EdgeInsets.all(15.0),
                      border: InputBorder.none,
                      prefixIcon:
                          Icon(IconlyLight.search, color: Colors.grey.shade600),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: Colors.grey.shade600),
                              onPressed: () {
                                searchController.clear();
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Filter and Sort Row
                Row(
                  children: [
                    // Filter Dropdown
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedFilter,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            icon: Icon(IconlyLight.filter, size: 20),
                            items: [
                              'All',
                              'Filter Data'
                            ]
                                .map((filter) => DropdownMenuItem(
                                      value: filter,
                                      child: Text(filter,
                                          style: subTitleTextStyle(size: 14)),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedFilter = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Sort Dropdown
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedSort,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            icon: Icon(IconlyLight.swap, size: 20),
                            items: ['Name', 'Recent', 'Cnic', 'UniqueId', 'Gender']
                                .map((sort) => DropdownMenuItem(
                                      value: sort,
                                      child: Text(sort,
                                          style: subTitleTextStyle(size: 14)),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSort = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Stats Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Obx(() {
              final filteredPatients = _getFilteredPatients();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredPatients.length} Patients Found',
                    style:
                        titleTextStyle(size: 16, fontWeight: FontWeight.w600),
                  ),
                  if (searchQuery.isNotEmpty || selectedFilter != 'All')
                    TextButton(
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                          searchController.clear();
                          selectedFilter = 'All';
                        });
                      },
                      child: Text(
                        'Clear Filters',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                ],
              );
            }),
          ),
          // Patients List
          Expanded(
            child: Obx(() {
              final filteredPatients = _getFilteredPatients();

              if (filteredPatients.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredPatients.length,
                itemBuilder: (context, index) {
                  final patient = filteredPatients[index];
                  return _buildPatientCard(patient, index);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getFilteredPatients() {
    var patients = patientController.patients.toList();

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      patients = patients.where((patient) {
        return
            patient.patientId.toLowerCase().contains(searchQuery) ||
            patient.fullName.toLowerCase().contains(searchQuery) ||
            patient.contact.toLowerCase().contains(searchQuery) ||
            patient.cnic.toLowerCase().contains(searchQuery);
      }).toList();
    }

    // Apply category filter
    // if (selectedFilter != 'All') {
    //   if (selectedFilter == 'Gender') {
    //     patients = patients.where((p) => p.gender == selectedFilter).toList();
    //   } else {
    //     // Blood group filter
    //     /*patients =
    //         patients.where((p) => p.bloodGroup == selectedFilter).toList();*/
    //   }
    // }

    // Apply sorting
    switch (selectedSort) {
      case 'Name':
        patients.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case 'Cnic':
        patients.sort((a, b) => a.cnic.compareTo(b.cnic));
        break;
      case 'UniqueId':
        patients.sort((a, b) => a.patientId.compareTo(b.patientId));
        break;
      case 'Gender':
        patients.sort((a, b) => a.gender.compareTo(b.gender));
        break;
      case 'Recent':
        // Assuming there's a createdAt field, otherwise reverse the list
        patients = patients.reversed.toList();
        break;
      /*case 'Blood Group':
        patients.sort((a, b) => a.bloodGroup.compareTo(b.bloodGroup));
        break;*/
    }

    return patients;
  }

  Widget _buildPatientCard(patient, int index) {
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
              // Number Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getGenderColor(patient.gender).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    patient.fullName.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: _getGenderColor(patient.gender),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            patient.fullName,
                            style: titleTextStyle(
                                size: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          /*child: Text(
                            getBloodGroupName(patient.bloodGroup),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),*/
                        ),
                      ],
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getGenderColor(patient.gender)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            patient.gender== '1'?'Male':'Female',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getGenderColor(patient.gender),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(IconlyLight.document, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UNIQUE_ID: ${patient.patientId}',
                                style: descriptionTextStyle(size: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2), // spacing between lines
                              Text(
                                'CNIC: ${patient.cnic}',
                                style: descriptionTextStyle(size: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

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

  Color _getGenderColor(String gender) {
    return gender == '1' ? Colors.blue : Colors.pink;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconlyLight.profile,
            size: 80,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 20),
          Text(
            searchQuery.isNotEmpty ? 'No patients found' : 'No patients yet',
            style: titleTextStyle(size: 18, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Text(
            searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Add your first patient to get started',
            style: descriptionTextStyle(color: Colors.grey),
          ),
          SizedBox(height: 30),
          FilledButton.icon(
            onPressed: () => Get.to(PatientRegistrationForm()),
            icon: Icon(IconlyLight.plus),
            label: Text('Add Patient'),
            style: FilledButton.styleFrom(
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
