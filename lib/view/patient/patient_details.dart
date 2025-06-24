import 'package:bhu/models/patient_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../../utils/helpers.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key, required this.patient});

  final PatientModel patient;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
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
        title: const Text("Patient Details"),
        actions: [
          IconButton.filledTonal(
            style: IconButton.styleFrom(backgroundColor: greyColor),
            onPressed: () => _showEditOptions(),
            icon: const Icon(IconlyLight.edit),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Patient Header Card
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      widget.patient.fullName.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patient.fullName,
                        style: titleTextStyle(size: 22),
                      ),
                      SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Unique Id: ${widget.patient.patientId}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.patient.gender == '1'
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.pink.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.patient.gender == '1' ? 'Male' : 'Female',
                              style: TextStyle(
                                fontSize: 14,
                                color: widget.patient.gender == '1' ? Colors.blue : Colors.pink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  icon: IconlyLight.call,
                  label: "Call",
                  color: Colors.green,
                  onTap: () => _makePhoneCall(widget.patient.contact),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildQuickAction(
                  icon: IconlyLight.message,
                  label: "WhatsApp",
                  color: Colors.teal,
                  onTap: () => _openWhatsApp(widget.patient.contact),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildQuickAction(
                  icon: IconlyLight.document,
                  label: "Medical History",
                  color: Colors.blue,
                  onTap: () => _viewMedicalHistory(),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Contact Information Section
          _buildSectionCard(
            title: "Contact Information",
            icon: IconlyBold.calling,
            children: [
              _buildInfoRow("Phone", widget.patient.contact, IconlyLight.call),
              /*_buildInfoRow("Emergency Contact", widget.patient.contact, IconlyLight.call),
              _buildInfoRow("Address", widget.patient.address, IconlyLight.location),*/
            ],
          ),

          SizedBox(height: 15),

          // Personal Information Section
          _buildSectionCard(
            title: "Personal Information",
            icon: IconlyBold.profile,
            children: [
              _buildInfoRow("CNIC", widget.patient.cnic, IconlyLight.document),
              _buildInfoRow("Relation Type", widget.patient.fatherName, IconlyLight.user2),
              _buildInfoRow("Date of Birth", "Not Available", IconlyLight.calendar),
              _buildInfoRow("Age", _calculateAge(), IconlyLight.timeCircle),
            ],
          ),

          SizedBox(height: 15),

          // Medical Information Section
          _buildSectionCard(
            title: "Medical Information",
            icon: IconlyBold.heart,
            children: [
              /*_buildInfoRow("Blood Group", getBloodGroupName(widget.patient.bloodGroup), Icons.water_drop_outlined),*/
              _buildInfoRow("Allergies", "None reported", IconlyLight.dangerCircle),
              _buildInfoRow("Chronic Conditions", "None reported", IconlyLight.activity),
              _buildInfoRow("Current Medications", "None", IconlyLight.category),
            ],
          ),

          SizedBox(height: 15),

          // Recent OPD Visits Section
          _buildSectionCard(
            title: "Recent OPD Visits",
            icon: IconlyBold.activity,
            children: [
              _buildOPDVisitTile("OPD-2024-001", "General Checkup", "15/01/2024"),
              _buildOPDVisitTile("OPD-2024-002", "Follow-up", "22/01/2024"),
            ],
          ),

          SizedBox(height: 15),

          // Emergency Contact Section
          _buildSectionCard(
            title: "Emergency Contact",
            icon: IconlyBold.calling,
            children: [
              _buildInfoRow("Name", "Not specified", IconlyLight.profile),
              _buildInfoRow("Relationship", "Not specified", IconlyLight.user2),
              _buildInfoRow("Contact", widget.patient.contact, IconlyLight.call),
            ],
          ),

          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor, size: 24),
                SizedBox(width: 10),
                Text(
                  title,
                  style: titleTextStyle(size: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 15),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: descriptionTextStyle(size: 14),
                ),
                Flexible(
                  child: Text(
                    value,
                    style: subTitleTextStyle(size: 14, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOPDVisitTile(String ticketNo, String reason, String date) {
    return InkWell(
      onTap: () {
        // Navigate to OPD visit details
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(IconlyLight.ticket, color: Colors.green, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticketNo,
                    style: titleTextStyle(size: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    reason,
                    style: descriptionTextStyle(size: 12),
                  ),
                ],
              ),
            ),
            Text(
              date,
              style: descriptionTextStyle(size: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(IconlyLight.edit, color: primaryColor),
              title: Text("Edit Patient Information"),
              onTap: () {
                Get.back();
                // Navigate to edit screen
              },
            ),
            ListTile(
              leading: Icon(IconlyLight.document, color: Colors.blue),
              title: Text("Update Medical Records"),
              onTap: () {
                Get.back();
                // Navigate to medical records
              },
            ),
            ListTile(
              leading: Icon(IconlyLight.delete, color: Colors.red),
              title: Text("Delete Patient", style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _confirmDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await url_launcher.launchUrl(launchUri);
  }

  void _openWhatsApp(String phoneNumber) async {
    final Uri whatsappUrl = Uri.parse('https://wa.me/$phoneNumber');
    if (await url_launcher.canLaunchUrl(whatsappUrl)) {
      await url_launcher.launchUrl(whatsappUrl);
    } else {
      Get.snackbar('Error', 'Could not open WhatsApp');
    }
  }

  void _viewMedicalHistory() {
    // Navigate to medical history screen
    Get.snackbar('Medical History', 'Feature coming soon!');
  }

  String _calculateAge() {
    // This is a placeholder - you should calculate from actual DOB
    return "Not Available";
  }

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        title: Text("Delete Patient"),
        content: Text("Are you sure you want to delete this patient record? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Delete patient logic
              Get.snackbar('Success', 'Patient deleted successfully');
              Get.back();
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
