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
  final bloodGroups = <Map<String, dynamic>>[].obs;
  final immunized = false.obs;
  final relationType = 'own'.obs;
  
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
                  items: ['own', 'father', 'husband']
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
                      items: ['Male', 'Female']
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => gender.value = val!,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ))),
              _label("BLOOD GROUP"),
              DropDownWidget(
                child: Obx(() => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value:
                            bloodGroup.value == '' ? null : bloodGroup.value,
                        hint: Text("Select Blood Group"),
                        items: bloodGroups
                            .map((e) =>
                                DropdownMenuItem<String>(value: e['name'] as String, child: Text(e['name'] as String)))
                            .toList(),
                        onChanged: (val) => bloodGroup.value = val!,
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    )),
              ),
              _label("IMMUNIZED"),
              Obx(() => SwitchListTile(
                    value: immunized.value,
                    onChanged: (val) => immunized.value = val,
                    title: Text("Immunized?"),
                  )),
              _label("MEDICAL HISTORY"),
              InputField(
                  hintText: "Chronic illnesses, allergies",
                  controller: historyCtrl),
              const SizedBox(height: 20),
              CustomBtn(
                icon: IconlyLight.addUser,
                text: "Save Patient",
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  
                  String id = await controller.generatePatientId(
                      cnicCtrl.text.trim(), relationType.value);
                  
                  // Get blood group ID from selected blood group name
                  int bloodGroupId = 1; // Default to A+ (ID: 1)
                  final selectedBg = bloodGroups.firstWhere(
                    (bg) => bg['name'] == bloodGroup.value,
                    orElse: () => {'id': 1, 'name': 'A+'},
                  );
                  
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
                    age: 18,
                    gender: gender.value,
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

