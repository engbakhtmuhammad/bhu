import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import 'package:bhu/view/auth/signin.dart';
import 'package:bhu/widgets/custom_btn.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import 'package:get/get.dart';
import '../../controller/auth_controller.dart';

import '../../services/api_service.dart';
import '../../widgets/input_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();

  // Text controllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController designationController = TextEditingController();

  // Dropdown values
  int selectedHealthFacilityId = 1;
  final int selectedUserRoleId = 2; // Default to Medical Officer, no need for selection

  // Health facility options from API
  final RxList<Map<String, dynamic>> healthFacilities = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchHealthFacilities();
  }

  Future<void> _fetchHealthFacilities() async {
    isLoading.value = true;
    try {
      final ApiService apiService = ApiService();
      final response = await apiService.getHealthFacilities();
      
      if (response.success && response.data != null) {
        healthFacilities.value = response.data!.map((facility) => {
          'id': facility['id'],
          'name': facility['name'],
        }).toList();
        
        if (healthFacilities.isNotEmpty) {
          selectedHealthFacilityId = healthFacilities[0]['id'];
        }
      } else {
        // Fallback to default if API fails
        healthFacilities.value = [
          {'id': 1, 'name': 'Primary Health Center'},
          {'id': 2, 'name': 'District Hospital'},
        ];
      }
    } catch (e) {
      debugPrint('Error fetching health facilities: $e');
      // Fallback to default if API fails
      healthFacilities.value = [
        {'id': 1, 'name': 'Primary Health Center'},
        {'id': 2, 'name': 'District Hospital'},
      ];
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    cnicController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    designationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final success = await authController.registerUser(
      userName: nameController.text.trim(),
      email: emailController.text.trim(),
      cnic: cnicController.text.trim(),
      designation: designationController.text.trim(),
      password: passwordController.text,
      phoneNo: phoneController.text.trim(),
      healthFacilityId: selectedHealthFacilityId,
      
      userRoleId: selectedUserRoleId, // Fixed as 2
    );

    if (success) {
      // Navigate back to login screen
      Get.off(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: blackColor,
        leading: IconButton.filledTonal(
          style: IconButton.styleFrom(backgroundColor: greyColor),
          onPressed: () => Get.back(),
          icon: Icon(IconlyLight.arrowLeft2),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Sign Up",
            style: titleTextStyle(size: 24, color: whiteColor),
          ),
          Text(
            "Please sign up to get started",
            style: subTitleTextStyle(color: greyColor),
          ),
          SizedBox(height: defaultPadding * 2),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(defaultPadding),
              width: double.infinity,
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: defaultPadding),

                      // Full Name Field
                      Text(
                        "FULL NAME",
                        style: subTitleTextStyle(color: blackColor, size: 15),
                      ),
                      InputField(
                        hintText: "Enter your full name",
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // CNIC Field
                      Text(
                        "CNIC",
                        style: subTitleTextStyle(color: blackColor, size: 15),
                      ),
                      InputField(
                        hintText: "Enter your CNIC (e.g., 3520112345678)",
                        controller: cnicController, // Keeping the same controller for backend compatibility
                        inputType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your CNIC';
                          }
                          if (value.length != 13) {
                            return 'CNIC must be exactly 13 digits';
                          }
                          if (!RegExp(r'^\d+$').hasMatch(value)) {
                            return 'CNIC must contain only digits';
                          }
                          return null;
                        },
                        // 👇 Add this inside your InputField widget (modify your InputField to support it)
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(13), // Set max length to 13
                          FilteringTextInputFormatter.digitsOnly, // Only allow numeric input
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "EMAIL",
                        style: subTitleTextStyle(color: blackColor, size: 15),
                      ),
                      InputField(
                        hintText: "Enter your email",
                        controller: emailController, // We'll keep using emailController for backend compatibility
                        inputType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                            final regex = RegExp(emailPattern);
                            if (!regex.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Phone Field
                      Text(
                        "PHONE NUMBER",
                        style: subTitleTextStyle(color: blackColor, size: 15),
                      ),
                      InputField(
                        hintText: "03000000000",
                        controller: phoneController,
                        inputType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length < 11) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Designation Field
                      Text(
                        "DESIGNATION",
                        style: subTitleTextStyle(color: blackColor, size: 15),
                      ),
                      InputField(
                        hintText: "e.g., Medical Officer",
                        controller: designationController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your designation';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Health Facility Dropdown
                      Text(
                        "HEALTH FACILITY",
                        style: subTitleTextStyle(color: blackColor, size: 15),
                      ),
                      Obx(() => Container(
                        decoration: BoxDecoration(
                          color: greyColor,
                          borderRadius: BorderRadius.circular(containerRoundCorner),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: isLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownButtonHideUnderline(
                                
                                  child: DropdownButton<int>(
                                    dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                                    value: selectedHealthFacilityId,
                                    hint: Text('Select Health Facility'),
                                    isExpanded: true,
                                    items: healthFacilities.map((facility) {
                                      return DropdownMenuItem<int>(
                                        value: facility['id'],
                                        child: Text(facility['name']),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedHealthFacilityId = value!;
                                      });
                                    },
                                  ),
                                ),
                        ),
                      )),
                      const SizedBox(height: 15),

                      // User Role Dropdown
                //       Text(
                //         "USER ROLE",
                //         style: subTitleTextStyle(color: blackColor, size: 15),
                //       ),
                //       Container(
                // decoration: BoxDecoration(
                //   color: greyColor,
                //   borderRadius: BorderRadius.circular(containerRoundCorner),
                // ),
                // child: Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                //         child: DropdownButtonHideUnderline(
                //           child: DropdownButton<int>(
                //             value: selectedUserRoleId,
                //             hint: Text('Select User Role'),
                //             isExpanded: true,
                //             items: userRoles.map((role) {
                //               return DropdownMenuItem<int>(
                //                 value: role['id'],
                //                 child: Text(role['name']),
                //               );
                //             }).toList(),
                //             onChanged: (value) {
                //               setState(() {
                //                 selectedUserRoleId = value!;
                //               });
                //             },
                //           ),
                //         ),
                //       )),
                //       const SizedBox(height: 15),

                      // Password Field
                      Text(
                        "PASSWORD",
                        style: subTitleTextStyle(color: blackColor, size: 15),
                      ),
                      InputField(
                        hintText: "Enter password",
                        controller: passwordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Confirm Password Field
                      Text(
                        "CONFIRM PASSWORD",
                        style: subTitleTextStyle(color: blackColor, size: 15),
                      ),
                      InputField(
                        hintText: "Confirm password",
                        controller: confirmPasswordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      // Sign Up Button
                      Obx(() {
                        if (authController.isLoading.value) {
                          return Container(
                            height: 50,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            ),
                          );
                        }
                        return CustomBtn(
                          icon: IconlyLight.login,
                          text: "Sign Up",
                          onPressed: _handleSignup,
                        );
                      }),

                      // Sign In Link
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: Colors.grey.withValues(alpha: 0.8),
                                fontSize: 16,
                              ),
                              children: [
                                TextSpan(
                                  text: "Sign In",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 16,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.off(() => const LoginScreen());
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
