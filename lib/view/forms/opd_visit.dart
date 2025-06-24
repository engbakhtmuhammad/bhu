import 'package:bhu/view/forms/patient_registration.dart';
import 'package:bhu/widgets/input_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../controller/opd_controller.dart';
import '../../controller/prescription_controller.dart';
import '../../db/database_helper.dart';
import '../../models/patient_model.dart';
import '../../models/prescription_model.dart';
import '../../utils/constants.dart';
import '../../utils/style.dart';
import '../../widgets/input_field.dart';
import '../../widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';

class OpdVisitForm extends StatefulWidget {
  const OpdVisitForm({super.key});

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
    prescriptionController.filterDrugs('');
    // Generate OPD ticket number at form initialization
    _generateOpdTicketNumber();

    // Load prescription data immediately
    prescriptionController.loadMedicines().then((_) {
      // Force UI update after data is loaded
      if (mounted) setState(() {});
    });
  }

  // Add this method to generate the OPD ticket number
  Future<void> _generateOpdTicketNumber() async {
    if (controller.opdTicketNo.value.isEmpty) {
      final db = DatabaseHelper();
      final ticketNo = await db.generateOpdTicketNo();
      controller.opdTicketNo.value = ticketNo;
    }
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
        title: const Text("OPD/MCH Form"),
        actions: [
          IconButton.filledTonal(
            style: IconButton.styleFrom(
              backgroundColor: Colors.black, // Set to black
              foregroundColor: Colors.white, // Optional: to make the icon white for contrast
            ),
            onPressed: () => Get.to(PatientRegistrationForm()),
            icon: const Icon(IconlyLight.addUser),
          ),

          const SizedBox(width: 10),
        ],
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Obx(() {
                  return DropdownSearch<PatientModel>(
                    items: controller.filteredPatients,
                    itemAsString: (patient) => '${patient.fullName} ${patient.patientId} ',
                    selectedItem: controller.selectedPatient.value,
                    onChanged: (val) {
                      controller.selectedPatient.value = val;
                      if (val != null) {
                        controller.patientSearchController.clear();
                      }
                    },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: "Search patient by name, uniqueId, CNIC, or contact...",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    popupProps: PopupProps.dialog(
                      showSearchBox: true,
                      searchDelay: const Duration(milliseconds: 200),
                      dialogProps: DialogProps(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), // Slightly rounded for a modern dialog
                        ),
                        backgroundColor: Colors.white, // Clean white background
                      ),
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: "Search patients...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              controller.patientSearchController.clear();
                              controller.filterPatients('');
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        controller: controller.patientSearchController,
                      ),
                      itemBuilder: (context, patient, isSelected) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? primaryColor : Colors.grey.shade300,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.fullName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? primaryColor : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "CNIC: ${patient.cnic}",
                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            ),
                            Text(
                              "Contact: ${patient.contact}",
                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            ),
                            Text(
                              "Unique ID: ${patient.patientId}",
                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      emptyBuilder: (context, searchEntry) => const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No patients found",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    filterFn: (patient, filter) {
                      final search = filter.toLowerCase();
                      return patient.fullName.toLowerCase().contains(search) ||
                          patient.cnic.toLowerCase().contains(search) ||
                          patient.contact.toLowerCase().contains(search);
                    },
                  );
                }),
              ),
            ),


            _label("REASON FOR VISIT"),
            DropDownWidget(
              child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.reasonForVisit.value,
                      isExpanded: true,
                      items: ['MCH','General OPD']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => controller.setReasonForVisit(val!),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  )),
            ),

            // OBGYN Section (shown only if OBGYN is selected) - moved up
            Obx(() => controller.reasonForVisit.value == 'MCH'
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
            Obx(() => (controller.reasonForVisit.value == 'MCH' &&
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

  Color hexToColor(String hexColor, {double opacity = 1.0}) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor'; // Add alpha if not provided
    return Color(int.parse(hexColor, radix: 16)).withOpacity(opacity);
  }

  Widget _buildDiagnosisSection() {
    return Container(
      decoration: BoxDecoration(
        color: greyColor,
        borderRadius: BorderRadius.circular(containerRoundCorner),
      ),
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final diseasesByCategory = controller.diseasesByCategory;
        final entries = diseasesByCategory.entries.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(entries.length, (index) {
            final entry = entries[index];
            final diseaseColor = hexToColor(entry.key.color ?? '#999999', opacity: 0.12);
            final textColor = hexToColor(entry.key.color ?? '#999999');

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: diseaseColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: textColor.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Theme(
                data: ThemeData().copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    entry.key.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                  iconColor: textColor,
                  collapsedIconColor: textColor,
                  children: entry.value.map((subdisease) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: CheckboxListTile(
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: textColor,
                        value: controller.selectedDiseases.contains(subdisease.name),
                        onChanged: (val) => controller.toggleDiseaseSelection(
                          subdisease.name,
                          subdisease.id,
                          isSubdisease: true,
                          parentDiseaseId: subdisease.disease_id,
                        ),
                        title: Text(
                          subdisease.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }),
        );
      }),
    );
  }



  Widget _buildLabTestsSection() {
    return Container(
      decoration: BoxDecoration(
        color: greyColor,
        borderRadius: BorderRadius.circular(containerRoundCorner),
      ),
      padding: const EdgeInsets.all(15),
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 12),
            ...controller.labTestOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final test = entry.value;
              final isSelected = controller.selectedLabTests.contains(test);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.grey.shade300,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (val) => controller.toggleLabTestSelection(test, index + 1),
                      activeColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        test,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? primaryColor : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      }),
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
        _label("MCH VISIT TYPE"),
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
        _label("DRUG NAME"),
        Container(
          decoration: BoxDecoration(
            color: greyColor,
            borderRadius: BorderRadius.circular(containerRoundCorner),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Obx(() {
              // Ensure clean instance
              final drugOptions = prescriptionController.filteredDrugs.map((drug) {
                return Map<String, dynamic>.from(drug);
              }).toList();

              // Match selected item by id + name to prevent assertion error
              Map<String, dynamic>? selectedDrug;
              if (controller.selectedDrug.value != null) {
                final selectedId = controller.selectedDrug.value!['id'];
                final selectedName = controller.selectedDrug.value!['name'];

                for (var item in drugOptions) {
                  if (item['id'] == selectedId && item['name'] == selectedName) {
                    selectedDrug = item;
                    break;
                  }
                }
              }

              return DropdownSearch<Map<String, dynamic>>(
                items: drugOptions,
                itemAsString: (drug) => drug['name'] ?? '',
                selectedItem: selectedDrug,
                onChanged: (val) {
                  if (val != null) {
                    controller.selectedDrug.value = val;
                    controller.drugId.value = val['id'];
                    drugNameCtrl.text = val['name'];
                  }
                },
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: "Search & select medicine",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                popupProps: PopupProps.dialog(
                  showSearchBox: true,
                  searchDelay: Duration(milliseconds: 200),
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Search medicine...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  dialogProps: DialogProps(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(containerRoundCorner),
                    ),
                  ),
                  itemBuilder: (context, item, isSelected) => ListTile(
                    title: Text(
                      item['name'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected ? primaryColor : Colors.black,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: primaryColor)
                        : null,
                  ),
                  emptyBuilder: (context, searchEntry) => Center(
                    child: Text("No medicine found"),
                  ),
                ),
              );
            }),
          ),
        ),

        // Rest of your existing widgets remain the same...
        _label("QUANTITY"),
        InputField(
          hintText: "Number of units",
          controller: quantityCtrl,
          inputType: TextInputType.number,
        ),

        const SizedBox(height: 20),
        CustomBtn(
          icon: IconlyLight.plus,
          text: "Add Medicine",
          onPressed: () async {
            if (drugNameCtrl.text.trim().isEmpty) {
              Get.snackbar("Error", "Please enter drug name");
              return;
            }

            if (controller.opdTicketNo.value.isEmpty) {
              await _generateOpdTicketNumber();
            }

            final dbHelper = DatabaseHelper();
            final now = DateTime.now().toIso8601String();

            await dbHelper.addQuantityColumnToPrescriptions();

            final Map<String, dynamic> prescriptionMap = {
              'opdTicketNo': controller.opdTicketNo.value,
              'medicine': controller.drugId.value.toString(),
              'quantity': int.tryParse(quantityCtrl.text) ?? 1,
              'isSynced': 0,
              'created_at': now,
              'updated_at': now,
            };

            final db = await dbHelper.database;
            final newId = await db.insert('prescriptions', prescriptionMap);

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

            controller.prescriptions.add(newPrescription);

            controller.selectedDrug.value = null;
            controller.drugId.value = 0;
            drugNameCtrl.clear();
            dosageCtrl.clear();
            durationCtrl.clear();
            quantityCtrl.text = "1";
          },
        ),

        const SizedBox(height: 20),
        _label("ADDED MEDICINES"),
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
