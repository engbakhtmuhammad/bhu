import 'package:bhu/widgets/input_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../controller/opd_controller.dart';
import '../../utils/constants.dart';
import '../../utils/style.dart';
import '../../widgets/input_field.dart';
import '../../widgets/custom_btn.dart';

class OpdVisitForm extends StatelessWidget {
  final controller = Get.put(OpdController());

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

            // OBGYN Section (shown only if OBGYN is selected)
            Obx(() => controller.reasonForVisit.value == 'OBGYN' 
                ? _buildObgynSection() 
                : SizedBox()),

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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: diseasesByCategory.entries.map((entry) {
              return ExpansionTile(
                title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
                children: entry.value.map((disease) {
                  return CheckboxListTile(
                    title: Text(disease.name),
                    value: controller.selectedDiseases.contains(disease.name),
                    onChanged: (val) => controller.toggleDiseaseSelection(disease.name),
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
            children: controller.labTestOptions.map((test) {
              return CheckboxListTile(
                title: Text(test),
                value: controller.selectedLabTests.contains(test),
                onChanged: (val) => controller.toggleLabTestSelection(test),
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
                children: controller.fpOptions.map((fp) {
                  return CheckboxListTile(
                    title: Text(fp),
                    value: controller.selectedFpList.contains(fp),
                    onChanged: (val) => controller.toggleFpSelection(fp),
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
    final highRiskCtrl = TextEditingController(text: controller.highRiskIndicators.value);
    final parityCtrl = TextEditingController(text: controller.parity.value.toString());
    final gravidaCtrl = TextEditingController(text: controller.gravida.value.toString());
    final complicationsCtrl = TextEditingController(text: controller.complications.value);
    final facilityCtrl = TextEditingController(text: controller.deliveryFacility.value);

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
        DropDownWidget(
          child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.antenatalVisits.value,
                  isExpanded: true,
                  items: controller.antenatalVisitOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => controller.antenatalVisits.value = val!,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              )),
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
        InputField(
          hintText: "Enter high-risk indicators",
          controller: highRiskCtrl,
          onChanged: (val) => controller.highRiskIndicators.value = val,
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
          controller: complicationsCtrl,
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
          controller: facilityCtrl,
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
        DropDownWidget(
          child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.deliveryMode.value,
                  isExpanded: true,
                  items: controller.deliveryModeOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => controller.deliveryMode.value = val!,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              )),
        ),
      ],
    );
  }

  Widget _buildPostDeliverySection() {
    final postpartumCtrl = TextEditingController(text: controller.postpartumFollowup.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("POSTPARTUM FOLLOW-UP & NEONATAL HEALTH"),
        InputField(
          hintText: "Enter postpartum follow-up details",
          controller: postpartumCtrl,
          onChanged: (val) => controller.postpartumFollowup.value = val,
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
}