import 'package:bhu/widgets/input_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../controller/opd_controller.dart';
import '../../controller/prescription_controller.dart';
import '../../db/database_helper.dart';
import '../../models/disease_model.dart';
import '../../models/patient_model.dart';
import '../../models/prescription_model.dart';
import '../../utils/constants.dart';
import '../../utils/style.dart';
import '../../widgets/input_field.dart';
import '../../widgets/custom_btn.dart';

class OpdVisitForm extends StatefulWidget {
  @override
  _OpdVisitFormState createState() => _OpdVisitFormState();
}

class _OpdVisitFormState extends State<OpdVisitForm> {
  final controller = Get.put(OpdController());
  final prescriptionController = Get.put(PrescriptionController());
  
  final drugNameCtrl = TextEditingController();
  final dosageCtrl = TextEditingController();
  final durationCtrl = TextEditingController();
  final quantityCtrl = TextEditingController(text: "1");
  
  String? selectedDrug;
  
  @override
  void initState() {
    super.initState();
    print('Initializing OpdVisitForm');
    
    // Generate OPD ticket number at form initialization
    _generateOpdTicketNumber();
    
    // Load prescription data immediately
    prescriptionController.loadMedicines().then((_) {
      // Force UI update after data is loaded
      if (mounted) setState(() {});
    });
    
    // Add debug logging
    Future.delayed(Duration(seconds: 1), () {
      print('Drug list size: ${prescriptionController.commonDrugs.length}');
      print('Dosage list size: ${prescriptionController.medicineDosages.length}');
      print('Lab test options size: ${controller.labTestOptions.length}');
      print('FP options size: ${controller.fpOptions.length}');
      print('Current OPD Ticket Number: ${controller.opdTicketNo.value}');
    });
  }
  
  // Add this method to generate the OPD ticket number
  Future<void> _generateOpdTicketNumber() async {
    if (controller.opdTicketNo.value.isEmpty) {
      final db = DatabaseHelper();
      final ticketNo = await db.generateOpdTicketNo();
      controller.opdTicketNo.value = ticketNo;
      print('Generated OPD Ticket Number: ${controller.opdTicketNo.value}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _label("SELECT PATIENT"),
            Container(
              decoration: BoxDecoration(
                color: greyColor,
                borderRadius: BorderRadius.circular(containerRoundCorner),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Search field inside the dropdown container
                    TextField(
                      controller: controller.patientSearchController,
                      decoration: InputDecoration(
                        hintText: "Search patient by name, CNIC, or contact...",
                        hintStyle: descriptionTextStyle(),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: primaryColor),
                        suffixIcon: Obx(() => controller.searchText.value.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: primaryColor),
                                onPressed: () {
                                  controller.patientSearchController.clear();
                                  controller.filterPatients('');
                                },
                              )
                            : SizedBox()),
                      ),
                      onChanged: (value) => controller.filterPatients(value),
                    ),

                    // Divider between search and dropdown
                    Divider(color: Colors.grey[300], height: 1),

                    // Patient dropdown
                    Obx(() {
                      // Find th matching patient in filtered list to avoid assertion error
                      PatientModel? selectedValue;
                      if (controller.selectedPatient.value != null) {
                        for (var patient in controller.filteredPatients) {
                          if (patient.patientId == controller.selectedPatient.value!.patientId) {
                            selectedValue = patient;
                            break;
                          }
                        }
                      }

                      return DropdownButtonHideUnderline(
                        child: DropdownButton<PatientModel>(
                          value: selectedValue,
                          hint: Text(controller.filteredPatients.isEmpty
                              ? "No patients found"
                              : "Select Patient (${controller.filteredPatients.length} found)"),
                          isExpanded: true,
                          items: controller.filteredPatients
                              .map((patient) => DropdownMenuItem<PatientModel>(
                                    key: ValueKey("patient_${patient.patientId}"),
                                    value: patient,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          patient.fullName,
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "CNIC: ${patient.cnic} | Contact: ${patient.contact}",
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (PatientModel? val) {
                            controller.selectedPatient.value = val;
                            // Clear search when patient is selected
                            controller.patientSearchController.clear();
                            controller.filterPatients('');
                          },
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            _label("REASON FOR VISIT"),
            DropDownWidget(
              child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.reasonForVisit.value,
                      isExpanded: true,
                      items: ['OBGYN','General OPD']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => controller.setReasonForVisit(val!),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  )),
            ),

            // OBGYN Section (shown only if OBGYN is selected) - moved up
            Obx(() => controller.reasonForVisit.value == 'OBGYN' 
                ? _buildObgynSection() 
                : SizedBox()),

            _label("FOLLOW-UP"),
            Obx(() => SwitchListTile(
                  value: controller.isFollowUp.value,
                  onChanged: (val) => controller.isFollowUp.value = val,
                  title: Text("Is this a follow-up visit?"),
                )),

            // Diagnosis Selection
            _label("DIAGNOSIS"),
            _buildDiagnosisSection(),

            // Lab Tests
            _label("LAB TESTS ORDERED"),
            _buildLabTestsSection(),

            _label("REFERRED"),
            Obx(() => SwitchListTile(
                  value: controller.isReferred.value,
                  onChanged: (val) => controller.isReferred.value = val,
                  title: Text("Patient referred?"),
                )),

            _label("FOLLOW-UP ADVISED"),
            Obx(() => Column(
                  children: [
                    SwitchListTile(
                      value: controller.followUpAdvised.value,
                      onChanged: (val) => controller.followUpAdvised.value = val,
                      title: Text("Follow-up advised?"),
                    ),
                    if (controller.followUpAdvised.value)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child:                         Row(
                          children: [
                            Text("Days: "),
                            Expanded(
                              child: Slider(
                                value: controller.followUpDays.value < 1 ? 1.0 : controller.followUpDays.value.toDouble(),
                                min: 1,
                                max: 30,
                                divisions: 29,
                                label: controller.followUpDays.value.toString(),
                                onChanged: (val) => controller.followUpDays.value = val.toInt(),
                              ),
                            ),
                            Text("${controller.followUpDays.value} days"),
                          ],
                        ),
                      ),
                  ],
                )),

            // Family Planning section - only show for OBGYN Post-Delivery visits
            Obx(() => (controller.reasonForVisit.value == 'OBGYN' &&
                       controller.obgynVisitType.value == 'Post-Delivery')
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("FAMILY PLANNING ADVISED"),
                      SwitchListTile(
                        value: controller.fpAdvised.value,
                        onChanged: (val) => controller.fpAdvised.value = val,
                        title: Text("Family Planning advised?"),
                      ),
                      controller.fpAdvised.value ? _buildFpSection() : SizedBox(),
                    ],
                  )
                : SizedBox()),

            // Prescription Section
            _label("PRESCRIPTIONS"),
            _buildPrescriptionSection(),

            const SizedBox(height: 20),
            CustomBtn(
              icon: IconlyLight.addUser,
              text: "Save OPD Visit",
              onPressed: () => controller.saveOpdVisit(),
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
        const SizedBox(height: 15),
        Text(text, style: subTitleTextStyle(color: Colors.black, size: 15)),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildDiagnosisSection() {
    return Container(
      decoration: BoxDecoration(
        color: greyColor,
        borderRadius: BorderRadius.circular(containerRoundCorner),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Obx(() {
          final diseasesByCategory = controller.diseasesByCategory;
          // Filter out any "Uncategorized" category
          final filteredCategories = Map<String, List<SubDiseaseModel>>.from(diseasesByCategory)
            ..removeWhere((key, value) => key.toLowerCase() == "uncategorized" || value.isEmpty);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: filteredCategories.entries.map((entry) {
              return ExpansionTile(
                title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
                children: entry.value.map((subdisease) {
                  return CheckboxListTile(
                    title: Text(subdisease.name),
                    value: controller.selectedDiseases.contains(subdisease.name),
                    onChanged: (val) => controller.toggleDiseaseSelection(
                      subdisease.name, 
                      subdisease.id,
                      isSubdisease: true,
                      parentDiseaseId: subdisease.disease_id
                    ),
                    dense: true,
                  );
                }).toList(),
              );
            }).toList(),
          );
        }),
      ),
    );
  }

  Widget _buildLabTestsSection() {
    return DropDownWidget(
      child: Obx(() => Column(
            children: controller.labTestOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final test = entry.value;
              return CheckboxListTile(
                title: Text(test),
                value: controller.selectedLabTests.contains(test),
                onChanged: (val) => controller.toggleLabTestSelection(test, index + 1), // Use index+1 as ID
                dense: true,
              );
            }).toList(),
          )),
    );
  }

  Widget _buildFpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("FAMILY PLANNING LIST"),
        DropDownWidget(
          child: Obx(() => Column(
                children: controller.fpOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final fp = entry.value;
                  return CheckboxListTile(
                    title: Text(fp),
                    value: controller.selectedFpList.contains(fp),
                    onChanged: (val) => controller.toggleFpSelection(fp, index + 1), // Use index+1 as ID
                    dense: true,
                  );
                }).toList(),
              )),
        ),
      ],
    );
  }

  Widget _buildObgynSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("OBGYN VISIT TYPE"),
        Container(
          decoration: BoxDecoration(
            color: greyColor,
            borderRadius: BorderRadius.circular(containerRoundCorner),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.obgynVisitType.value,
                    isExpanded: true,
                    items: ['Pre-Delivery', 'Delivery', 'Post-Delivery']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => controller.setObgynVisitType(val!),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                )),
          ),
        ),

        // Pre-Delivery Section
        Obx(() => controller.obgynVisitType.value == 'Pre-Delivery' 
            ? _buildPreDeliverySection() 
            : SizedBox()),

        // Delivery Section
        Obx(() => controller.obgynVisitType.value == 'Delivery' 
            ? _buildDeliverySection() 
            : SizedBox()),

        // Post-Delivery Section
        Obx(() => controller.obgynVisitType.value == 'Post-Delivery' 
            ? _buildPostDeliverySection() 
            : SizedBox()),
      ],
    );
  }

  Widget _buildPreDeliverySection() {
    // Initialize controllers with current values
    final gestationalAgeCtrl = TextEditingController(text: controller.gestationalAge.value.toString());
    final fundalHeightCtrl = TextEditingController(text: controller.fundalHeight.value.toString());
    final parityCtrl = TextEditingController(text: controller.parity.value.toString());
    final gravidaCtrl = TextEditingController(text: controller.gravida.value.toString());
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("ANC CARD AVAILABLE"),
        Obx(() => SwitchListTile(
              value: controller.ancCardAvailable.value,
              onChanged: (val) => controller.ancCardAvailable.value = val,
              title: Text("ANC Card Available?"),
            )),

        _label("GESTATIONAL AGE (MONTHS)"),
        InputField(
          hintText: "Enter gestational age",
          inputType: TextInputType.number,
          controller: gestationalAgeCtrl,
          onChanged: (val) {
            int age = int.tryParse(val) ?? 1;
            controller.gestationalAge.value = age < 1 ? 1 : age;
          },
        ),

        _label("ANTENATAL VISITS"),
        Container(
          decoration: BoxDecoration(
            color: greyColor,
            borderRadius: BorderRadius.circular(containerRoundCorner),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Obx(() {
              // Create unique instances for this dropdown
              final antenatalOptions = controller.antenatalVisitOptionsWithIds.map((visit) {
                return Map<String, dynamic>.from(visit);
              }).toList();

              // Find matching value
              Map<String, dynamic>? selectedValue;
              if (controller.selectedAntenatalVisit.value != null) {
                final selectedId = controller.selectedAntenatalVisit.value!['id'];
                for (var item in antenatalOptions) {
                  if (item['id'] == selectedId) {
                    selectedValue = item;
                    break;
                  }
                }
              }

              return DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  value: selectedValue,
                  isExpanded: true,
                  hint: Text("Select Antenatal Visits"),
                  items: antenatalOptions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final visit = entry.value;
                    return DropdownMenuItem<Map<String, dynamic>>(
                      key: ValueKey("antenatal_${visit['id']}_$index"),
                      value: visit,
                      child: Text(visit['name']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedAntenatalVisit.value = val;
                      controller.antenatalVisitId.value = val['id'];
                      controller.antenatalVisits.value = val['name'];
                    }
                  },
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              );
            }),
          ),
        ),

        _label("FUNDAL HEIGHT"),
        InputField(
          hintText: "Enter fundal height (cm)",
          inputType: TextInputType.number,
          controller: fundalHeightCtrl,
          onChanged: (val) {
            int height = int.tryParse(val) ?? 1;
            controller.fundalHeight.value = height < 1 ? 1 : height;
          },
        ),

        _label("ULTRASOUND REPORTS"),
        Obx(() => SwitchListTile(
              value: controller.ultrasoundReports.value,
              onChanged: (val) => controller.ultrasoundReports.value = val,
              title: Text("Ultrasound Reports Available?"),
            )),

        _label("HIGH-RISK PREGNANCY INDICATORS"),
        Container(
          decoration: BoxDecoration(
            color: greyColor,
            borderRadius: BorderRadius.circular(containerRoundCorner),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: controller.selectedPregnancyIndicator.value,
                    isExpanded: true,
                    hint: Text("Select High-Risk Indicator"),
                    items: controller.pregnancyIndicatorsWithIds
                        .map((indicator) => DropdownMenuItem(
                              value: indicator,
                              child: Text(indicator['name']),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedPregnancyIndicator.value = val;
                        controller.pregnancyIndicatorId.value = val['id'];
                        controller.highRiskIndicators.value = val['name'];
                      }
                    },
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                )),
          ),
        ),

        _label("PARITY"),
        InputField(
          hintText: "Enter parity",
          inputType: TextInputType.number,
          controller: parityCtrl,
          onChanged: (val) {
            int parity = int.tryParse(val) ?? 1;
            controller.parity.value = parity < 1 ? 1 : parity;
          },
        ),

        _label("GRAVIDA"),
        InputField(
          hintText: "Enter gravida",
          inputType: TextInputType.number,
          controller: gravidaCtrl,
          onChanged: (val) {
            int gravida = int.tryParse(val) ?? 1;
            controller.gravida.value = gravida < 1 ? 1 : gravida;
          },
        ),

        _label("COMPLICATIONS"),
        InputField(
          hintText: "Enter complications",
          controller: TextEditingController(text: controller.complications.value),
          onChanged: (val) => controller.complications.value = val,
        ),

        _label("EXPECTED DELIVERY DATE"),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now().add(Duration(days: 90)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (date != null) {
              controller.expectedDeliveryDate.value = date;
            }
          },
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: greyColor,
              borderRadius: BorderRadius.circular(containerRoundCorner),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today),
                SizedBox(width: 10),
                Obx(() => Text(
                      controller.expectedDeliveryDate.value != null
                          ? "${controller.expectedDeliveryDate.value!.day}/${controller.expectedDeliveryDate.value!.month}/${controller.expectedDeliveryDate.value!.year}"
                          : "Select Expected Delivery Date",
                    )),
              ],
            ),
          ),
        ),

        _label("DELIVERY FACILITY"),
        InputField(
          hintText: "Enter delivery facility",
          controller: TextEditingController(text: controller.deliveryFacility.value),
          onChanged: (val) => controller.deliveryFacility.value = val,
        ),

        _label("REFERRED TO HIGHER TIER FACILITY"),
        Obx(() => SwitchListTile(
              value: controller.referredToHigherTier.value,
              onChanged: (val) => controller.referredToHigherTier.value = val,
              title: Text("Referred to Higher Tier Facility?"),
            )),

        _label("TT ADVISED/VACCINATED"),
        Container(
          decoration: BoxDecoration(
            color: greyColor,
            borderRadius: BorderRadius.circular(containerRoundCorner),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Obx(() {
              // Create unique instances for this dropdown to avoid conflicts
              final ttOptions = controller.ttAdvisedOptionsWithIds.map((option) {
                return Map<String, dynamic>.from(option);
              }).toList();

              // Find the matching item based on ID to avoid assertion error
              Map<String, dynamic>? selectedValue;
              if (controller.selectedTTAdvised.value != null) {
                final selectedId = controller.selectedTTAdvised.value!['id'];
                final selectedName = controller.selectedTTAdvised.value!['name'];

                for (var item in ttOptions) {
                  if (item['id'] == selectedId && item['name'] == selectedName) {
                    selectedValue = item;
                    break;
                  }
                }
              }

              return DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  value: selectedValue,
                  isExpanded: true,
                  hint: Text("Select TT Advised Option"),
                  items: ttOptions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    return DropdownMenuItem<Map<String, dynamic>>(
                      key: ValueKey("tt_advised_main_${option['id']}_${option['name']}_$index"),
                      value: option,
                      child: Text(option['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (Map<String, dynamic>? newValue) {
                    if (newValue != null) {
                      controller.selectedTTAdvised.value = newValue;
                      controller.ttAdvisedId.value = newValue['id'] ?? 0;
                    }
                  },
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("DELIVERY MODE"),
        Container(
          decoration: BoxDecoration(
            color: greyColor,
            borderRadius: BorderRadius.circular(containerRoundCorner),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Obx(() {
              // Create unique instances for this dropdown
              final deliveryOptions = controller.deliveryModeOptionsWithIds.map((mode) {
                return Map<String, dynamic>.from(mode);
              }).toList();

              // Find the matching item based on ID
              Map<String, dynamic>? selectedValue;
              if (controller.selectedDeliveryMode.value != null) {
                final selectedId = controller.selectedDeliveryMode.value!['id'];
                for (var item in deliveryOptions) {
                  if (item['id'] == selectedId) {
                    selectedValue = item;
                    break;
                  }
                }
              }

              // Create dropdown items with unique keys
              final items = deliveryOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final mode = entry.value;
                return DropdownMenuItem<Map<String, dynamic>>(
                  key: ValueKey("delivery_${mode['id']}_$index"),
                  value: mode,
                  child: Text(mode['name']),
                );
              }).toList();
              
              return DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  value: selectedValue,
                  isExpanded: true,
                  hint: Text("Select Delivery Mode"),
                  items: items,
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedDeliveryMode.value = val;
                      controller.deliveryModeId.value = val['id'];
                      controller.deliveryMode.value = val['name'];
                    }
                  },
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              );
            }),
          ),
        ),
        
        // Show baby details only for normal delivery or neonatal death
        Obx(() => (controller.deliveryMode.value.contains('Normal Delivery') || 
                   controller.deliveryMode.value.contains('Neonatal Death')) 
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("BABY GENDER"),
                  Container(
                    decoration: BoxDecoration(
                      color: greyColor,
                      borderRadius: BorderRadius.circular(containerRoundCorner),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Obx(() {
                        // Create unique instances for this dropdown
                        final genderOptions = controller.genderOptions.map((gender) {
                          return Map<String, dynamic>.from(gender);
                        }).toList();

                        // Find the matching item based on ID
                        Map<String, dynamic>? selectedValue;
                        if (controller.selectedBabyGender.value != null) {
                          final selectedId = controller.selectedBabyGender.value!['id'];
                          for (var item in genderOptions) {
                            if (item['id'] == selectedId) {
                              selectedValue = item;
                              break;
                            }
                          }
                        }

                        // Create dropdown items with unique keys
                        final items = genderOptions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final gender = entry.value;
                          return DropdownMenuItem<Map<String, dynamic>>(
                            key: ValueKey("baby_gender_${gender['id']}_$index"),
                            value: gender,
                            child: Text(gender['name'].toString()),
                          );
                        }).toList();
                        
                        return DropdownButtonHideUnderline(
                          child: DropdownButton<Map<String, dynamic>>(
                            value: selectedValue,
                            isExpanded: true,
                            hint: Text("Select Baby Gender"),
                            items: items,
                            onChanged: (val) {
                              if (val != null) {
                                controller.selectedBabyGender.value = val;
                                controller.babyGenderId.value = val['id'];
                                controller.babyGender.value = val['name'];
                              }
                            },
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  _label("BABY WEIGHT (GRAMS)"),
                  InputField(
                    hintText: "Enter baby weight in grams",
                    inputType: TextInputType.number,
                    controller: TextEditingController(text: controller.babyWeight.value > 0 
                        ? controller.babyWeight.value.toString() 
                        : ""),
                    onChanged: (val) {
                      int weight = int.tryParse(val) ?? 0;
                      controller.babyWeight.value = weight;
                    },
                  ),
                ],
              )
            : SizedBox()),
      ],
    );
  }

  Widget _buildPostDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("POSTPARTUM"),
        Container(
          decoration: BoxDecoration(
            color: greyColor,
            borderRadius: BorderRadius.circular(containerRoundCorner),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Obx(() {
              // Create unique instances for this dropdown
              final postpartumOptions = controller.postpartumStatusOptionsWithIds.map((status) {
                return Map<String, dynamic>.from(status);
              }).toList();

              // Find matching value
              Map<String, dynamic>? selectedValue;
              if (controller.selectedPostpartumStatus.value != null) {
                final selectedId = controller.selectedPostpartumStatus.value!['id'];
                for (var item in postpartumOptions) {
                  if (item['id'] == selectedId) {
                    selectedValue = item;
                    break;
                  }
                }
              }

              return DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  value: selectedValue,
                  isExpanded: true,
                  hint: Text("Select Postpartum Status"),
                  items: postpartumOptions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final status = entry.value;
                    return DropdownMenuItem<Map<String, dynamic>>(
                      key: ValueKey("postpartum_${status['id']}_$index"),
                      value: status,
                      child: Text(status['name']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedPostpartumStatus.value = val;
                      controller.postpartumStatusId.value = val['id'];
                      controller.postpartumFollowup.value = val['name'];
                    }
                  },
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              );
            }),
          ),
        ),

        _label("FAMILY PLANNING SERVICES"),
        DropDownWidget(
          child: Obx(() => Column(
                children: controller.fpOptions.map((service) {
                  return CheckboxListTile(
                    title: Text(service),
                    value: controller.familyPlanningServices.contains(service),
                    onChanged: (val) => controller.toggleFamilyPlanningService(service),
                    dense: true,
                  );
                }).toList(),
              )),
        ),
      ],
    );
  }

  Widget _buildPrescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drug selection
        _label("DRUG NAME"),
        Container(
          decoration: BoxDecoration(
            color: greyColor,
            borderRadius: BorderRadius.circular(containerRoundCorner),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: controller.selectedDrug.value,
                hint: Text("Select Drug"),
                isExpanded: true,
                items: prescriptionController.medicinesWithIds
                    .map((drug) => DropdownMenuItem(
                          value: drug,
                          child: Text(drug['name']),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      controller.selectedDrug.value = val;
                      controller.drugId.value = val['id'];
                      drugNameCtrl.text = val['name'];
                    });
                  }
                },
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 10),
        InputField(
          hintText: "Or enter custom drug name",
          controller: drugNameCtrl,
          onChanged: (val) {
            setState(() {
              controller.selectedDrug.value = null; // Clear dropdown selection when typing
              controller.drugId.value = 0; // Reset drug ID when custom name is entered
            });
          },
        ),

        // _label("DOSAGE"),
        // Container(
        //   decoration: BoxDecoration(
        //     color: greyColor,
        //     borderRadius: BorderRadius.circular(containerRoundCorner),
        //   ),
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
        //     child: DropdownButtonHideUnderline(
        //       child: DropdownButton<String>(
        //         value: dosageCtrl.text.isEmpty ? null : dosageCtrl.text,
        //         hint: Text("Select Dosage"),
        //         isExpanded: true,
        //         items: prescriptionController.medicineDosages
        //             .map((dosage) => DropdownMenuItem(
        //                   value: dosage,
        //                   child: Text(dosage),
        //                 ))
        //             .toList(),
        //         onChanged: (val) {
        //           setState(() {
        //             dosageCtrl.text = val ?? '';
        //           });
        //         },
        //         dropdownColor: Colors.white,
        //         borderRadius: BorderRadius.circular(8.0),
        //       ),
        //     ),
        //   ),
        // ),

        // const SizedBox(height: 10),
        // InputField(
        //   hintText: "Or enter custom dosage",
        //   controller: dosageCtrl,
        // ),

        // _label("DURATION OF MEDICATION"),
        // InputField(
        //   hintText: "e.g., 7 days, 2 weeks",
        //   controller: durationCtrl,
        // ),
        
        _label("QUANTITY"),
        InputField(
          hintText: "Number of units",
          controller: quantityCtrl,
          inputType: TextInputType.number,
        ),

        const SizedBox(height: 20),
        CustomBtn(
          icon: IconlyLight.plus,
          text: "Add Prescription",
          onPressed: () async {
            if (drugNameCtrl.text.trim().isEmpty) {
              Get.snackbar("Error", "Please enter drug name");
              return;
            }

            // Ensure we have a valid OPD ticket number
            if (controller.opdTicketNo.value.isEmpty) {
              await _generateOpdTicketNumber();
            }

            // Save to database
            final dbHelper = DatabaseHelper();
            final now = DateTime.now().toIso8601String();
            
            // Ensure the quantity column exists
            await dbHelper.addQuantityColumnToPrescriptions();
            
            // Create a map that matches the database schema
            final Map<String, dynamic> prescriptionMap = {
              // Don't include id to let SQLite auto-generate it
              'medicine': controller.drugId.value.toString(),
              'dosage': dosageCtrl.text.trim(),
              'duration': durationCtrl.text.trim(),
              'opdTicketNo': controller.opdTicketNo.value, // Use the generated ticket number
              'quantity': int.tryParse(quantityCtrl.text) ?? 1,
              'is_synced': 0,
              'created_at': now,
              'updated_at': now,
            };
            
            // Debug log
            print('Adding prescription with OPD Ticket: ${controller.opdTicketNo.value}');
            
            // Insert into database
            final db = await dbHelper.database;
            final newId = await db.insert('prescriptions', prescriptionMap);
            print('Inserted prescription with ID: $newId');
            
            // Create a new prescription with the ID from the database
            final newPrescription = PrescriptionModel(
              id: newId,
              drugName: drugNameCtrl.text.trim(),
              dosage: dosageCtrl.text.trim(),
              duration: durationCtrl.text.trim(),
              opdTicketNo: controller.opdTicketNo.value,
              quantity: int.tryParse(quantityCtrl.text) ?? 1,
              createdAt: now,
              updatedAt: now,
            );
            
            // Add to the controller's list
            controller.prescriptions.add(newPrescription);
            
            // Clear form
            setState(() {
              controller.selectedDrug.value = null;
              controller.drugId.value = 0;
              drugNameCtrl.clear();
              dosageCtrl.clear();
              durationCtrl.clear();
              quantityCtrl.text = "1";
            });
          },
        ),
        
        const SizedBox(height: 20),
        _label("ADDED PRESCRIPTIONS"),
        Obx(() {
          final prescriptions = controller.prescriptions;
          if (prescriptions.isEmpty) {
            return Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: greyColor,
                borderRadius: BorderRadius.circular(containerRoundCorner),
              ),
              child: Text(
                "No prescriptions added yet",
                style: descriptionTextStyle(),
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            children: prescriptions.map((prescription) {
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(containerRoundCorner),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prescription.drugName,
                            style: titleTextStyle(size: 16),
                          ),
                          // Text(
                          //   "Dosage: ${prescription.dosage}",
                          //   style: descriptionTextStyle(size: 14),
                          // ),
                          // Text(
                          //   "Duration: ${prescription.duration}",
                          //   style: descriptionTextStyle(size: 14),
                          // ),
                          Text(
                            "Quantity: ${prescription.quantity}",
                            style: descriptionTextStyle(size: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.prescriptions.remove(prescription),
                      icon: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  bool _mapEquals(Map<String, dynamic>? map1, Map<String, dynamic>? map2) {
    if (map1 == null || map2 == null) return map1 == map2;
    if (map1['id'] != map2['id']) return false;
    if (map1['name'] != map2['name']) return false;
    return true;
  }
}
