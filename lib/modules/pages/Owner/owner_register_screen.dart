import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:neo_parlour_owner/data/models/register_user_model.dart';
import 'package:neo_parlour_owner/data/services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_login.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neo_parlour_owner/modules/pages/verify_registration_otp_screen.dart';

class OwnerRegisterScreen extends StatefulWidget {
  const OwnerRegisterScreen({super.key});

  @override
  State<OwnerRegisterScreen> createState() => _OwnerRegisterScreenState();
}

class _OwnerRegisterScreenState extends State<OwnerRegisterScreen> {
  bool isChecked = false;
  bool isOwnerTab = true;

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController salonNameController = TextEditingController();
  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController areaNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? _selectedGender = "MALE";
  DateTime? _selectedBirthdate;

  String? _selectedDocumentType = "AADHAAR_OR_GOVERNMENT_ID";
  String? _kycFileName;
  final List<KycDocument> _kycDocumentsList = [];

  bool _isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  bool _isValidGmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(email);
  }

  String openingTime = "09:00";
  String closingTime = "21:00";

  final Map<String, List<String>> _cityAreas = {
    "Pune": [
      "Kothrud",
      "Baner",
      "Hinjewadi",
      "Viman Nagar",
      "Kalyani Nagar",
      "Hadapsar",
      "Wakad",
    ],
    "Mumbai": [
      "Andheri",
      "Bandra",
      "Borivali",
      "Dadar",
      "Powai",
      "Juhu",
      "Colaba",
    ],
    "Bangalore": [
      "Indiranagar",
      "Koramangala",
      "HSR Layout",
      "Whitefield",
      "Jayanagar",
      "MG Road",
    ],
  };
  String? _selectedCity;
  String? _selectedArea;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    salonNameController.dispose();
    cityNameController.dispose();
    areaNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double h = size.height;
    final double w = size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/Images/SplashScreen/splash_screen_one_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: w * 0.05),
                  padding: EdgeInsets.fromLTRB(
                    w * 0.06,
                    h * 0.03,
                    w * 0.06,
                    h * 0.03,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// TABS
                        Row(
                          children: [
                            _buildTabItem("OWNER", true, () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OwnerRegisterScreen(),
                                ),
                              );
                            }),
                            // SizedBox(width: w * 0.08),
                            // _buildTabItem(
                            //   "EMPLOYEE",
                            //   false,
                            //   () {
                            //     Navigator.pushReplacement(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (_) => const StaffRegisterScreen(),
                            //       ),
                            //     );
                            //   },
                            // ),
                          ],
                        ),

                        SizedBox(height: h * 0.03),

                        _customInputField(
                          "assets/Images/RegisterScreen/username.svg",
                          "User Name",
                          nameController,
                        ),
                        _customInputField(
                          "assets/Images/RegisterScreen/mail.svg",
                          "Email Id",
                          emailController,
                        ),

                        _customInputField(
                          "assets/Images/RegisterScreen/call.svg",
                          "Mobile Number",
                          mobileController,
                          isVerify: true,
                        ),
                        _customInputField(
                          "assets/Images/RegisterScreen/username.svg",
                          "Salon Name",
                          salonNameController,
                        ),

                        _dropdownField(
                          "City Name",
                          _selectedCity,
                          _cityAreas.keys.toList(),
                          (val) {
                            setState(() {
                              _selectedCity = val;
                              _selectedArea = null;
                              cityNameController.text = val ?? "";
                            });
                          },
                        ),

                        _dropdownField(
                          "Area Name",
                          _selectedArea,
                          _selectedCity == null
                              ? []
                              : _cityAreas[_selectedCity]!,
                          (val) {
                            setState(() {
                              _selectedArea = val;
                              areaNameController.text = val ?? "";
                            });
                          },
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: _timePickerField(
                                "Opening Time",
                                openingTime,
                                (t) => setState(() => openingTime = t),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _timePickerField(
                                "Closing Time",
                                closingTime,
                                (t) => setState(() => closingTime = t),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        _datePickerField(
                          "Birthdate",
                          _selectedBirthdate != null
                              ? "${_selectedBirthdate!.year}-${_selectedBirthdate!.month.toString().padLeft(2, '0')}-${_selectedBirthdate!.day.toString().padLeft(2, '0')}"
                              : "Select Birthdate",
                          (date) => setState(() => _selectedBirthdate = date),
                        ),

                        _dropdownField(
                          "Gender",
                          _selectedGender,
                          ["MALE", "FEMALE", "OTHER"],
                          (val) {
                            setState(() {
                              _selectedGender = val;
                            });
                          },
                        ),

                        _customInputField(
                          "assets/Images/RegisterScreen/username.svg",
                          "Address",
                          addressController,
                        ),

                        const SizedBox(height: 14),

                        _dropdownField(
                          "KYC Document Type",
                          _selectedDocumentType,
                          [
                            "AADHAAR_OR_GOVERNMENT_ID",
                            "PAN_CARD",
                            "SHOP_ESTABLISHMENT_LICENSE",
                            "BANK_ACCOUNT_PROOF",
                          ],
                          (val) {
                            setState(() {
                              _selectedDocumentType = val;
                            });
                          },
                        ),

                        _documentPickerField(),

                        if (_kycDocumentsList.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Uploaded Documents:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ..._kycDocumentsList.map(
                            (doc) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0XFFF9F9F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0XFFE0E0E0),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.description,
                                    color: Color(0XFFFF0B01),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doc.documentType.replaceAll('_', ' '),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          doc.fileName,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _kycDocumentsList.remove(doc);
                                        if (_kycFileName == doc.fileName) {
                                          _kycFileName = null;
                                          
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        _customInputField(
                          "assets/Images/RegisterScreen/password.svg",
                          "Create a password",
                          passwordController,
                          obscure: !_passwordVisible,
                        ),
                        _customInputField(
                          "assets/Images/RegisterScreen/password.svg",
                          "Confirm password",
                          confirmPasswordController,
                          obscure: !_confirmPasswordVisible,
                        ),

                        SizedBox(height: h * 0.01),

                        SizedBox(
                          width: double.infinity,
                          height: h * 0.065,
                          child: ElevatedButton(
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0XFFFF0B01),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "REGISTER",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              activeColor: const Color(0XFFFF0B01),
                              onChanged: (v) => setState(() => isChecked = v!),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Color(0XFF909090),
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                  ),
                                  children: [
                                    const TextSpan(text: "I agree to the "),
                                    TextSpan(
                                      text: "Terms & Conditions",
                                      style: const TextStyle(
                                        color: Color(0XFFFF0B01),
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = openOwnerTerms,
                                    ),
                                    const TextSpan(text: " and "),
                                    TextSpan(
                                      text: "Privacy Policy",
                                      style: const TextStyle(
                                        color: Color(0XFFFF0B01),
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = openOwnerPrivacy,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Already have account? ",
                                  style: TextStyle(color: Color(0XFF909090)),
                                ),
                                TextSpan(
                                  text: "Login",
                                  style: const TextStyle(
                                    color: Color(0XFFFF0B01),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const SalonOwnerLoginScreen(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openOwnerTerms() async {
    final Uri url = Uri.parse(
      'https://www.neoparlour.com/owner/terms-and-conditions',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> openOwnerPrivacy() async {
    final Uri url = Uri.parse(
      'https://www.neoparlour.com/owner/privacy-policy',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void _handleRegister() async {
    String phone = mobileController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        mobileController.text.isEmpty ||
        passwordController.text.isEmpty) {
      FlushbarHelper.show(context, "Please fill all mandatory fields");
      return;
    }

    // 📱 Phone validation
    if (!_isValidPhone(phone)) {
      FlushbarHelper.show(context, "Mobile number must be exactly 10 digits");
      return;
    }

    // 📧 Gmail validation
    if (!_isValidGmail(email)) {
      FlushbarHelper.show(context, "Please enter a valid Gmail address");
      return;
    }

    // 🔑 Password length
    if (password.length < 6) {
      FlushbarHelper.show(context, "Password must be at least 6 characters");
      return;
    }

    if (password != confirmPassword) {
      FlushbarHelper.show(context, "Passwords do not match");
      return;
    }

    if (!isChecked) {
      FlushbarHelper.show(context, "Please accept Terms of Use");
      return;
    }

    final hasAadhaar = _kycDocumentsList.any(
      (doc) => doc.documentType == "AADHAAR_OR_GOVERNMENT_ID",
    );
    if (!hasAadhaar) {
      FlushbarHelper.show(
        context,
        "Aadhaar Card is compulsory. Please upload it.",
      );
      return;
    }

    try {
      final authService = AuthService();
      await authService.sendRegisterOtp(mobileController.text.trim());

      String? fcmToken;
      try {
        String? vapidKey;
        if (kIsWeb) {
          vapidKey = "BIdYnU3B7lY_U7wKzUv3Qv7Jv_Z_qX_L7_X_z_v_x_Z_Y";
        }
        fcmToken = await FirebaseMessaging.instance.getToken(
          vapidKey: vapidKey,
        );
        debugPrint("OWNER REG FCM TOKEN (RAW) => $fcmToken");
      } catch (e) {
        debugPrint("Non-fatal error getting FCM token: $e");
      }

      final registrationData = UserRegistrationRequest(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: mobileController.text.trim(),
        password: passwordController.text,
        salonName: salonNameController.text.trim(),
        cityName: cityNameController.text.trim(),
        areaName: areaNameController.text.trim(),
        openingTime: openingTime.split(':').length == 2 ? "$openingTime:00" : openingTime,
        closingTime: closingTime.split(':').length == 2 ? "$closingTime:00" : closingTime,
        fcmToken: fcmToken,
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        birthdate: _selectedBirthdate != null
            ? "${_selectedBirthdate!.year}-${_selectedBirthdate!.month.toString().padLeft(2, '0')}-${_selectedBirthdate!.day.toString().padLeft(2, '0')}"
            : null,
        latitude: 18.5074, // Default placeholder
        longitude: 73.8077, // Default placeholder
        gender: _selectedGender,
        homeServiceCharges: null,
        kycDocuments: _kycDocumentsList,
        tncAccepted: isChecked,
        tncVersion: '1.0',
        tncAcceptedAt: DateTime.now().toUtc().toIso8601String(),
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyRegistrationOtpScreen(
            registrationRequest: registrationData,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      FlushbarHelper.show(context, "Error: ${e.toString()}");
    }
  }

  Widget _documentPickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Document",
          style: TextStyle(fontSize: 12, color: Color(0XFF909090)),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: () => _showUploadOptions(context),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0XFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0XFFE0E0E0), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _kycFileName ?? "Select PDF or Image",
                    style: TextStyle(
                      color: _kycFileName != null
                          ? Colors.black
                          : const Color(0XFFADADAD),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.upload_file,
                  color: Color(0XFF909090),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDocumentFromGallery() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null) {
        final file = result.files.single;
        Uint8List? bytes;
        try {
          bytes = await file.readAsBytes();
        } catch (_) {
          if (file.path != null && !kIsWeb) {
            final localFile = File(file.path!);
            bytes = await localFile.readAsBytes();
          }
        }

        if (bytes != null) {
          _addKycDocument(file.name, base64Encode(bytes));
        } else {
          if (mounted) {
            FlushbarHelper.show(context, "Could not retrieve file content.");
          }
        }
      }
    } catch (e) {
      if (mounted) {
        FlushbarHelper.show(context, "Error picking file: $e");
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        _addKycDocument(photo.name, base64Encode(bytes));
      }
    } catch (e) {
      if (mounted) {
        FlushbarHelper.show(context, "Error taking photo: $e");
      }
    }
  }

  void _addKycDocument(String name, String base64Content) {
    if (_selectedDocumentType == null) return;

    final newDoc = KycDocument(
      documentType: _selectedDocumentType!,
      fileName: name,
      contentType: name.toLowerCase().endsWith('.pdf')
          ? 'application/pdf'
          : 'image/jpeg',
      fileBase64: base64Content,
    );

    setState(() {
      final existingIndex = _kycDocumentsList.indexWhere(
        (doc) => doc.documentType == _selectedDocumentType,
      );
      if (existingIndex != -1) {
        _kycDocumentsList[existingIndex] = newDoc;
      } else {
        _kycDocumentsList.add(newDoc);
      }
      _kycFileName = name;
    });
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Select Document Source",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0XFFF9F9F9),
                  child: Icon(Icons.photo_library, color: Color(0XFFFF0B01)),
                ),
                title: const Text("Upload from Gallery / Files"),
                subtitle: const Text("Select image or PDF document"),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocumentFromGallery();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0XFFF9F9F9),
                  child: Icon(Icons.camera_alt, color: Color(0XFFFF0B01)),
                ),
                title: const Text("Take a Photo"),
                subtitle: const Text("Capture using device camera"),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _datePickerField(
    String label,
    String currentValue,
    Function(DateTime) onDateSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0XFF909090)),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedBirthdate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0XFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0XFFE0E0E0), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(currentValue, style: const TextStyle(color: Colors.black)),
                const Icon(
                  Icons.calendar_today,
                  color: Color(0XFF909090),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _timePickerField(
    String label,
    String currentTime,
    Function(String) onTimeSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0XFF909090)),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: int.parse(currentTime.split(":")[0]),
                minute: int.parse(currentTime.split(":")[1]),
              ),
            );
            if (picked != null) {
              final formattedTime =
                  "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
              onTimeSelected(formattedTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0XFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0XFFE0E0E0), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(currentTime, style: const TextStyle(color: Colors.black)),
                const Icon(
                  Icons.access_time,
                  color: Color(0XFF909090),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.black : const Color(0XFFADADAD),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: title.length * 9,
            color: isActive ? const Color(0XFFFF0B01) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _customInputField(
    String icon,
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    bool isVerify = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              icon,
              colorFilter: const ColorFilter.mode(
                Color(0XFF909090),
                BlendMode.srcIn,
              ),
            ),
          ),
          suffixIcon:
              (hint == "Create a password" || hint == "Confirm password")
              ? IconButton(
                  icon: Icon(
                    hint == "Create a password"
                        ? (_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off)
                        : (_confirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                    color: const Color(0XFF909090),
                  ),
                  onPressed: () {
                    setState(() {
                      if (hint == "Create a password") {
                        _passwordVisible = !_passwordVisible;
                      } else {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      }
                    });
                  },
                )
              : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0XFFADADAD)),
          filled: true,
          fillColor: const Color(0XFFF9F9F9),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0XFFE0E0E0), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0XFFFF0B01), width: 1.6),
          ),
        ),
      ),
    );
  }

  Widget _dropdownField(
    String hint,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: value,
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.location_city, color: Color(0XFF909090)),
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0XFFADADAD)),
          filled: true,
          fillColor: const Color(0XFFF9F9F9),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0XFFE0E0E0), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0XFFFF0B01), width: 1.6),
          ),
        ),
      ),
    );
  }
}
