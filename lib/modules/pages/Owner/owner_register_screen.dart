import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neo_parlour_owner/widgets/custom_input_field.dart';
import 'package:neo_parlour_owner/data/models/register_user_model.dart';
import 'package:neo_parlour_owner/data/services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_login.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:neo_parlour_owner/modules/pages/verify_registration_otp_screen.dart';
import 'package:neo_parlour_owner/core/data/services/search_service.dart';
import 'package:neo_parlour_owner/l10n/generated/app_localizations.dart';
import 'package:neo_parlour_owner/core/utils/gst_validator.dart';
import 'package:neo_parlour_owner/widgets/salon_location_card.dart';

class OwnerRegisterScreen extends StatefulWidget {
  const OwnerRegisterScreen({super.key});

  @override
  State<OwnerRegisterScreen> createState() => _OwnerRegisterScreenState();
}

class _OwnerRegisterScreenState extends State<OwnerRegisterScreen> {
  bool isChecked = false;

  bool  _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController salonNameController = TextEditingController();
  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController areaNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController specificAddressController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  String? _selectedStateEnum;
  bool _includeGstInInvoice = false;
  
  String? _selectedGender;
  DateTime? _selectedBirthdate;
  double? _latitude;
  double? _longitude;
  String _shopOrFlatNo = '';
  String _buildingName = '';
  List<String> _nearbyLandmarks = [];

  String? _selectedDocumentType;
  final List<KycDocument> _kycDocumentsList = [];

  int _currentStep = 0;
  String? _mainSalonImageBase64;
  Uint8List? _mainSalonImageBytes;
  String? _exteriorImageBase64;
  Uint8List? _exteriorImageBytes;
  String? _interior1ImageBase64;
  Uint8List? _interior1ImageBytes;
  String? _interior2ImageBase64;
  Uint8List? _interior2ImageBytes;
  String? _optionalImage1Base64;
  Uint8List? _optionalImage1Bytes;
  String? _optionalImage2Base64;
  Uint8List? _optionalImage2Bytes;
  String _selectedAreaDistrict = '';

  String get _stateDisplayName {
    if (_selectedStateEnum == null) return '';
    try {
      return GstValidator.indianStates.firstWhere((s) => s.enumValue == _selectedStateEnum).displayName;
    } catch (_) {
      return '';
    }
  }

  List<String> get _salonGalleryImagesBase64 {
    final list = <String>[];
    if (_exteriorImageBase64 != null) list.add(_exteriorImageBase64!);
    if (_interior1ImageBase64 != null) list.add(_interior1ImageBase64!);
    if (_interior2ImageBase64 != null) list.add(_interior2ImageBase64!);
    if (_optionalImage1Base64 != null) list.add(_optionalImage1Base64!);
    if (_optionalImage2Base64 != null) list.add(_optionalImage2Base64!);
    return list;
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  bool _isValidGmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(email);
  }

  Uint8List? _decodeBase64(String? input) {
    if (input == null || input.isEmpty) return null;
    try {
      String clean = input;
      if (clean.contains(',')) {
        clean = clean.split(',').last;
      }
      return base64Decode(clean.trim());
    } catch (_) {
      try {
        return base64Decode(input.replaceAll(RegExp(r'\s+'), ''));
      } catch (e) {
        debugPrint("Error decoding base64 image: $e");
        return null;
      }
    }
  }

  String openingTime = "09:00";
  String closingTime = "21:00";

  final SearchService _searchService = SearchService();
  final FocusNode cityFocusNode = FocusNode();
  final FocusNode areaFocusNode = FocusNode();
  final FocusNode landmarkFocusNode = FocusNode();

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
    specificAddressController.dispose();
    landmarkController.dispose();
    gstinController.dispose();
    cityFocusNode.dispose();
    areaFocusNode.dispose();
    landmarkFocusNode.dispose();
    super.dispose();
  }

  Widget _buildStepperHeader() {
    final steps = [
      AppLocalizations.of(context)!.stepPersonal,
      AppLocalizations.of(context)!.stepSalon,
      AppLocalizations.of(context)!.stepKyc,
      AppLocalizations.of(context)!.stepOtp,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Connecting Line
          Positioned(
            left: 30,
            right: 30,
            top: 20,
            child: Container(
              height: 2,
              color: Colors.grey[300],
            ),
          ),
          Positioned(
             left: 30,
             right: 30,
             top: 20,
             child: Row(
               children: [
                  Expanded(
                    flex: _currentStep,
                    child: Container(height: 2, color: const Color(0XFFFF0B01)),
                  ),
                  Expanded(
                    flex: 3 - _currentStep,
                    child: Container(height: 2, color: Colors.transparent),
                  )
               ],
             ),
          ),
          // Step circles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final isActive = index == _currentStep;
              final isCompleted = index < _currentStep;
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isActive || isCompleted ? const Color(0XFFFF0B01) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive || isCompleted ? const Color(0XFFFF0B01) : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActive || isCompleted ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.ownerDetails,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 15),
        CustomInputField(
          icon: "assets/Images/RegisterScreen/username.svg",
          hint: AppLocalizations.of(context)!.ownerFullName,
          controller: nameController,
        ),
        CustomInputField(
          icon: "assets/Images/RegisterScreen/mail.svg",
          hint: AppLocalizations.of(context)!.emailAddress,
          controller: emailController,
        ),
        CustomInputField(
          icon: "assets/Images/RegisterScreen/call.svg",
          hint: AppLocalizations.of(context)!.mobileNumber,
          controller: mobileController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          maxLength: 10,
          isVerify: true,
        ),
        const SizedBox(height: 15),
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            hintText: "Gender",
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          value: _selectedGender,
          items: const [
            DropdownMenuItem(value: 'MALE', child: Text('Male')),
            DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
            DropdownMenuItem(value: 'OTHER', child: Text('Other')),
          ],
          onChanged: (val) => setState(() => _selectedGender = val),
        ),
        const SizedBox(height: 15),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final maxDate = DateTime(now.year - 18, now.month, now.day);
            final picked = await showDatePicker(
              context: context,
              initialDate: maxDate,
              firstDate: DateTime(1900),
              lastDate: maxDate,
            );
            if (picked != null) {
              setState(() => _selectedBirthdate = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedBirthdate == null
                        ? "Birthdate (18+ only)"
                        : "${_selectedBirthdate!.year}-${_selectedBirthdate!.month.toString().padLeft(2, '0')}-${_selectedBirthdate!.day.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: _selectedBirthdate == null ? Colors.grey.shade600 : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(context)!.securityTab,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 15),
        CustomInputField(
          icon: "assets/Images/RegisterScreen/password.svg",
          hint: AppLocalizations.of(context)!.createPassword,
          controller: passwordController,
          isPassword: true,
        ),
        CustomInputField(
          icon: "assets/Images/RegisterScreen/password.svg",
          hint: AppLocalizations.of(context)!.confirmPassword,
          controller: confirmPasswordController,
          isPassword: true,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || emailController.text.isEmpty || mobileController.text.isEmpty || passwordController.text.isEmpty) {
                FlushbarHelper.show(context, AppLocalizations.of(context)!.fillMandatoryFields);
                return;
              }
              if (_selectedGender == null || _selectedBirthdate == null) {
                FlushbarHelper.show(context, "Please select Gender and Birthdate");
                return;
              }
              final now = DateTime.now();
              final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
              if (_selectedBirthdate!.isAfter(eighteenYearsAgo)) {
                FlushbarHelper.show(context, "Owner must be at least 18 years old to register.");
                return;
              }
              if (!_isValidPhone(mobileController.text.trim())) {
                FlushbarHelper.show(context, AppLocalizations.of(context)!.mobileNumber10Digits);
                return;
              }
              if (!_isValidGmail(emailController.text.trim())) {
                FlushbarHelper.show(context, AppLocalizations.of(context)!.validGmailAddress);
                return;
              }
              if (passwordController.text.length < 6) {
                FlushbarHelper.show(context, AppLocalizations.of(context)!.passwordLengthError);
                return;
              }
              if (passwordController.text != confirmPasswordController.text) {
                FlushbarHelper.show(context, AppLocalizations.of(context)!.passwordsDoNotMatch);
                return;
              }
              setState(() => _currentStep = 1);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0XFFFF0B01),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalizations.of(context)!.continueToSalonInfo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: AppLocalizations.of(context)!.alreadyHaveAccount, style: const TextStyle(color: Color(0XFF909090))),
                TextSpan(
                  text: AppLocalizations.of(context)!.login,
                  style: const TextStyle(color: Color(0XFFFF0B01), fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalonOwnerLoginScreen())),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalonStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.salonInformation,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 15),
        CustomInputField(
          icon: "assets/Images/RegisterScreen/username.svg",
          hint: AppLocalizations.of(context)!.salonName,
          controller: salonNameController,
        ),
        const SizedBox(height: 15),
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.map, color: Color(0XFF909090)),
            ),
            hintText: "Select State / UT",
            hintStyle: const TextStyle(color: Color(0XFFADADAD), fontSize: 13),
            filled: true,
            fillColor: const Color(0XFFF9F9F9),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0XFFE0E0E0), width: 1.2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0XFFFF0B01), width: 1.6)),
          ),
          value: _selectedStateEnum,
          items: GstValidator.indianStates.map((state) {
            return DropdownMenuItem(
              value: state.enumValue,
              child: Text(
                state.displayName,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedStateEnum = val;
              cityNameController.clear();
              areaNameController.clear();
            });
          },
        ),
        const SizedBox(height: 10),
        SalonLocationCard(
          latitude: _latitude,
          longitude: _longitude,
          shopOrFlatNo: _shopOrFlatNo,
          buildingName: _buildingName,
          specificAddress: specificAddressController.text,
          landmark: landmarkController.text,
          areaName: areaNameController.text,
          cityName: cityNameController.text,
          state: _stateDisplayName,
          nearbyLandmarks: _nearbyLandmarks,
          onLocationChanged: (details) {
            setState(() {
              _latitude = details.latitude;
              _longitude = details.longitude;
              _shopOrFlatNo = details.shopOrFlatNo;
              _buildingName = details.buildingName;
              specificAddressController.text = details.specificAddress;
              landmarkController.text = details.landmark;
              if (details.areaName.isNotEmpty) {
                areaNameController.text = details.areaName;
              }
              if (details.cityName.isNotEmpty) {
                cityNameController.text = details.cityName;
              }
              _nearbyLandmarks = details.nearbyLandmarks;
              if (details.state.isNotEmpty) {
                final rawState = details.state.trim();
                final stateQuery = rawState.toUpperCase().replaceAll(' ', '_');
                try {
                  final matchedState = GstValidator.indianStates.firstWhere(
                    (s) =>
                        s.enumValue == stateQuery ||
                        s.displayName.toLowerCase() == rawState.toLowerCase() ||
                        s.enumValue.contains(stateQuery),
                  );
                  _selectedStateEnum = matchedState.enumValue;
                } catch (_) {}
              }
            });
          },
        ),
        const SizedBox(height: 10),
        _buildCityTypeAhead(),
        const SizedBox(height: 15),
        _buildAreaTypeAhead(),
        const SizedBox(height: 15),
        _buildLandmarkTypeAhead(),
        const SizedBox(height: 15),
        CustomInputField(
          icon: "assets/Images/RegisterScreen/username.svg", // Or appropriate icon
          hint: "Street / Specific Address", // Will be replaced by l10n later if needed
          controller: specificAddressController,
        ),
        _buildAddressPreview(),
        const SizedBox(height: 10),
        SwitchListTile(
          title: const Text("Include GST (18%) in Invoices"),
          value: _includeGstInInvoice,
          onChanged: (val) => setState(() => _includeGstInInvoice = val),
          contentPadding: EdgeInsets.zero,
        ),
        if (_includeGstInInvoice) ...[
          const SizedBox(height: 10),
          CustomInputField(
            icon: "assets/Images/RegisterScreen/username.svg",
            hint: "15-Digit GSTIN (e.g. 27AAAAA0000A1Z5)",
            controller: gstinController,
            maxLength: 15,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              UpperCaseTextFormatter(),
            ],
          ),
        ],
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _timePickerField(
                AppLocalizations.of(context)!.openingTime,
                openingTime,
                (t) => setState(() => openingTime = t),
                compareTime: closingTime,
                isOpening: true,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _timePickerField(
                AppLocalizations.of(context)!.closingTime,
                closingTime,
                (t) => setState(() => closingTime = t),
                compareTime: openingTime,
                isOpening: false,
              ),
            ),
          ],
        ),
        if (_timeToMinutes(openingTime) == _timeToMinutes(closingTime)) ...[
          const SizedBox(height: 6),
          const Row(
            children: [
              Icon(Icons.error_outline, size: 14, color: Color(0XFFFF0B01)),
              SizedBox(width: 4),
              Text(
                "Opening time and closing time cannot be the same.",
                style: TextStyle(color: Color(0XFFFF0B01), fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ] else if (_timeToMinutes(openingTime) > _timeToMinutes(closingTime)) ...[
          const SizedBox(height: 6),
          const Row(
            children: [
              Icon(Icons.error_outline, size: 14, color: Color(0XFFFF0B01)),
              SizedBox(width: 4),
              Text(
                "Closing time must be after opening time.",
                style: TextStyle(color: Color(0XFFFF0B01), fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.salonMedia,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 15),
        Text(AppLocalizations.of(context)!.mainSalonImageLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: _buildImageSlot("", AppLocalizations.of(context)!.uploadBtn, "MAIN_SALON_IMAGE", _mainSalonImageBytes),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(AppLocalizations.of(context)!.salonGalleryTitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0XFFFF0B01).withValues(alpha:0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(AppLocalizations.of(context)!.min3ImagesRequired, style: const TextStyle(color: Color(0XFFFF0B01), fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(AppLocalizations.of(context)!.uploadImageInstructions, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildImageSlot(AppLocalizations.of(context)!.exteriorView, AppLocalizations.of(context)!.uploadOutsideBtn, "EXTERIOR", _exteriorImageBytes)),
            const SizedBox(width: 10),
            Expanded(child: _buildImageSlot(AppLocalizations.of(context)!.interiorView1, AppLocalizations.of(context)!.uploadInside1Btn, "INTERIOR1", _interior1ImageBytes)),
            const SizedBox(width: 10),
            Expanded(child: _buildImageSlot(AppLocalizations.of(context)!.interiorView2, AppLocalizations.of(context)!.uploadInside2Btn, "INTERIOR2", _interior2ImageBytes)),
          ],
        ),
        const SizedBox(height: 25),
        Text(AppLocalizations.of(context)!.additionalGalleryImages, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          children: [
            if (_optionalImage1Bytes != null)
              SizedBox(width: 100, child: _buildImageSlot("", "", "OPTIONAL1", _optionalImage1Bytes)),
            if (_optionalImage2Bytes != null)
              SizedBox(width: 100, child: _buildImageSlot("", "", "OPTIONAL2", _optionalImage2Bytes)),
            if (_optionalImage1Base64 == null || _optionalImage2Base64 == null)
              GestureDetector(
                onTap: () {
                  _selectedDocumentType = _optionalImage1Base64 == null ? "OPTIONAL1" : "OPTIONAL2";
                  _showUploadOptions(context);
                },
                child: Container(
                  width: 100,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0XFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0XFFE0E0E0), width: 1.2),
                  ),
                  child: const Center(child: Icon(Icons.add, color: Colors.grey)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0XFFE0E0E0)),
                ),
                child: Text(AppLocalizations.of(context)!.backBtn, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  if (salonNameController.text.isEmpty || cityNameController.text.isEmpty || areaNameController.text.isEmpty) {
                     FlushbarHelper.show(context, AppLocalizations.of(context)!.fillSalonInfoError);
                     return;
                  }
                  final openMin = _timeToMinutes(openingTime);
                  final closeMin = _timeToMinutes(closingTime);
                  if (openMin == closeMin) {
                    FlushbarHelper.show(context, "Opening time and closing time cannot be the same.");
                    return;
                  }
                  if (openMin > closeMin) {
                    FlushbarHelper.show(context, "Closing time must be after opening time.");
                    return;
                  }
                  if (_includeGstInInvoice) {
                    if (_selectedStateEnum == null) {
                      FlushbarHelper.show(context, "Please select a State/UT for GST invoicing");
                      return;
                    }
                    final gstError = GstValidator.validateGstinAndState(gstinController.text, _selectedStateEnum, isRequired: true);
                    if (gstError != null) {
                      FlushbarHelper.show(context, gstError);
                      return;
                    }
                  }
                  if (_mainSalonImageBase64 == null) {
                     FlushbarHelper.show(context, AppLocalizations.of(context)!.uploadMainSalonImageError);
                     return;
                  }
                  if (_salonGalleryImagesBase64.length < 3) {
                     FlushbarHelper.show(context, AppLocalizations.of(context)!.uploadGalleryImagesError);
                     return;
                  }
                  setState(() => _currentStep = 2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFFFF0B01),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppLocalizations.of(context)!.continueToKycBtn, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageSlot(String label, String buttonText, String docType, Uint8List? imageBytes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
        ],
        GestureDetector(
          onTap: () {
            _selectedDocumentType = docType;
            _showUploadOptions(context);
          },
          child: Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0XFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (imageBytes != null) ? const Color(0XFFFF0B01) : const Color(0XFFE0E0E0),
                width: 1.2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageBytes != null)
                    Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                      cacheWidth: 300,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.broken_image, color: Colors.grey, size: 24),
                              SizedBox(height: 4),
                              Text("Invalid Image", style: TextStyle(fontSize: 9, color: Colors.grey)),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.upload, color: Colors.grey, size: 24),
                          const SizedBox(height: 4),
                          if (buttonText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                buttonText,
                                style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (imageBytes != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          if (docType == "MAIN_SALON_IMAGE") setState(() { _mainSalonImageBase64 = null; _mainSalonImageBytes = null; });
                          if (docType == "EXTERIOR") setState(() { _exteriorImageBase64 = null; _exteriorImageBytes = null; });
                          if (docType == "INTERIOR1") setState(() { _interior1ImageBase64 = null; _interior1ImageBytes = null; });
                          if (docType == "INTERIOR2") setState(() { _interior2ImageBase64 = null; _interior2ImageBytes = null; });
                          if (docType == "OPTIONAL1") setState(() { _optionalImage1Base64 = null; _optionalImage1Bytes = null; });
                          if (docType == "OPTIONAL2") setState(() { _optionalImage2Base64 = null; _optionalImage2Bytes = null; });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.red),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKycBox(String title, String docType) {
    final docIndex = _kycDocumentsList.indexWhere((doc) => doc.documentType == docType);
    final hasDoc = docIndex != -1;
    final doc = hasDoc ? _kycDocumentsList[docIndex] : null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0XFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasDoc ? Colors.green : const Color(0XFFE0E0E0), width: 1.2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              if (hasDoc) const Icon(Icons.check_circle, color: Colors.green, size: 16),
            ],
          ),
          const SizedBox(height: 4),
          if (!hasDoc)
            Text(AppLocalizations.of(context)!.notUploaded, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          if (hasDoc)
            Text(doc!.fileName, style: const TextStyle(color: Colors.grey, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                if (hasDoc) {
                   setState(() => _kycDocumentsList.removeAt(docIndex));
                } else {
                   _selectedDocumentType = docType;
                   _showUploadOptions(context);
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: hasDoc ? Colors.red.withValues(alpha:0.3) : Colors.grey.withValues(alpha:0.3)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(hasDoc ? AppLocalizations.of(context)!.removeBtn : AppLocalizations.of(context)!.uploadFileBtn, style: TextStyle(color: hasDoc ? Colors.red : Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKycStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.kycVerification,
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0XFFFF0B01).withValues(alpha:0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(AppLocalizations.of(context)!.atLeast1DocRequired, style: const TextStyle(color: Color(0XFFFF0B01), fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(AppLocalizations.of(context)!.kycInstructions, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.05,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          children: [
            _buildKycBox(AppLocalizations.of(context)!.aadhaarGovtId, "AADHAAR_OR_GOVERNMENT_ID"),
            _buildKycBox(AppLocalizations.of(context)!.panCard, "PAN_CARD"),
            _buildKycBox(AppLocalizations.of(context)!.shopEstLicense, "SHOP_ESTABLISHMENT_LICENSE"),
            _buildKycBox(AppLocalizations.of(context)!.bankAccountProof, "BANK_ACCOUNT_PROOF"),
          ],
        ),
        const SizedBox(height: 30),
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
                  style: const TextStyle(color: Color(0XFF909090), fontSize: 12, fontFamily: 'Inter'),
                  children: [
                    TextSpan(text: AppLocalizations.of(context)!.iAgreeWithThe),
                    TextSpan(
                      text: AppLocalizations.of(context)!.termsAndConditions,
                      style: const TextStyle(color: Color(0XFFFF0B01), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = openOwnerTerms,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0XFFE0E0E0)),
                ),
                child: Text(AppLocalizations.of(context)!.backBtn, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _submitRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFFFF0B01),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppLocalizations.of(context)!.sendOtpBtn, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double h = size.height;
    final double w = size.width;

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentStep > 0) {
          setState(() => _currentStep--);
        }
      },
      child: Scaffold(
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
                  padding: EdgeInsets.fromLTRB(w * 0.06, h * 0.03, w * 0.06, h * 0.03),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_currentStep > 0) {
                                  setState(() => _currentStep--);
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Icon(Icons.arrow_back),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              AppLocalizations.of(context)!.ownerAndSalonRegistration,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        _buildStepperHeader(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _currentStep == 0
                              ? _buildPersonalStep()
                              : _currentStep == 1
                                  ? _buildSalonStep()
                                  : _buildKycStep(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Future<void> openOwnerTerms() async {
    final Uri url = Uri.parse('https://www.neoparlour.com/owner/terms-and-conditions');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> openOwnerPrivacy() async {
    final Uri url = Uri.parse('https://www.neoparlour.com/owner/privacy-policy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }



  void _submitRegistration() async {
    final openMin = _timeToMinutes(openingTime);
    final closeMin = _timeToMinutes(closingTime);
    if (openMin == closeMin) {
      FlushbarHelper.show(context, "Opening time and closing time cannot be the same.");
      return;
    }
    if (openMin > closeMin) {
      FlushbarHelper.show(context, "Closing time must be after opening time.");
      return;
    }

    if (!isChecked) {
      FlushbarHelper.show(context, AppLocalizations.of(context)!.pleaseAcceptTerms);
      return;
    }

    if (_kycDocumentsList.isEmpty) {
      FlushbarHelper.show(context, AppLocalizations.of(context)!.pleaseUpload1KycDoc);
      return;
    }

    if (_includeGstInInvoice) {
      if (_selectedStateEnum == null) {
        FlushbarHelper.show(context, "Please select a State/UT for GST invoicing");
        return;
      }
      final gstError = GstValidator.validateGstinAndState(gstinController.text, _selectedStateEnum, isRequired: true);
      if (gstError != null) {
        FlushbarHelper.show(context, gstError);
        return;
      }
    }

    for (var doc in _kycDocumentsList) {
      final decoded = _decodeBase64(doc.fileBase64);
      if (decoded != null && decoded.lengthInBytes > _maxFileSizeBytes) {
        FlushbarHelper.show(context, "KYC Document '${doc.fileName}' exceeds maximum allowed size of 5 MB.");
        return;
      }
    }

    if (_mainSalonImageBase64 != null) {
      final decoded = _decodeBase64(_mainSalonImageBase64);
      if (decoded != null && decoded.lengthInBytes > _maxFileSizeBytes) {
        FlushbarHelper.show(context, "Main Salon Image exceeds maximum allowed size of 5 MB.");
        return;
      }
    }

    for (var img in _salonGalleryImagesBase64) {
      final decoded = _decodeBase64(img);
      if (decoded != null && decoded.lengthInBytes > _maxFileSizeBytes) {
        FlushbarHelper.show(context, "A gallery image exceeds maximum allowed size of 5 MB.");
        return;
      }
    }

    try {
      final authService = AuthService();
      final String? generatedOtp = await authService.sendRegisterOtp(mobileController.text.trim());

      String? fcmToken;
      try {
        String? vapidKey;
        if (kIsWeb) {
          vapidKey = "BIdYnU3B7lY_U7wKzUv3Qv7Jv_Z_qX_L7_X_z_v_x_Z_Y";
        }
        fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: vapidKey);
      } catch (e) {
        debugPrint("Non-fatal error getting FCM token: $e");
      }

      final registrationData = UserRegistrationRequest(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: mobileController.text.trim(),
        gender: _selectedGender,
        birthdate: _selectedBirthdate != null ? "${_selectedBirthdate!.year}-${_selectedBirthdate!.month.toString().padLeft(2, '0')}-${_selectedBirthdate!.day.toString().padLeft(2, '0')}" : null,
        password: passwordController.text,
        salonName: salonNameController.text.trim(),
        cityName: cityNameController.text.trim(),
        areaName: areaNameController.text.trim(),
        openingTime: openingTime.split(':').length == 2 ? "$openingTime:00" : openingTime,
        closingTime: closingTime.split(':').length == 2 ? "$closingTime:00" : closingTime,
        fcmToken: fcmToken,
        address: _getFormattedAddress().isEmpty ? null : _getFormattedAddress(),
        specificAddress: specificAddressController.text.trim().isEmpty ? null : specificAddressController.text.trim(),
        landmark: landmarkController.text.trim().isEmpty ? null : landmarkController.text.trim(),
        state: _selectedStateEnum,
        includeGstInInvoice: _includeGstInInvoice,
        gstin: gstinController.text.trim().isEmpty ? null : gstinController.text.trim(),
        imageBase64: _mainSalonImageBase64,
        salonImagesBase64: _salonGalleryImagesBase64,
        latitude: _latitude,
        longitude: _longitude,
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
            initialOtp: generatedOtp,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      FlushbarHelper.show(context, "${AppLocalizations.of(context)!.errorPrefix}${e.toString()}");
    }
  }

  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

  bool _isSalonImage(String? docType) {
    return [
      "MAIN_SALON_IMAGE",
      "EXTERIOR",
      "INTERIOR1",
      "INTERIOR2",
      "OPTIONAL1",
      "OPTIONAL2",
    ].contains(docType);
  }

  Future<void> _pickDocumentFromGallery() async {
    try {
      if (_isSalonImage(_selectedDocumentType)) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          final int fileSize = await image.length();
          if (fileSize > _maxFileSizeBytes) {
            final double sizeInMb = fileSize / (1024 * 1024);
            if (mounted) {
              FlushbarHelper.show(
                context,
                "Selected image is ${sizeInMb.toStringAsFixed(1)} MB. Maximum allowed size is 5 MB.",
              );
            }
            return;
          }
          final bytes = await image.readAsBytes();
          _handleUploadedFile(image.name, base64Encode(bytes), rawBytes: bytes);
        }
        return;
      }

      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null) {
        final file = result.files.single;
        if (file.size > _maxFileSizeBytes) {
          final double sizeInMb = file.size / (1024 * 1024);
          if (mounted) {
            FlushbarHelper.show(
              context,
              "Selected file is ${sizeInMb.toStringAsFixed(1)} MB. Maximum allowed size is 5 MB.",
            );
          }
          return;
        }

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
          if (bytes.lengthInBytes > _maxFileSizeBytes) {
            final double sizeInMb = bytes.lengthInBytes / (1024 * 1024);
            if (mounted) {
              FlushbarHelper.show(
                context,
                "Selected file is ${sizeInMb.toStringAsFixed(1)} MB. Maximum allowed size is 5 MB.",
              );
            }
            return;
          }
          _handleUploadedFile(file.name, base64Encode(bytes), rawBytes: bytes);
        } else {
          if (mounted) FlushbarHelper.show(context, AppLocalizations.of(context)!.couldNotRetrieveFileContent);
        }
      }
    } catch (e) {
      if (mounted) FlushbarHelper.show(context, "${AppLocalizations.of(context)!.errorPickingFile}$e");
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final int fileSize = await photo.length();
        if (fileSize > _maxFileSizeBytes) {
          final double sizeInMb = fileSize / (1024 * 1024);
          if (mounted) {
            FlushbarHelper.show(
              context,
              "Captured photo is ${sizeInMb.toStringAsFixed(1)} MB. Maximum allowed size is 5 MB.",
            );
          }
          return;
        }
        final bytes = await photo.readAsBytes();
        _handleUploadedFile(photo.name, base64Encode(bytes), rawBytes: bytes);
      }
    } catch (e) {
      if (mounted) FlushbarHelper.show(context, "${AppLocalizations.of(context)!.errorTakingPhoto}$e");
    }
  }

  void _handleUploadedFile(String name, String base64Content, {Uint8List? rawBytes}) {
    if (_selectedDocumentType == null) return;

    final bytes = rawBytes ?? _decodeBase64(base64Content);
    if (bytes != null && bytes.lengthInBytes > _maxFileSizeBytes) {
      if (mounted) FlushbarHelper.show(context, "File size must not exceed 5 MB.");
      return;
    }

    if (_selectedDocumentType == "MAIN_SALON_IMAGE") {
      setState(() {
        _mainSalonImageBase64 = base64Content;
        _mainSalonImageBytes = bytes;
      });
    } else if (_selectedDocumentType == "EXTERIOR") {
      setState(() {
        _exteriorImageBase64 = base64Content;
        _exteriorImageBytes = bytes;
      });
    } else if (_selectedDocumentType == "INTERIOR1") {
      setState(() {
        _interior1ImageBase64 = base64Content;
        _interior1ImageBytes = bytes;
      });
    } else if (_selectedDocumentType == "INTERIOR2") {
      setState(() {
        _interior2ImageBase64 = base64Content;
        _interior2ImageBytes = bytes;
      });
    } else if (_selectedDocumentType == "OPTIONAL1") {
      setState(() {
        _optionalImage1Base64 = base64Content;
        _optionalImage1Bytes = bytes;
      });
    } else if (_selectedDocumentType == "OPTIONAL2") {
      setState(() {
        _optionalImage2Base64 = base64Content;
        _optionalImage2Bytes = bytes;
      });
    } else {
      final newDoc = KycDocument(
        documentType: _selectedDocumentType!,
        fileName: name,
        contentType: name.toLowerCase().endsWith('.pdf') ? 'application/pdf' : 'image/jpeg',
        fileBase64: base64Content,
      );
      setState(() {
        final existingIndex = _kycDocumentsList.indexWhere((doc) => doc.documentType == _selectedDocumentType);
        if (existingIndex != -1) {
          _kycDocumentsList[existingIndex] = newDoc;
        } else {
          _kycDocumentsList.add(newDoc);
        }
      });
    }
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 15),
              const SizedBox(height: 15),
              Text(AppLocalizations.of(context)!.selectDocumentSource, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0XFFF9F9F9), child: Icon(Icons.photo_library, color: Color(0XFFFF0B01))),
                title: Text(AppLocalizations.of(context)!.uploadFromGallery),
                subtitle: Text(AppLocalizations.of(context)!.selectImageOrPdf),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocumentFromGallery();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0XFFF9F9F9), child: Icon(Icons.camera_alt, color: Color(0XFFFF0B01))),
                title: Text(AppLocalizations.of(context)!.takeAPhoto),
                subtitle: Text(AppLocalizations.of(context)!.captureUsingCamera),
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

  int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return hour * 60 + minute;
    }
    return 0;
  }

  Widget _timePickerField(
    String label,
    String currentTime,
    Function(String) onTimeSelected, {
    String? compareTime,
    bool isOpening = true,
  }) {
    final hasSameTimeConflict = compareTime != null && _timeToMinutes(currentTime) == _timeToMinutes(compareTime);
    final hasOrderConflict = compareTime != null &&
        (isOpening
            ? _timeToMinutes(currentTime) > _timeToMinutes(compareTime)
            : _timeToMinutes(compareTime) > _timeToMinutes(currentTime));
    final hasError = hasSameTimeConflict || hasOrderConflict;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0XFF909090))),
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
              if (compareTime != null) {
                final pickedMinutes = picked.hour * 60 + picked.minute;
                final compareMinutes = _timeToMinutes(compareTime);
                if (pickedMinutes == compareMinutes) {
                  if (mounted) {
                    FlushbarHelper.show(
                      context,
                      "Opening time and closing time cannot be the same.",
                    );
                  }
                  return;
                }
                if (isOpening && pickedMinutes > compareMinutes) {
                  if (mounted) {
                    FlushbarHelper.show(
                      context,
                      "Opening time cannot be after closing time ($compareTime).",
                    );
                  }
                  return;
                }
                if (!isOpening && pickedMinutes < compareMinutes) {
                  if (mounted) {
                    FlushbarHelper.show(
                      context,
                      "Closing time cannot be before opening time ($compareTime).",
                    );
                  }
                  return;
                }
              }
              onTimeSelected(formattedTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0XFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError ? const Color(0XFFFF0B01) : const Color(0XFFE0E0E0),
                width: hasError ? 1.5 : 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentTime,
                  style: TextStyle(
                    color: hasError ? const Color(0XFFFF0B01) : Colors.black,
                    fontWeight: hasError ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: hasError ? const Color(0XFFFF0B01) : const Color(0XFF909090),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityTypeAhead() {
    return TypeAheadField<Map<String, dynamic>>(
      controller: cityNameController,
      focusNode: cityFocusNode,
      debounceDuration: const Duration(milliseconds: 400),
      suggestionsCallback: (pattern) async {
        if (pattern.trim().length < 2) return [];
        return await _searchService.searchExternalLocations(pattern, featureClass: 'city', stateName: _stateDisplayName);
      },
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.location_city, color: Color(0XFF909090)),
            ),
            suffixIcon: cityNameController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Color(0XFF8B8989)),
                    onPressed: () {
                      setState(() {
                        cityNameController.clear();
                        areaNameController.clear();
                        _selectedAreaDistrict = '';
                        landmarkController.clear();
                        _nearbyLandmarks = [];
                        specificAddressController.clear();
                        _shopOrFlatNo = '';
                        _buildingName = '';
                      });
                    },
                  )
                : null,
            hintText: AppLocalizations.of(context)!.cityTitle,
            hintStyle: const TextStyle(color: Color(0XFFADADAD), fontSize: 13),
            filled: true,
            fillColor: const Color(0XFFF9F9F9),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0XFFE0E0E0), width: 1.2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0XFFFF0B01), width: 1.6)),
          ),
          onChanged: (val) {
             setState(() {
               areaNameController.clear();
               _selectedAreaDistrict = '';
               landmarkController.clear();
               _nearbyLandmarks = [];
               specificAddressController.clear();
               _shopOrFlatNo = '';
               _buildingName = '';
             });
          },
        );
      },
      itemBuilder: (context, suggestion) {
        final name = suggestion['name'] ?? '';
        return ListTile(
          dense: true,
          leading: const Icon(Icons.location_city, size: 18, color: Color(0XFFFF0B01)),
          title: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        );
      },
      onSelected: (suggestion) {
        setState(() {
          cityNameController.text = suggestion['name'] ?? '';
          areaNameController.clear();
          _selectedAreaDistrict = '';
          landmarkController.clear();
          _nearbyLandmarks = [];
          specificAddressController.clear();
          _shopOrFlatNo = '';
          _buildingName = '';
        });
        areaFocusNode.requestFocus();
      },
      emptyBuilder: (context) => const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text('No results found.', style: TextStyle(color: Colors.grey)),
      ),
      loadingBuilder: (context) => const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text('Searching...', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildAreaTypeAhead() {
    return TypeAheadField<Map<String, dynamic>>(
      controller: areaNameController,
      focusNode: areaFocusNode,
      debounceDuration: const Duration(milliseconds: 400),
      suggestionsCallback: (pattern) async {
        if (pattern.trim().length < 2) return [];
        return await _searchService.searchExternalLocations(
          pattern,
          featureClass: 'area',
          cityName: cityNameController.text.trim(),
          stateName: _stateDisplayName,
        );
      },
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.location_on, color: Color(0XFF909090)),
            ),
            suffixIcon: areaNameController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Color(0XFF8B8989)),
                    onPressed: () {
                      setState(() {
                        areaNameController.clear();
                        _selectedAreaDistrict = '';
                        landmarkController.clear();
                        _nearbyLandmarks = [];
                        specificAddressController.clear();
                        _shopOrFlatNo = '';
                        _buildingName = '';
                      });
                    },
                  )
                : null,
            hintText: AppLocalizations.of(context)!.areaTitle,
            hintStyle: const TextStyle(color: Color(0XFFADADAD), fontSize: 13),
            filled: true,
            fillColor: const Color(0XFFF9F9F9),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0XFFE0E0E0), width: 1.2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0XFFFF0B01), width: 1.6)),
          ),
          onChanged: (val) {
             setState(() {
               _selectedAreaDistrict = '';
               landmarkController.clear();
               _nearbyLandmarks = [];
               specificAddressController.clear();
               _shopOrFlatNo = '';
               _buildingName = '';
             });
          },
        );
      },
      itemBuilder: (context, suggestion) {
        final name = suggestion['name'] ?? '';
        final details = suggestion['city'] ?? '';
        return ListTile(
          dense: true,
          leading: const Icon(Icons.place, size: 18, color: Color(0XFFFF0B01)),
          title: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: details.isNotEmpty ? Text(details, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)) : null,
        );
      },
      onSelected: (suggestion) {
        setState(() {
          areaNameController.text = suggestion['name'] ?? '';
          _selectedAreaDistrict = suggestion['district'] ?? '';
          landmarkController.clear();
          _nearbyLandmarks = [];
          specificAddressController.clear();
          _shopOrFlatNo = '';
          _buildingName = '';
        });
        FocusScope.of(context).unfocus();
      },
      emptyBuilder: (context) => const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text('No results found.', style: TextStyle(color: Colors.grey)),
      ),
      loadingBuilder: (context) => const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text('Searching...', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildLandmarkTypeAhead() {
    return TypeAheadField<Map<String, dynamic>>(
      controller: landmarkController,
      focusNode: landmarkFocusNode,
      debounceDuration: const Duration(milliseconds: 400),
      suggestionsCallback: (pattern) async {
        if (pattern.trim().length < 2) return [];
        return await _searchService.searchLandmarks(
          pattern,
          cityName: cityNameController.text.trim(),
          stateName: _stateDisplayName,
          areaName: areaNameController.text.trim(),
          districtName: _selectedAreaDistrict,
        );
      },
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.location_on, color: Color(0XFF909090)),
            ),
            suffixIcon: landmarkController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Color(0XFF8B8989)),
                    onPressed: () {
                      setState(() {
                        landmarkController.clear();
                      });
                    },
                  )
                : null,
            hintText: "Landmark (Optional)",
            hintStyle: const TextStyle(color: Color(0XFFADADAD), fontSize: 13),
            filled: true,
            fillColor: const Color(0XFFF9F9F9),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0XFFE0E0E0), width: 1.2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0XFFFF0B01), width: 1.6)),
          ),
          onChanged: (val) {
             setState(() {});
          },
        );
      },
      itemBuilder: (context, suggestion) {
        final name = suggestion['name'] ?? '';
        final details = suggestion['city'] ?? '';
        return ListTile(
          dense: true,
          leading: const Icon(Icons.location_on, size: 18, color: Color(0XFFFF0B01)),
          title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: details.isNotEmpty ? Text(details, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
        );
      },
      onSelected: (suggestion) {
        setState(() {
          landmarkController.text = suggestion['name'] ?? '';
        });
        FocusScope.of(context).unfocus();
      },
      emptyBuilder: (context) => const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text('No results found.', style: TextStyle(color: Colors.grey)),
      ),
      loadingBuilder: (context) => const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text('Searching...', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  String _getFormattedAddress() {
    final specific = specificAddressController.text.trim();
    final landmark = landmarkController.text.trim();
    final area = areaNameController.text.trim();
    final city = cityNameController.text.trim();
    final state = _stateDisplayName;

    final components = <String>[];
    if (specific.isNotEmpty) components.add(specific);
    if (landmark.isNotEmpty) components.add('near $landmark');
    if (area.isNotEmpty) components.add(area);
    if (city.isNotEmpty) components.add(city);
    if (state.isNotEmpty) components.add(state);

    return components.join(', ');
  }

  Widget _buildAddressPreview() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        specificAddressController,
        landmarkController,
        areaNameController,
        cityNameController,
      ]),
      builder: (context, _) {
        final specific = specificAddressController.text.trim();
        final landmark = landmarkController.text.trim();
        final area = areaNameController.text.trim();
        final city = cityNameController.text.trim();
        final state = _stateDisplayName;

        final components = <String>[];
        if (specific.isNotEmpty) components.add(specific);
        if (landmark.isNotEmpty) components.add('near $landmark');
        if (area.isNotEmpty) components.add(area);
        if (city.isNotEmpty) components.add(city);
        if (state.isNotEmpty) components.add(state);

        if (components.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(top: 15),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0XFFF9F9F9),
            border: Border.all(color: const Color(0XFFE0E0E0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 18, color: Color(0XFFFF0B01)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Address Preview",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      components.join(', '),
                      style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
