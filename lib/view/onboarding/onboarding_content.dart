class OnboardingContent {
  String image;
  String title;
  String description;

  OnboardingContent({required this.image, required this.title, required this.description});
}

List<OnboardingContent> contents = [
  OnboardingContent(
    title: 'Digitize Patient Records',
    image: 'assets/icons/records.png',
    description: "Easily capture and store patient details including OPD, OBGYN, and medical history.",
  ),
  OnboardingContent(
    title: 'Offline Access & Sync',
    image: 'assets/icons/async.png',
    description: "Work seamlessly without internet and sync data securely when back online.",
  ),
  OnboardingContent(
    title: 'Track Health Services',
    image: 'assets/icons/prescription.png',
    description: "Manage prescriptions, family planning, and antenatal care in one unified system.",
  ),
];