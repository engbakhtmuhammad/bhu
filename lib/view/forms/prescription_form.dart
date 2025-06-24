import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../controller/prescription_controller.dart';
import '../../utils/constants.dart';
import '../../utils/style.dart';
import '../../widgets/input_field.dart';
import '../../widgets/custom_btn.dart';

class PrescriptionForm extends StatefulWidget {
  final String? opdTicketNo;

  const PrescriptionForm({super.key, this.opdTicketNo});

  @override
  // ignore: library_private_types_in_public_api
  _PrescriptionFormState createState() => _PrescriptionFormState();
}

class _PrescriptionFormState extends State<PrescriptionForm> {
  final controller = Get.put(PrescriptionController());
  final drugNameCtrl = TextEditingController();
  final dosageCtrl = TextEditingController();
  final durationCtrl = TextEditingController();

  String? selectedDrug;

  @override
  void initState() {
    super.initState();
    // If opdTicketNo is provided, set it in controller
    if (widget.opdTicketNo != null) {
      controller.selectedOpdTicket.value = widget.opdTicketNo!;
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
            _label("SELECT OPD VISIT"),
            Container(
              decoration: BoxDecoration(
                color: greyColor,
                borderRadius: BorderRadius.circular(containerRoundCorner),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Obx(() => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedOpdTicket.value.isEmpty
                            ? null
                            : controller.selectedOpdTicket.value,
                        hint: Text("Select OPD Visit"),
                        isExpanded: true,
                        items: controller.opdVisits
                            .map((visit) => DropdownMenuItem(
                                  value: visit.opdTicketNo,
                                  child: Text(
                                      "${visit.opdTicketNo} - ${visit.patientId}"),
                                ))
                            .toList(),
                        onChanged: (val) {
                          controller.selectedOpdTicket.value = val ?? '';
                          controller.loadPrescriptions(val ?? '');
                        },
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    )),
              ),
            ),
            _label("DRUG NAME"),
            Container(
              decoration: BoxDecoration(
                color: greyColor,
                borderRadius: BorderRadius.circular(containerRoundCorner),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedDrug,
                    hint: Text("Select Drug"),
                    isExpanded: true,
                    items: controller.commonDrugs
                        .map((drug) => DropdownMenuItem(
                              value: drug,
                              child: Text(drug),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedDrug = val;
                        drugNameCtrl.text = val ?? '';
                      });
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
                  selectedDrug = null; // Clear dropdown selection when typing
                });
              },
            ),
            const SizedBox(height: 10),
            InputField(
              hintText: "Or enter custom dosage",
              controller: dosageCtrl,
            ),
            _label("DURATION OF MEDICATION"),
            InputField(
              hintText: "e.g., 7 days, 2 weeks",
              controller: durationCtrl,
            ),
            const SizedBox(height: 20),
            CustomBtn(
              icon: IconlyLight.plus,
              text: "Add Medicine",
              onPressed: () async {
                if (controller.selectedOpdTicket.value.isEmpty) {
                  Get.snackbar("Error", "Please select an OPD visit");
                  return;
                }

                if (drugNameCtrl.text.trim().isEmpty) {
                  Get.snackbar("Error", "Please enter drug name");
                  return;
                }

                await controller.addPrescription(
                  drugNameCtrl.text.trim(),
                  dosageCtrl.text.trim(),
                  durationCtrl.text.trim(),
                );

                // Clear form
                setState(() {
                  selectedDrug = null;
                  drugNameCtrl.clear();
                  dosageCtrl.clear();
                  durationCtrl.clear();
                });
              },
            ),
            const SizedBox(height: 30),
            _label("PRESCRIPTIONS FOR SELECTED VISIT"),
            Obx(() {
              final prescriptions = controller.currentPrescriptions;
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
                                "Dosage: ${prescription.dosage}",
                                style: descriptionTextStyle(size: 14),
                              ),
                              Text(
                                "Duration: ${prescription.duration}",
                                style: descriptionTextStyle(size: 14),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: prescription.id != null
                              ? () => controller
                                  .deletePrescription(prescription.id!)
                              : null,
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
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
}
