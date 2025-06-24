import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final selectedGender = Rx<Map<String, dynamic>?>(null);
  final genders = <Map<String, dynamic>>[].obs;

  final age = 0.obs;
  final relationType = 'own'.obs;
  final selectedRelationType = Rx<Map<String, dynamic>?>(null);
  final relationTypes = <Map<String, dynamic>>[].obs;
  final yearOfBirth = Rx<int?>(null);

  final ageCtrl = TextEditingController();

  // Error messages observable
  final relationTypeError = RxString('');
  final genderError = RxString('');
  final nameError = RxString('');
  final cnicError = RxString('');
  final contactError = RxString('');

  PatientRegistrationForm({super.key}) {
    _loadGenders();
    _loadRelationTypes();
  }

  Future<void> _loadGenders() async {
    try {
      final genderList = await db.getApiGenders();
      genders.value = genderList.isNotEmpty
          ? genderList
          : [];
      final relationTypeList = await db.getRelationTypes();
      relationTypes.value = relationTypeList.isNotEmpty
          ? relationTypeList
          : [];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _loadRelationTypes() async {
    try {

    } catch (e) {
      relationTypes.value = [
        {'id': 1, 'name': 'Own'},
        {'id': 2, 'name': 'Father'},
        {'id': 3, 'name': 'Mother'},
        {'id': 4, 'name': 'Husband'},
      ];
    }
    selectedRelationType.value = relationTypes.first;
    relationType.value = relationTypes.first['name'].toString().toLowerCase();
  }

  void _validateName(String value) {
    if (value.isEmpty) {
      nameError.value = 'Please enter full name';
    } else {
      nameError.value = '';
    }
  }

  void _validateCNIC(String value) {
    if (value.isEmpty) {
      cnicError.value = 'Please enter your CNIC';
    } else if (value.length != 13) {
      cnicError.value = 'CNIC must be exactly 13 digits';
    } else if (!RegExp(r'^\d{13}$').hasMatch(value)) {
      cnicError.value = 'CNIC must contain only digits';
    } else {
      cnicError.value = '';
    }
  }

  void _validateContact(String value) {
    String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.isEmpty) {
      contactError.value = 'Please enter contact number';
    } else if (digitsOnly.length < 11) {
      contactError.value = 'Contact number must be at least 11 digits';
    } else if (digitsOnly.length > 13) {
      contactError.value = 'Contact number is too long';
    } else if (!RegExp(r'^(03|923)').hasMatch(digitsOnly)) {
      contactError.value = 'Please enter a valid Pakistani mobile number';
    } else {
      contactError.value = '';
    }
  }

  bool _validateForm() {
    _validateName(nameCtrl.text);
    _validateCNIC(cnicCtrl.text);
    _validateContact(contactCtrl.text);

    // Validate relation type
    if (selectedRelationType.value == null) {
      relationTypeError.value = 'Please select relation type';
    } else {
      relationTypeError.value = '';
    }

    // Validate gender
    if (selectedGender.value == null) {
      genderError.value = 'Please select gender';
    } else {
      genderError.value = '';
    }

    return nameError.value.isEmpty &&
        cnicError.value.isEmpty &&
        contactError.value.isEmpty &&
        relationTypeError.value.isEmpty &&
        genderError.value.isEmpty;
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
        title: const Text("Register Patient"),
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _label("FULL NAME"),
              InputField(
                hintText: "Full Name",
                controller: nameCtrl,
                onChanged: _validateName,
              ),
              Obx(() => nameError.value.isNotEmpty
                  ? _errorText(nameError.value)
                  : const SizedBox.shrink()),
              const SizedBox(height: 15),

              _label("CNIC"),
              InputField(
                hintText: "Enter your CNIC (e.g., 3520112345678)",
                controller: cnicCtrl,
                inputType: TextInputType.number,
                onChanged: _validateCNIC,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(13),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              Obx(() => cnicError.value.isNotEmpty
                  ? _errorText(cnicError.value)
                  : const SizedBox.shrink()),
              const SizedBox(height: 15),

              _label("RELATION TYPE"),
              DropDownWidget(child: Obx(() {
                final relationTypeOptions =
                relationTypes.map((e) => Map<String, dynamic>.from(e)).toList();

                Map<String, dynamic>? selectedValue;
                if (selectedRelationType.value != null) {
                  try {
                    selectedValue = relationTypeOptions.firstWhere(
                            (element) => element['id'] == selectedRelationType.value!['id']);
                  } catch (_) {
                    selectedValue = null;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, dynamic>>(
                        value: selectedValue,
                        hint: const Text("Select Relation Type"),
                        isExpanded: true,
                        items: relationTypeOptions.map((relationType) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: relationType,
                            child: Text(relationType['name']),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            selectedRelationType.value = val;
                            relationType.value = val['name'].toString().toLowerCase();
                            relationTypeError.value = '';
                          }
                        },
                      ),
                    ),
                    Obx(() => relationTypeError.value.isNotEmpty
                        ? _errorText(relationTypeError.value)
                        : const SizedBox.shrink()),
                  ],
                );
              })),
              const SizedBox(height: 15),

              _label("CONTACT"),
              InputField(
                hintText: "+923001234567",
                controller: contactCtrl,
                inputType: TextInputType.phone,
                onChanged: _validateContact,
              ),
              Obx(() => contactError.value.isNotEmpty
                  ? _errorText(contactError.value)
                  : const SizedBox.shrink()),
              const SizedBox(height: 15),

              _label("GENDER"),
              DropDownWidget(child: Obx(() {
                final genderOptions = genders.map((e) => Map<String, dynamic>.from(e)).toList();
                Map<String, dynamic>? selectedValue;
                if (selectedGender.value != null) {
                  try {
                    selectedValue = genderOptions.firstWhere(
                            (element) => element['id'] == selectedGender.value!['id']);
                  } catch (_) {
                    selectedValue = null;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, dynamic>>(
                        value: selectedValue,
                        hint: const Text("Select Gender"),
                        isExpanded: true,
                        items: genderOptions.map((gender) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: gender,
                            child: Text(gender['name']),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            selectedGender.value = val;
                            gender.value = val['name'];
                            genderError.value = '';
                          }
                        },
                      ),
                    ),
                    Obx(() => genderError.value.isNotEmpty
                        ? _errorText(genderError.value)
                        : const SizedBox.shrink()),
                  ],
                );
              })),
              const SizedBox(height: 15),

              _label("AGE"),
              InputField(
                hintText: "Enter Age (Optional if Year selected)",
                controller: ageCtrl,
                inputType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(3),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  int? enteredAge = int.tryParse(value);
                  if (enteredAge != null && enteredAge > 0 && enteredAge < 150) {
                    age.value = enteredAge;
                    yearOfBirth.value = DateTime.now().year - enteredAge;
                  } else {
                    age.value = 0;
                  }
                },
              ),
              const SizedBox(height: 15),

              _label("YEAR OF BIRTH"),
              Obx(() {
                List<int> years = List.generate(150, (index) => DateTime.now().year - index);
                return DropDownWidget(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: yearOfBirth.value,
                      isExpanded: true,
                      hint: const Text("Select Year"),
                      items: years.map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (selectedYear) {
                        if (selectedYear != null) {
                          yearOfBirth.value = selectedYear;
                          int calculatedAge = DateTime.now().year - selectedYear;
                          age.value = calculatedAge;
                          ageCtrl.text = calculatedAge.toString();
                        }
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 25),

              CustomBtn(
                icon: IconlyLight.addUser,
                text: "Save Patient",
                onPressed: () async {
                  if (!_validateForm()) {
                    return;
                  }

                  int relationTypeId = selectedRelationType.value?['id'] ?? 1;
                  int genderId = selectedGender.value?['id'] ?? 1;

                  final patient = PatientModel(
                    patientId: cnicCtrl.text.trim(),
                    fullName: nameCtrl.text.trim(),
                    relationType: relationTypeId,
                    gender: genderId.toString(),
                    cnic: cnicCtrl.text.trim(),
                    contact: contactCtrl.text.trim(),
                    age: age.value,
                    fatherName: '',
                  );

                  try {
                    await controller.savePatient(patient);
                    if (Get.isRegistered<OpdController>()) {
                      await Get.find<OpdController>().refreshPatients();
                    }
                    Get.snackbar("Success", "Patient saved successfully");
                    _resetForm();
                  } catch (e) {
                    Get.snackbar("Error", "Failed to save patient: ${e.toString()}");
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void _resetForm() {
    nameCtrl.clear();
    cnicCtrl.clear();
    contactCtrl.clear();
    addressCtrl.clear();
    historyCtrl.clear();
    ageCtrl.clear();
    gender.value = '';
    selectedGender.value = null;
    age.value = 0;
    yearOfBirth.value = null;
    relationType.value = 'own';
    relationTypeError.value = '';
    genderError.value = '';
    nameError.value = '';
    cnicError.value = '';
    contactError.value = '';
    if (relationTypes.isNotEmpty) selectedRelationType.value = relationTypes.first;
    _formKey.currentState?.reset();
  }

  Widget _label(String text) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(text, style: subTitleTextStyle(color: Colors.black, size: 15)),
      const SizedBox(height: 5),
    ],
  );

  Widget _errorText(String text) => Padding(
    padding: const EdgeInsets.only(top: 4.0),
    child: Text(
      text,
      style: const TextStyle(color: Colors.red, fontSize: 12),
    ),
  );
}