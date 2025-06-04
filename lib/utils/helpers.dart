String getBloodGroupName(int bloodGroupId) {
  switch (bloodGroupId) {
    case 1: return 'A+';
    case 2: return 'A-';
    case 3: return 'B+';
    case 4: return 'B-';
    case 5: return 'AB+';
    case 6: return 'AB-';
    case 7: return 'O+';
    case 8: return 'O-';
    default: return 'Unknown';
  }
}