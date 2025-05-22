import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../controller/patient_controller.dart';
import '../../models/patient_model.dart';
import '../../utils/constants.dart';
import '../../utils/style.dart';
import '../../widgets/input_field.dart';
import '../../widgets/custom_btn.dart';

class PatientRegistrationForm extends StatelessWidget {
  final controller = Get.put(PatientController());

  final nameCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final historyCtrl = TextEditingController();

  final gender = ''.obs;
  final bloodGroup = ''.obs;
  final immunized = false.obs;
  final relationType = 'own'.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _label("FULL NAME"),
            InputField(hintText: "Full Name", controller: nameCtrl),
            _label("CNIC"),
            InputField(hintText: "e.g. 1234567890123", controller: cnicCtrl),
            _label("RELATION TYPE"),
            Container(
              decoration: BoxDecoration(
                color: greyColor,
                borderRadius: BorderRadius.circular(containerRoundCorner),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Obx(() => DropdownButtonHideUnderline(
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
                    )),
              ),
            ),
            _label("CONTACT"),
            InputField(
                hintText: "+923001234567",
                controller: contactCtrl,
                inputType: TextInputType.phone),
            _label("ADDRESS"),
            InputField(hintText: "Your address", controller: addressCtrl),
            _label("GENDER"),
            Container(
                decoration: BoxDecoration(
                  color: greyColor,
                  borderRadius: BorderRadius.circular(containerRoundCorner),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Obx(() => DropdownButtonHideUnderline(
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
                      )),
                )),
            _label("BLOOD GROUP"),
            Container(
                decoration: BoxDecoration(
                  color: greyColor,
                  borderRadius: BorderRadius.circular(containerRoundCorner),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Obx(() => DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              bloodGroup.value == '' ? null : bloodGroup.value,
                          hint: Text("Select Blood Group"),
                          items: [
                            'A+',
                            'A-',
                            'B+',
                            'B-',
                            'AB+',
                            'AB-',
                            'O+',
                            'O-'
                          ]
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) => bloodGroup.value = val!,
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      )),
                )),
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
                String id = await controller.generatePatientId(
                    cnicCtrl.text.trim(), relationType.value);
                final patient = PatientModel(
                  patientId: id,
                  fullName: nameCtrl.text.trim(),
                  relationCnic: cnicCtrl.text.trim(),
                  relationType: relationType.value,
                  contact: contactCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                  gender: gender.value,
                  bloodGroup: bloodGroup.value,
                  medicalHistory: historyCtrl.text.trim(),
                  immunized: immunized.value,
                );
                await controller.savePatient(patient);
                Get.snackbar("Success", "Patient saved with ID: $id");
              },
            )
          ],
        ),
      ),
    );
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
