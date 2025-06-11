import 'package:bhu/widgets/input_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../controller/opd_controller.dart';
import '../../controller/prescription_controller.dart';
import '../../models/disease_model.dart';
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
    });
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
            DropDownWidget(
              child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: controller.selectedPatient.value,
                      hint: Text("Select Patient"),
                      isExpanded: true,
                      items: controller.patients
                          .map((patient) => DropdownMenuItem(
                                value: patient,
                                child: Text("${patient.fullName} (${patient.patientId})"),
                              ))
                          .toList(),
                      onChanged: (val) => controller.selectedPatient.value = val,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  )),
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
                      onChanged: (val) => controller.reasonForVisit.value = val!,
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

            _label("FAMILY PLANNING ADVISED"),
            Obx(() => SwitchListTile(
                  value: controller.fpAdvised.value,
                  onChanged: (val) => controller.fpAdvised.value = val,
                  title: Text("Family Planning advised?"),
                )),

            Obx(() => controller.fpAdvised.value ? _buildFpSection() : SizedBox()),

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
                    onChanged: (val) => controller.obgynVisitType.value = val!,
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
            child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: controller.selectedAntenatalVisit.value,
                    isExpanded: true,
                    hint: Text("Select Antenatal Visits"),
                    items: controller.antenatalVisitOptionsWithIds
                        .map((visit) => DropdownMenuItem(
                              value: visit,
                              child: Text(visit['name']),
                            ))
                        .toList(),
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
                )),
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
        Obx(() => SwitchListTile(
              value: controller.ttAdvised.value,
              onChanged: (val) => controller.ttAdvised.value = val,
              title: Text("TT Advised/Vaccinated?"),
            )),
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
            child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: controller.selectedDeliveryMode.value,
                    isExpanded: true,
                    hint: Text("Select Delivery Mode"),
                    items: controller.deliveryModeOptionsWithIds
                        .map((mode) => DropdownMenuItem(
                              value: mode,
                              child: Text(mode['name']),
                            ))
                        .toList(),
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
                )),
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
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Map<String, dynamic>>(
                          value: controller.selectedBabyGender.value,
                          isExpanded: true,
                          hint: Text("Select Baby Gender"),
                          items: [
                            {'id': 1, 'name': 'Male'},
                            {'id': 2, 'name': 'Female'}
                          ].map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender['name'].toString()),
                              )).toList(),
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
                      ),
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
            child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: controller.selectedPostpartumStatus.value,
                    isExpanded: true,
                    hint: Text("Select Postpartum Status"),
                    items: controller.postpartumStatusOptionsWithIds
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status['name']),
                            ))
                        .toList(),
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
                )),
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
          onPressed: () {
            if (drugNameCtrl.text.trim().isEmpty) {
              Get.snackbar("Error", "Please enter drug name");
              return;
            }
            
            // Create a new prescription
            final newPrescription = PrescriptionModel(
              drugName: drugNameCtrl.text.trim(),
              id: controller.drugId.value, // Use the drug ID
              dosage: dosageCtrl.text.trim(),
              duration: durationCtrl.text.trim(),
              opdTicketNo: controller.selectedPatient.value?.patientId ?? '',
              quantity: int.tryParse(quantityCtrl.text) ?? 1,
            );
            
            // Add to the list
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
}
