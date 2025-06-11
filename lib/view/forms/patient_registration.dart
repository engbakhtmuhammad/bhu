import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../controller/patient_controller.dart';
import '../../controller/opd_controller.dart';
import '../../db/database_helper.dart';
import '../../models/patient_model.dart';
import '../../utils/constants.dart';
import '../../utils/style.dart';
import '../../widgets/input_field.dart';
import '../../widgets/custom_btn.dart';
import '../../widgets/input_widget.dart';

class PatientRegistrationForm extends StatelessWidget {
  final controller = Get.put(PatientController());
  final db = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final historyCtrl = TextEditingController();

  final gender = ''.obs;
  final bloodGroup = ''.obs;
  final age = 0.obs;
  final bloodGroups = <Map<String, dynamic>>[].obs;
  final ages = <Map<String, dynamic>>[].obs;
  final immunized = false.obs;
  final relationType = 'own'.obs;
  final yearOfBirth = Rx<int?>(null);
  
  PatientRegistrationForm() {
    _loadBloodGroups();
  }
  
  Future<void> _loadBloodGroups() async {
    try {
      final groups = await db.getBloodGroups();
      if (groups.isNotEmpty) {
        bloodGroups.value = groups;
      } else {
        // Fallback to default blood groups
        bloodGroups.value = [
          {'id': 1, 'name': 'A+'},
          {'id': 2, 'name': 'A-'},
          {'id': 3, 'name': 'B+'},
          {'id': 4, 'name': 'B-'},
          {'id': 5, 'name': 'AB+'},
          {'id': 6, 'name': 'AB-'},
          {'id': 7, 'name': 'O+'},
          {'id': 8, 'name': 'O-'},
        ];
      }
    } catch (e) {
      // Fallback to default blood groups
      bloodGroups.value = [
        {'id': 1, 'name': 'A+'},
        {'id': 2, 'name': 'A-'},
        {'id': 3, 'name': 'B+'},
        {'id': 4, 'name': 'B-'},
        {'id': 5, 'name': 'AB+'},
        {'id': 6, 'name': 'AB-'},
        {'id': 7, 'name': 'O+'},
        {'id': 8, 'name': 'O-'},
      ];
    }
   ages.value = [
  {'id': 1, 'name': 'Child (0-12)'},
  {'id': 2, 'name': 'Teenager (13-19)'},
  {'id': 3, 'name': 'Adult (20-59)'},
  {'id': 4, 'name': 'Senior (60+)'},
];

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _label("FULL NAME"),
              InputField(hintText: "Full Name", controller: nameCtrl),
              _label("CNIC"),
              InputField(hintText: "e.g. 1234567890123", controller: cnicCtrl),
              _label("RELATION TYPE"),
              DropDownWidget(child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: relationType.value,
                  items: ['own', 'father', 'husband', 'mother']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (val) => relationType.value = val!,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              )),),
              _label("CONTACT"),
              InputField(
                  hintText: "+923001234567",
                  controller: contactCtrl,
                  inputType: TextInputType.phone),
              _label("ADDRESS"),
              InputField(hintText: "Your address", controller: addressCtrl),
              _label("GENDER"),
              DropDownWidget(child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: gender.value == '' ? null : gender.value,
                      hint: Text("Select Gender"),
                      items: ['Male', 'Female', 'Transgender', 'Other']
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => gender.value = val!,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ))),
              // _label("BLOOD GROUP"),
              // DropDownWidget(
              //   child: Obx(() => DropdownButtonHideUnderline(
              //         child: DropdownButton<String>(
              //           value:
              //               bloodGroup.value == '' ? null : bloodGroup.value,
              //           hint: Text("Select Blood Group"),
              //           items: bloodGroups
              //               .map((e) =>
              //                   DropdownMenuItem<String>(value: e['name'] as String, child: Text(e['name'] as String)))
              //               .toList(),
              //           onChanged: (val) => bloodGroup.value = val!,
              //           dropdownColor: Colors.white,
              //           borderRadius: BorderRadius.circular(8.0),
              //         ),
              //       )),
              // ),
               _label("YEAR OF BIRTH"),
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(DateTime.now().year - 20),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    initialDatePickerMode: DatePickerMode.year,
                  );
                  if (picked != null) {
                    yearOfBirth.value = picked.year;
                    // Calculate age from year of birth
                    age.value = DateTime.now().year - picked.year;
                    // Set age group based on calculated age
                    // if (age <= 12) {
                    //   age.value = 'Child (0-12)';
                    // } else if (age <= 19) {
                    //   age.value = 'Teenager (13-19)';
                    // } else if (age <= 59) {
                    //   age.value = 'Adult (20-59)';
                    // } else {
                    //   age.value = 'Senior (60+)';
                    // }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: greyColor,
                    borderRadius: BorderRadius.circular(containerRoundCorner),
                  ),
                  child: Row(
                    children: [
                      Icon(IconlyLight.calendar),
                      SizedBox(width: 10),
                      Obx(() => Text(
                        yearOfBirth.value != null
                            ? "${yearOfBirth.value}"
                            : "Select Year of Birth",
                      )),
                    ],
                  ),
                ),
              ),
              // _label("IMMUNIZED"),
              // Obx(() => SwitchListTile(
              //       value: immunized.value,
              //       onChanged: (val) => immunized.value = val,
              //       title: Text("Immunized?"),
              //     )),
              // _label("MEDICAL HISTORY"),
              // InputField(
              //     hintText: "Chronic illnesses, allergies",
              //     controller: historyCtrl),
              const SizedBox(height: 20),
              CustomBtn(
                icon: IconlyLight.addUser,
                text: "Save Patient",
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  
                  // Use CNIC as patient ID without concatenating relation type
                  String id = cnicCtrl.text.trim();
                  
                  // Get blood group ID from selected blood group name
                  int bloodGroupId = 1; // Default to A+ (ID: 1)
                  final selectedBg = bloodGroups.firstWhere(
                    (bg) => bg['name'] == bloodGroup.value,
                    orElse: () => {'id': 1, 'name': 'A+'},
                  );
                  
                  // Map relation type to correct integer values
                  int relationTypeId;
                  switch (relationType.value) {
                    case 'own': relationTypeId = 1; break;
                    case 'father': relationTypeId = 2; break;
                    case 'mother': relationTypeId = 3; break;
                    case 'husband': relationTypeId = 4; break;
                    default: relationTypeId = 5; // other
                  }
                  
                  // Map gender to correct integer values
                  int genderId;
                  switch (gender.value) {
                    case 'Male': genderId = 1; break;
                    case 'Female': genderId = 2; break;
                    case 'Transgender': genderId = 3; break;
                    default: genderId = 4; // other
                  }
                  
                  // Determine father/husband name based on relation type
                  String fatherName = '';
                  String? husbandName;
                  
                  if (relationType.value == 'father') {
                    fatherName = nameCtrl.text.trim();
                  } else if (relationType.value == 'husband') {
                    husbandName = nameCtrl.text.trim();
                  }
                  
                  final patient = PatientModel(
                    patientId: id,
                    fullName: nameCtrl.text.trim(),
                    fatherName: fatherName,
                    husbandName: husbandName,
                    age: age.value,
                    relationType: relationTypeId,
                    gender: genderId.toString(), // Pass the gender ID
                    cnic: cnicCtrl.text.trim(),
                    contact: contactCtrl.text.trim(),
                    emergencyContact: contactCtrl.text.trim(),
                    address: addressCtrl.text.trim(),
                    bloodGroup: selectedBg['id'],
                    medicalHistory: historyCtrl.text.trim(),
                    immunized: immunized.value,
                  );
                  await controller.savePatient(patient);
                  
                  // Refresh OPD controller's patient list
                  if (Get.isRegistered<OpdController>()) {
                    final opdController = Get.find<OpdController>();
                    await opdController.refreshPatients();
                  }
                  
                  Get.snackbar("Success", "Patient saved with ID: $id");
                },
              )
            ],
          ),
    )));
  }

  Widget _label(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: subTitleTextStyle(color: Colors.black, size: 15)),
        const SizedBox(height: 5),
      ],
    );
  }
}

