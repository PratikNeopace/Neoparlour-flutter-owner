import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/providers/salon_provider.dart';
import 'package:neo_parlour_owner/core/utils/download_helper.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_login.dart';
import 'package:neo_parlour_owner/widgets/premium_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:neo_parlour_owner/core/data/services/search_service.dart';
import 'package:neo_parlour_owner/data/models/salon_profile_model.dart';
import 'package:neo_parlour_owner/widgets/salon_location_card.dart';
import 'package:neo_parlour_owner/l10n/generated/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _salonNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _homeChargesController = TextEditingController();
  
  // Salon Location & Entrance
  double? _salonLatitude;
  double? _salonLongitude;
  final TextEditingController _salonSpecificAddressController = TextEditingController();
  final TextEditingController _salonLandmarkController = TextEditingController();
  final TextEditingController _salonCityController = TextEditingController();
  final TextEditingController _salonAreaController = TextEditingController();
  String _salonShopOrFlatNo = '';
  String _salonBuildingName = '';
  List<String> _salonNearbyLandmarks = [];
  
  // Discount Controllers
  final TextEditingController _weekdayDiscountController = TextEditingController();
  final TextEditingController _morningController = TextEditingController();
  final TextEditingController _afternoonController = TextEditingController();
  final TextEditingController _eveningController = TextEditingController();
  final TextEditingController _nightController = TextEditingController();
  
  DiscountMode _selectedDiscountMode = DiscountMode.NONE;
  
  String _selectedGender = 'Select Gender'; // Initial state can be just a string, we'll update it later if needed or in build where we have context.
  String _selectedWeeklyOff = 'NONE';
  String _openingTime = '09:00';
  String _closingTime = '21:00';
  String _salonCode = '';

  String _salonPhone = '';
  bool _isEditing = false;
  bool _isLoadingData = false;

  String? _mainSalonImageUrl;
  String? _mainSalonImageBase64;
  List<dynamic> _salonGalleryImageUrls = [];
  final List<String> _salonGalleryImagesBase64 = [];
  String? _selectedDocumentType;

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

  final SearchService _searchService = SearchService();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _areaFocusNode = FocusNode();
  List<Map<String, dynamic>> _citySuggestions = [];
  List<Map<String, dynamic>> _areaSuggestions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    if (_isLoadingData) return;
    _isLoadingData = true;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final salonProvider = Provider.of<SalonProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      final bool isOwner = authProvider.user?.role == 'SALON_OWNER' || authProvider.user?.role == 'OWNER';
      
      // Fetch User Profile (Owner or Staff)
      await authProvider.fetchProfile(authProvider.user!.id);
      
      if (isOwner) {
        // Only fetch Salon Profile for Owners
        await salonProvider.fetchSalonProfile();
      }
      
      final user = authProvider.user!;
      final salon = salonProvider.salonProfile;
      
      setState(() {
        // Owner Profile Data
        _nameController.text = user.name;
        _phoneController.text = user.phone;
        if (user.birthdate != null && user.birthdate!.isNotEmpty) {
           _dobController.text = user.birthdate!.split('T')[0].split(' ')[0];
        } else {
          _dobController.text = '';
        }
        _selectedGender = user.gender ?? AppLocalizations.of(context)!.selectGender;
        _addressController.text = user.address ?? '';
        _cityController.text = user.cityName ?? '';
        _areaController.text = user.areaName ?? '';
        
        // Salon Profile Data
        if (salon != null) {
          _salonNameController.text = salon.salonName ?? '';
          _salonLatitude = salon.latitude ?? user.latitude;
          _salonLongitude = salon.longitude ?? user.longitude;
          final rawSpecific = (salon.specificAddress ?? salon.address ?? '').trim();
          _salonSpecificAddressController.text = rawSpecific;
          if (rawSpecific.isNotEmpty) {
            if (rawSpecific.contains(',')) {
              final parts = rawSpecific.split(',');
              _salonShopOrFlatNo = parts[0].trim();
              _salonBuildingName = parts.sublist(1).join(',').trim();
            } else {
              _salonBuildingName = rawSpecific;
              _salonShopOrFlatNo = '';
            }
          } else {
            _salonShopOrFlatNo = '';
            _salonBuildingName = '';
          }
          _salonLandmarkController.text = salon.landmark ?? '';
          _salonCityController.text = salon.city ?? user.cityName ?? '';
          _salonAreaController.text = salon.area ?? user.areaName ?? '';
          _homeChargesController.text = salon.homeServiceCharges?.toString() ?? '0';
          _weekdayDiscountController.text = salon.weekdayDiscount?.toString() ?? '0';
          _morningController.text = salon.morningDiscount?.toString() ?? '0';
          _afternoonController.text = salon.afternoonDiscount?.toString() ?? '0';
          _eveningController.text = salon.eveningDiscount?.toString() ?? '0';
          _nightController.text = salon.nightDiscount?.toString() ?? '0';
          _selectedDiscountMode = salon.activeDiscountMode;
          _selectedWeeklyOff = salon.weeklyOffDay ?? 'NONE';
          _openingTime = salon.openingTime ?? '09:00';
          _closingTime = salon.closingTime ?? '21:00';
          _salonCode = salon.salonCode ?? '';

          _salonPhone = salon.phone ?? '';
          _mainSalonImageUrl = salon.imageUrl;
          _salonGalleryImageUrls = List.from(salon.salonImages ?? []);
          _mainSalonImageBase64 = null;
          _salonGalleryImagesBase64.clear();
        } else {
          // Fallback to user data if salon profile fetch fails
          _salonNameController.text = user.salonName ?? '';
          _salonLatitude = user.latitude;
          _salonLongitude = user.longitude;
          final rawUserAddress = (user.address ?? '').trim();
          _salonSpecificAddressController.text = rawUserAddress;
          if (rawUserAddress.isNotEmpty) {
            if (rawUserAddress.contains(',')) {
              final parts = rawUserAddress.split(',');
              _salonShopOrFlatNo = parts[0].trim();
              _salonBuildingName = parts.sublist(1).join(',').trim();
            } else {
              _salonBuildingName = rawUserAddress;
              _salonShopOrFlatNo = '';
            }
          } else {
            _salonShopOrFlatNo = '';
            _salonBuildingName = '';
          }
          _salonCityController.text = user.cityName ?? '';
          _salonAreaController.text = user.areaName ?? '';
          _homeChargesController.text = user.homeServiceCharges?.toString() ?? '0';
          _weekdayDiscountController.text = '0';
          _morningController.text = '0';
          _afternoonController.text = '0';
          _eveningController.text = '0';
          _nightController.text = '0';
          _selectedDiscountMode = DiscountMode.NONE;
          _selectedWeeklyOff = user.weeklyOffDay ?? 'NONE';
          _openingTime = user.openingTime ?? '09:00';
          _closingTime = user.closingTime ?? '21:00';
          _salonCode = user.salonCode ?? '';
          _mainSalonImageBase64 = null;
          _salonGalleryImagesBase64.clear();
        }
      });
      
      
      salonProvider.fetchSalonQRCode(); // Fetch QR in background for both Owner and Staff
    }
    _isLoadingData = false;
  }

  void _saveOwnerProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    final Map<String, dynamic> data = {
      'id': user.role == 'STAFF' ? (user.staffId ?? user.id) : user.id,
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': user.email,
      'birthdate': _dobController.text.isNotEmpty 
          ? (_dobController.text.contains('T') ? _dobController.text : "${_dobController.text}T00:00:00.000Z")
          : null,
      'gender': _selectedGender == AppLocalizations.of(context)!.selectGender ? null : _selectedGender,
      'salonId': user.salonId,
      'salonName': _salonNameController.text,
      'address': _addressController.text.isEmpty ? null : _addressController.text,
      'cityName': _cityController.text.isEmpty ? null : _cityController.text,
      'areaName': _areaController.text.isEmpty ? null : _areaController.text,
      'role': user.role,
      'active': user.active,
      'imageBase64': user.imageBase64,
      'latitude': _salonLatitude ?? user.latitude,
      'longitude': _salonLongitude ?? user.longitude,
      'password': null,
      'fcmToken': user.fcmToken,
    };

    if (user.role == 'STAFF') {
      data['homeServiceCharges'] = null;
      data['updatedAt'] = null;
      data['openingTime'] = null;
      data['closingTime'] = null;
    } else {
      final openMin = _timeToMinutes(_openingTime);
      final closeMin = _timeToMinutes(_closingTime);
      if (openMin == closeMin) {
        FlushbarHelper.show(context, "Opening time and closing time cannot be the same.");
        return;
      }
      if (openMin > closeMin) {
        FlushbarHelper.show(context, "Closing time must be after opening time.");
        return;
      }
      data['homeServiceCharges'] = double.tryParse(_homeChargesController.text) ?? 0;
      data['weeklyOffDay'] = _selectedWeeklyOff;
      data['salonCode'] = _salonCode;
      data['openingTime'] = _openingTime;
      data['closingTime'] = _closingTime;
    }


    final success = await authProvider.updateProfile(data);
    if (success && mounted) {
      final roleName = (user.role == 'SALON_OWNER' || user.role == 'OWNER') ? "Owner" : "Staff";
      FlushbarHelper.show(context, "$roleName profile updated successfully", isSuccess: true);
      setState(() => _isEditing = false);
      _loadProfile();
    } else if (mounted) {
      final error = authProvider.errorMessage ?? "Update failed";
      FlushbarHelper.show(context, error);
    }
  }

  void _saveSalonProfile() async {
    final salonProvider = Provider.of<SalonProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final salon = salonProvider.salonProfile;
    final user = authProvider.user;
    if (salon == null) return;

    final openMin = _timeToMinutes(_openingTime);
    final closeMin = _timeToMinutes(_closingTime);
    if (openMin == closeMin) {
      FlushbarHelper.show(context, "Opening time and closing time cannot be the same.");
      return;
    }
    if (openMin > closeMin) {
      FlushbarHelper.show(context, "Closing time must be after opening time.");
      return;
    }

    final Map<String, dynamic> data = {
      'salonId': salon.salonId,
      'name': null,
      'phone': salon.phone,
      'email': salon.email,
      'salonName': _salonNameController.text,
      'cityName': _salonCityController.text.isNotEmpty ? _salonCityController.text : salon.city,
      'areaName': _salonAreaController.text.isNotEmpty ? _salonAreaController.text : salon.area,
      'address': _salonSpecificAddressController.text.isNotEmpty
          ? _salonSpecificAddressController.text
          : (_addressController.text.isNotEmpty ? _addressController.text : salon.address),
      'specificAddress': _salonSpecificAddressController.text.isNotEmpty
          ? _salonSpecificAddressController.text
          : salon.specificAddress,
      'landmark': _salonLandmarkController.text.isNotEmpty
          ? _salonLandmarkController.text
          : salon.landmark,
      'birthdate': null,
      'latitude': _salonLatitude ?? salon.latitude ?? user?.latitude,
      'longitude': _salonLongitude ?? salon.longitude ?? user?.longitude,
      'role': null,
      'active': salon.active,
      'createdAt': salon.createdAt,
      'updatedAt': null,
      'imageUrl': _mainSalonImageUrl,
      'qrCodeUrl': salon.qrCodeUrl,
      'salonCode': salon.salonCode,
      'openingTime': _openingTime,
      'closingTime': _closingTime,
      'homeServiceCharges': double.tryParse(_homeChargesController.text),
      'weekdayDiscount': _selectedDiscountMode == DiscountMode.WEEKDAY ? (double.tryParse(_weekdayDiscountController.text) ?? 0.0) : 0.0,
      'morningDiscount': _selectedDiscountMode == DiscountMode.CATEGORY ? (double.tryParse(_morningController.text) ?? 0.0) : 0.0,
      'afternoonDiscount': _selectedDiscountMode == DiscountMode.CATEGORY ? (double.tryParse(_afternoonController.text) ?? 0.0) : 0.0,
      'eveningDiscount': _selectedDiscountMode == DiscountMode.CATEGORY ? (double.tryParse(_eveningController.text) ?? 0.0) : 0.0,
      'nightDiscount': _selectedDiscountMode == DiscountMode.CATEGORY ? (double.tryParse(_nightController.text) ?? 0.0) : 0.0,
      'weeklyOffDay': _selectedWeeklyOff,
      'rating': null,
      'salonImages': _salonGalleryImageUrls,
      'isFavourite': null,
      'imageBase64': _mainSalonImageBase64,
      'salonImagesBase64': _salonGalleryImagesBase64.isNotEmpty ? _salonGalleryImagesBase64 : null,
    };

    final success = await salonProvider.updateSalonProfile(data);
    if (success && mounted) {
      FlushbarHelper.show(context, "Salon profile updated successfully", isSuccess: true);
      setState(() => _isEditing = false);
      _loadProfile();
    } else if (mounted) {
      final error = salonProvider.errorMessage ?? "Update failed";
      FlushbarHelper.show(context, error);
    }
  }

  void _confirmDeleteAccount() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final successMessage = await authProvider.deleteAccount();
              if (successMessage != null && mounted) {
                final nav = Navigator.of(context);
                // Return to owner login first
                nav.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SalonOwnerLoginScreen()),
                  (route) => false,
                );
                // Show flushbar after screen transition starts
                Future.delayed(const Duration(milliseconds: 300), () {
                  FlushbarHelper.show(nav.context, successMessage, isSuccess: true);
                });
              } else if (mounted) {
                final error = authProvider.errorMessage ?? "Deletion failed";
                FlushbarHelper.show(context, error);
              }
            },
            child: const Text("DELETE", style: TextStyle(color: Color(0XFFFF0B01))),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _salonNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _homeChargesController.dispose();
    _weekdayDiscountController.dispose();
    _salonSpecificAddressController.dispose();
    _salonLandmarkController.dispose();
    _salonCityController.dispose();
    _salonAreaController.dispose();
    _cityFocusNode.dispose();
    _areaFocusNode.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0XFF2D2D2D),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isLoading, VoidCallback onPressed) {
    if (!_isEditing) return const SizedBox.shrink();
    
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0XFFFF0B01),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                AppLocalizations.of(context)!.saveChanges,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  Widget _buildDeleteAccountLink() {
    return GestureDetector(
      onTap: _confirmDeleteAccount,
      child: Text(
        AppLocalizations.of(context)!.deleteAccount,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0XFFFF0B01),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: authProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)))
            : SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 60,
                ),
                child: Column(
                  children: [
                    // ================= HEADER =================
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipPath(
                          clipper: EditProfileHeaderClipper(),
                          child: Container(
                            height: size.height * 0.28,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/Images/ChangePasswordScreen/change_password_bg_image.jpg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(left: 20, bottom: 20),
                              alignment: Alignment.bottomLeft,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0XFF8B8B8B).withValues(alpha: 0.4),
                                    const Color(0XFFFF3502).withValues(alpha: 0.2),
                                  ],
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.editProfileTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // FLOATING EDIT ICON & LABEL
                        Positioned(
                          bottom: -40,
                          right: 24,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isEditing = !_isEditing;
                                  });
                                },
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: _isEditing ? Colors.black : const Color(0XFFFF0B01),
                                    shape: BoxShape.circle,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      _isEditing 
                                        ? "assets/Images/EditProfileScreen/username_edit_icon.svg"
                                        : "assets/Images/EditProfileScreen/edit_floating_button.svg",
                                      width: 22,
                                      height: 22,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isEditing ? AppLocalizations.of(context)!.cancelBtn : AppLocalizations.of(context)!.editBtn,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Back Button
                        Positioned(
                          top: size.height * 0.06,
                          left: 20,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withValues(alpha: 0.4),
                              child: const Icon(
                                Icons.chevron_left,
                                size: 30,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ================= CONTENT =================
                    DefaultTabController(
                      length: (authProvider.user?.role == 'SALON_OWNER' || authProvider.user?.role == 'OWNER') ? 2 : 1,
                      child: Column(
                        children: [
                          TabBar(
                            indicatorColor: const Color(0XFFFF0B01),
                            labelColor: const Color(0XFFFF0B01),
                            unselectedLabelColor: Colors.grey,
                            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            tabs: [
                              Tab(text: (authProvider.user?.role == 'SALON_OWNER' || authProvider.user?.role == 'OWNER') ? AppLocalizations.of(context)!.ownerProfileTab : AppLocalizations.of(context)!.staffProfileTab),
                              if (authProvider.user?.role == 'SALON_OWNER' || authProvider.user?.role == 'OWNER')
                                Tab(text: AppLocalizations.of(context)!.salonProfileTab),
                            ],
                          ),
                          SizedBox(
                            height: size.height * 0.75, // Adjust height based on content
                            child: TabBarView(
                              children: [
                                // Tab 1: Profile (Owner or Staff)
                                SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 120),
                                  child: Column(
                                    children: [
                                      _buildSectionHeader(AppLocalizations.of(context)!.personalDetails),
                                      const SizedBox(height: 15),
                                      _buildInputField(
                                        "assets/Images/EditProfileScreen/enter_name_icon.svg",
                                        AppLocalizations.of(context)!.fullName,
                                        _nameController,
                                      ),
                                      const SizedBox(height: 15),
                                      _buildInputField(
                                        "assets/Images/EditProfileScreen/dob_icon.svg",
                                        AppLocalizations.of(context)!.dob,
                                        _dobController,
                                        readOnly: true,
                                        onTap: !_isEditing ? null : () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime.now(),
                                          );
                                          if (date != null) {
                                            setState(() {
                                              _dobController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                                            });
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 15),
                                      _buildDropdownField(
                                        "assets/Images/EditProfileScreen/gender_icon.svg",
                                        _selectedGender == 'Select Gender' ? AppLocalizations.of(context)!.selectGender : _selectedGender,
                                      ),
                                      const SizedBox(height: 15),
                                      _buildInputField(
                                        "assets/Images/EditProfileScreen/mobile_number_icon.svg",
                                        AppLocalizations.of(context)!.mobileNumber,
                                        _phoneController,
                                        keyboardType: TextInputType.phone,
                                      ),
                                      const SizedBox(height: 25),
                                      _buildSectionHeader(AppLocalizations.of(context)!.contactInfo),
                                      const SizedBox(height: 15),
                                      _buildInputField(
                                        "assets/Images/EditProfileScreen/enter_name_icon.svg",
                                        AppLocalizations.of(context)!.address,
                                        _addressController,
                                        maxLines: 2,
                                      ),
                                      const SizedBox(height: 15),
                                       if (authProvider.user?.role == "SALON_OWNER" || authProvider.user?.role == "OWNER")
                                      Column(
                                        children: [
                                          _buildCityTypeAhead(),
                                          const SizedBox(height: 15),
                                          _buildAreaTypeAhead(),
                                        ],
                                      ),
                                       const SizedBox(height: 35),
                                       _buildSaveButton(authProvider.isLoading, _saveOwnerProfile),
                                       const SizedBox(height: 25),
                                       _buildDeleteAccountLink(),
                                       const SizedBox(height: 35),
                                       if (authProvider.user?.role == 'STAFF')
                                          _buildQRCodeSection(),
                                       const SizedBox(height: 120),
                                    ],
                                  ),
                                ),
                                // Tab 2: Salon Profile (Only for Owners)
                                if (authProvider.user?.role == 'SALON_OWNER' || authProvider.user?.role == 'OWNER')
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 120),
                                    child: Column(
                                      children: [
                                        _buildSectionHeader(AppLocalizations.of(context)!.salonDetails),
                                        const SizedBox(height: 15),
                                        _buildInputField(
                                          "assets/Images/AddPackageScreen/package_details_icon.svg",
                                          AppLocalizations.of(context)!.salonName,
                                          _salonNameController,
                                        ),
                                        const SizedBox(height: 15),
                                        _buildInputField(
                                          "assets/Images/RegisterScreen/username.svg",
                                          AppLocalizations.of(context)!.salonCode,
                                          TextEditingController(text: _salonCode),
                                          readOnly: true,
                                        ),
                                        const SizedBox(height: 15),
                                        _buildInputField(
                                          "assets/Images/EditProfileScreen/mobile_number_icon.svg",
                                          AppLocalizations.of(context)!.salonPhone,
                                          TextEditingController(text: _salonPhone),
                                          readOnly: true,
                                        ),
                                        const SizedBox(height: 25),
                                        _buildSectionHeader("Salon Location & Entrance"),
                                        const SizedBox(height: 15),
                                        SalonLocationCard(
                                          latitude: _salonLatitude,
                                          longitude: _salonLongitude,
                                          shopOrFlatNo: _salonShopOrFlatNo,
                                          buildingName: _salonBuildingName,
                                          specificAddress: _salonSpecificAddressController.text,
                                          landmark: _salonLandmarkController.text,
                                          areaName: _salonAreaController.text.isNotEmpty ? _salonAreaController.text : _areaController.text,
                                          cityName: _salonCityController.text.isNotEmpty ? _salonCityController.text : _cityController.text,
                                          nearbyLandmarks: _salonNearbyLandmarks,
                                          onBeforeEdit: () {
                                            if (!_isEditing) {
                                              setState(() => _isEditing = true);
                                            }
                                          },
                                          onLocationChanged: (details) {
                                            setState(() {
                                              _isEditing = true;
                                              _salonLatitude = details.latitude;
                                              _salonLongitude = details.longitude;
                                              _salonShopOrFlatNo = details.shopOrFlatNo;
                                              _salonBuildingName = details.buildingName;
                                              _salonSpecificAddressController.text = details.specificAddress;
                                              if (details.formattedAddress.isNotEmpty) {
                                                _addressController.text = details.formattedAddress;
                                              }
                                              _salonLandmarkController.text = details.landmark;
                                              if (details.areaName.isNotEmpty) {
                                                _salonAreaController.text = details.areaName;
                                                _areaController.text = details.areaName;
                                              }
                                              if (details.cityName.isNotEmpty) {
                                                _salonCityController.text = details.cityName;
                                                _cityController.text = details.cityName;
                                              }
                                              _salonNearbyLandmarks = details.nearbyLandmarks;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 15),
                                        _buildInputField(
                                          "assets/Images/RegisterScreen/username.svg",
                                          "Shop / Building / Specific Address",
                                          _salonSpecificAddressController,
                                        ),
                                        const SizedBox(height: 15),
                                        _buildInputField(
                                          "assets/Images/RegisterScreen/username.svg",
                                          "Landmark (e.g. Near Karishma Society)",
                                          _salonLandmarkController,
                                        ),
                                        const SizedBox(height: 15),
                                        _buildInputField(
                                          "assets/Images/RegisterScreen/username.svg",
                                          "Area",
                                          _salonAreaController,
                                          onChanged: (val) {
                                            setState(() {
                                              _salonSpecificAddressController.clear();
                                              _salonShopOrFlatNo = '';
                                              _salonBuildingName = '';
                                              _salonLandmarkController.clear();
                                              _salonNearbyLandmarks = [];
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 15),
                                        _buildInputField(
                                          "assets/Images/RegisterScreen/username.svg",
                                          "City",
                                          _salonCityController,
                                          onChanged: (val) {
                                            setState(() {
                                              _salonSpecificAddressController.clear();
                                              _salonShopOrFlatNo = '';
                                              _salonBuildingName = '';
                                              _salonAreaController.clear();
                                              _salonLandmarkController.clear();
                                              _salonNearbyLandmarks = [];
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 25),
                                        _buildSectionHeader(AppLocalizations.of(context)!.businessHours),
                                         if (authProvider.user?.role == 'SALON_OWNER' || authProvider.user?.role == 'OWNER') ...[
                                           Row(
                                             children: [
                                               Expanded(
                                                 child: _buildTimePickerField(
                                                   AppLocalizations.of(context)!.openingTime,
                                                   _openingTime,
                                                   (t) => setState(() => _openingTime = t),
                                                   compareTime: _closingTime,
                                                   isOpening: true,
                                                 ),
                                               ),
                                               const SizedBox(width: 15),
                                               Expanded(
                                                 child: _buildTimePickerField(
                                                   AppLocalizations.of(context)!.closingTime,
                                                   _closingTime,
                                                   (t) => setState(() => _closingTime = t),
                                                   compareTime: _openingTime,
                                                   isOpening: false,
                                                 ),
                                               ),
                                             ],
                                           ),
                                           if (_isEditing && _timeToMinutes(_openingTime) == _timeToMinutes(_closingTime)) ...[
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
                                           ] else if (_isEditing && _timeToMinutes(_openingTime) > _timeToMinutes(_closingTime)) ...[
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
                                         ],
                                        const SizedBox(height: 15),
                                         _buildWeeklyOffDropdown(),
                                         const SizedBox(height: 15),
                                         _buildLabeledField(
                                           AppLocalizations.of(context)!.homeServiceCharges,
                                           _buildInputField(
                                             "assets/Images/HomeScreen/revenue_icon.svg",
                                             AppLocalizations.of(context)!.homeServiceCharges,
                                             _homeChargesController,
                                             keyboardType: TextInputType.number,
                                           ),
                                         ),
                                         const SizedBox(height: 35),
                                         _buildDiscountSettings(),
                                         const SizedBox(height: 35),
                                         _buildSalonMediaSection(),
                                         const SizedBox(height: 35),
                                        _buildSaveButton(Provider.of<SalonProvider>(context).isLoading, _saveSalonProfile),
                                        const SizedBox(height: 35),
                                        _buildQRCodeSection(),
                                        const SizedBox(height: 120),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLabeledField(String label, Widget field) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0XFF909090),
        ),
      ),
      const SizedBox(height: 6),
      field,
    ],
  );
}

  Widget _buildQRCodeSection() {
    if (_isEditing) return const SizedBox.shrink(); // Hide QR when editing

    return Consumer<SalonProvider>(
      builder: (consumerContext, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.qrCode == null) {
          return const SizedBox.shrink();
        }
        
        final qr = provider.qrCode!;
        return Column(
          children: [
            Text(
              AppLocalizations.of(context)!.salonQrCodeTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Column(
                children: [
                  qr.qrCodeUrl != null && qr.qrCodeUrl!.isNotEmpty
                      ? PremiumImageWidget(
                          imageUrl: qr.qrCodeUrl,
                          width: 200,
                          height: 200,
                        )
                      : Image.memory(qr.qrCode, width: 200, height: 200),
                  const SizedBox(height: 8),
                  Text(
                    qr.salonCode,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0XFFFF0B01)),
                  ),
                  Text(
                    qr.salonName,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (qr.qrCodeUrl != null && qr.qrCodeUrl!.isNotEmpty) {
                        try {
                          final response = await http.get(Uri.parse(qr.qrCodeUrl!));
                          if (response.statusCode == 200) {
                            await downloadFileBytes(
                              response.bodyBytes,
                              "salon_qr_${qr.salonCode}.png",
                            );
                          } else {
                            throw Exception("Failed to download image");
                          }
                        } catch (e) {
                          if (mounted) {
                            FlushbarHelper.show(context, "Error downloading QR: $e");
                          }
                        }
                      } else {
                        await downloadFileBytes(
                          qr.qrCode,
                          "salon_qr_${qr.salonCode}.png",
                        );
                      }
                    },
                    icon: const Icon(Icons.download, size: 18),
                    label: Text(AppLocalizations.of(context)!.downloadQr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(150, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField(String icon, String hint, TextEditingController controller, {bool readOnly = false, VoidCallback? onTap, ValueChanged<String>? onChanged, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    final bool effectiveReadOnly = readOnly || !_isEditing;
    
    return TextField(
      controller: controller,
      readOnly: effectiveReadOnly,
      onTap: !_isEditing ? null : onTap,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        color: effectiveReadOnly ? Colors.black87 : Colors.black,
        fontWeight: effectiveReadOnly ? FontWeight.w400 : FontWeight.w500,
      ),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: SvgPicture.asset(
            icon,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              effectiveReadOnly ? Colors.grey : const Color(0XFFFF0B01),
              BlendMode.srcIn,
            ),
          ),
        ),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0XFF8D8D8D),
          fontSize: 14,
        ),
        filled: !effectiveReadOnly,
        fillColor: const Color(0XFFF9F9F9).withValues(alpha: 0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(
            color: effectiveReadOnly ? const Color(0XFFE0E0E0) : const Color(0XFF909090),
            width: effectiveReadOnly ? 0.5 : 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: Color(0XFFFF0B01),
            width: 1.2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    );
  }

  Widget _buildWeeklyOffDropdown() {
    final List<String> days = ['NONE', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(
          color: !_isEditing ? const Color(0XFFE0E0E0) : const Color(0XFF909090),
          width: !_isEditing ? 0.5 : 0.8,
        ),
        borderRadius: BorderRadius.circular(9),
        color: _isEditing ? const Color(0XFFF9F9F9).withValues(alpha: 0.5) : null,
      ),
      child: IgnorePointer(
        ignoring: !_isEditing,
        child: PopupMenuButton<String>(
          onSelected: (String newValue) async {
            setState(() {
              _selectedWeeklyOff = newValue;
            });
            if (newValue != 'NONE') {
               await context.read<SalonProvider>().setWeeklyOffDay(newValue);
            }
          },
          itemBuilder: (BuildContext context) => days.map((day) => PopupMenuItem<String>(value: day, child: Text(day))).toList(),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: _isEditing ? const Color(0XFFFF0B01) : Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Weekly Off: $_selectedWeeklyOff",
                  style: TextStyle(
                    fontSize: 14, 
                    color: _isEditing ? Colors.black : const Color(0XFF8D8D8D),
                  ),
                ),
              ),
              if (_isEditing) const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
        ),
      ),
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

  Widget _buildTimePickerField(
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
    final hasError = _isEditing && (hasSameTimeConflict || hasOrderConflict);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0XFF909090))),
        const SizedBox(height: 5),
        InkWell(
          onTap: !_isEditing ? null : () async {
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
              color: _isEditing ? const Color(0XFFF9F9F9) : Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: hasError
                    ? const Color(0XFFFF0B01)
                    : (!_isEditing ? const Color(0XFFE0E0E0) : const Color(0XFF909090)),
                width: hasError ? 1.5 : (!_isEditing ? 0.5 : 0.8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentTime, 
                  style: TextStyle(
                    color: hasError
                        ? const Color(0XFFFF0B01)
                        : (_isEditing ? Colors.black : Colors.black87), 
                    fontSize: 14,
                    fontWeight: hasError ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: hasError
                      ? const Color(0XFFFF0B01)
                      : (_isEditing ? const Color(0XFFFF0B01) : const Color(0XFF909090)),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(
          color: !_isEditing ? const Color(0XFFE0E0E0) : const Color(0XFF909090),
          width: !_isEditing ? 0.5 : 0.8,
        ),
        borderRadius: BorderRadius.circular(9),
        color: _isEditing ? const Color(0XFFF9F9F9).withValues(alpha: 0.5) : null,
      ),
      child: IgnorePointer(
        ignoring: !_isEditing,
        child: PopupMenuButton<String>(
          onSelected: (String newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(value: AppLocalizations.of(context)!.selectGender, child: Text(AppLocalizations.of(context)!.selectGender)),
            const PopupMenuItem<String>(value: 'MALE', child: Text('MALE')),
            const PopupMenuItem<String>(value: 'FEMALE', child: Text('FEMALE')),
            const PopupMenuItem<String>(value: 'OTHER', child: Text('OTHER')),
          ],
          child: Row(
            children: [
              SvgPicture.asset(
                icon,
                height: 18,
                width: 18,
                colorFilter: ColorFilter.mode(
                  _isEditing ? const Color(0XFFFF0B01) : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: _isEditing ? Colors.black : const Color(0XFF8D8D8D),
                  ),
                ),
              ),
              if (_isEditing) const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSalonMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Salon Media"),
        const SizedBox(height: 15),
        const Text("MAIN SALON IMAGE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 8),
        _buildImageUploadBox("MAIN_SALON_IMAGE", _mainSalonImageBase64, _mainSalonImageUrl),
        const SizedBox(height: 15),
        const Text("SALON GALLERY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            final totalImages = _salonGalleryImageUrls.length + _salonGalleryImagesBase64.length;
            
            Widget buildSlot(int index) {
              if (index < totalImages) {
                final isUrl = index < _salonGalleryImageUrls.length;
                final imageSrc = isUrl 
                    ? _salonGalleryImageUrls[index] 
                    : _salonGalleryImagesBase64[index - _salonGalleryImageUrls.length];
                    
                String label = "";
                if (index == 0) label = "1. EXTERIOR VIEW";
                else if (index == 1) label = "2. INTERIOR VIEW 1";
                else if (index == 2) label = "3. INTERIOR VIEW 2";
                else label = "OPTIONAL VIEW";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0XFFF9F9F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0XFFE0E0E0), width: 1.2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: isUrl
                                ? Image.network(
                                    imageSrc,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.broken_image, color: Colors.grey, size: 24),
                                    ),
                                  )
                                : (_decodeBase64(imageSrc) != null
                                    ? Image.memory(
                                        _decodeBase64(imageSrc)!,
                                        fit: BoxFit.cover,
                                        cacheWidth: 300,
                                        errorBuilder: (_, __, ___) => const Center(
                                          child: Icon(Icons.broken_image, color: Colors.grey, size: 24),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(Icons.broken_image, color: Colors.grey, size: 24),
                                      )),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isUrl) {
                                    _salonGalleryImageUrls.remove(imageSrc);
                                  } else {
                                    _salonGalleryImagesBase64.remove(imageSrc);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 16, color: Colors.red),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              } else {
                 return Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     const Text("ADD MORE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.transparent)),
                     const SizedBox(height: 6),
                     GestureDetector(
                      onTap: () {
                         _selectedDocumentType = "SALON_GALLERY";
                         _showUploadOptions(context);
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0XFFF9F9F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0XFFE0E0E0), width: 1.2),
                        ),
                        child: const Center(child: Icon(Icons.add, color: Colors.grey)),
                      ),
                    )
                   ]
                 );
              }
            }

            final List<Widget> primarySlots = [];
            for (int i = 0; i < 3; i++) {
              if (i < totalImages) {
                primarySlots.add(buildSlot(i));
              } else if (i == totalImages && _isEditing) {
                primarySlots.add(buildSlot(i));
              }
            }

            final List<Widget> optionalSlots = [];
            for (int i = 3; i < 5; i++) {
              if (i < totalImages) {
                optionalSlots.add(buildSlot(i));
              } else if (i == totalImages && _isEditing) {
                optionalSlots.add(buildSlot(i));
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: primarySlots,
                ),
                if (optionalSlots.isNotEmpty) ...[
                  const SizedBox(height: 25),
                  const Text("ADDITIONAL GALLERY IMAGES (OPTIONAL - MAX 2)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: optionalSlots,
                  ),
                ]
              ],
            );
          }
        ),
      ],
    );
  }

  Widget _buildImageUploadBox(String docType, String? currentBase64, String? currentUrl) {
    final Uint8List? imageBytes = _decodeBase64(currentBase64);
    final bool hasUrl = currentUrl != null && currentUrl.isNotEmpty;
    final bool hasImage = imageBytes != null || hasUrl;

    return GestureDetector(
      onTap: () {
        if (!_isEditing) return;
        _selectedDocumentType = docType;
        _showUploadOptions(context);
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0XFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasImage ? const Color(0XFFFF0B01) : const Color(0XFFE0E0E0), width: 1.2),
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
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey, size: 28),
                  ),
                )
              else if (hasUrl)
                Image.network(
                  currentUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey, size: 28),
                  ),
                )
              else
                const Center(
                  child: Icon(Icons.add_photo_alternate, color: Colors.grey, size: 30),
                ),
              if (hasImage && _isEditing)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (docType == "MAIN_SALON_IMAGE") {
                          _mainSalonImageBase64 = null;
                          _mainSalonImageUrl = null;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
              const Text("Select Document Source", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0XFFF9F9F9), child: Icon(Icons.photo_library, color: Color(0XFFFF0B01))),
                title: const Text("Upload from Gallery / Files"),
                subtitle: const Text("Select image or PDF document"),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocumentFromGallery();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0XFFF9F9F9), child: Icon(Icons.camera_alt, color: Color(0XFFFF0B01))),
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

  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

  Future<void> _pickDocumentFromGallery() async {
    try {
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
        _handleUploadedFile(image.name, base64Encode(bytes));
      }
    } catch (e) {
      if (mounted) FlushbarHelper.show(context, "Error picking file: $e");
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
        _handleUploadedFile(photo.name, base64Encode(bytes));
      }
    } catch (e) {
      if (mounted) FlushbarHelper.show(context, "Error taking photo: $e");
    }
  }

  void _handleUploadedFile(String name, String base64Content) {
    if (_selectedDocumentType == null) return;

    final decoded = _decodeBase64(base64Content);
    if (decoded != null && decoded.lengthInBytes > _maxFileSizeBytes) {
      if (mounted) FlushbarHelper.show(context, "File size must not exceed 5 MB.");
      return;
    }

    if (_selectedDocumentType == "MAIN_SALON_IMAGE") {
      setState(() {
        _mainSalonImageBase64 = base64Content;
        _mainSalonImageUrl = null;
      });
    } else if (_selectedDocumentType == "SALON_GALLERY") {
      setState(() => _salonGalleryImagesBase64.add(base64Content));
    }
  }
  Widget _buildCityTypeAhead() {
    final bool effectiveReadOnly = !_isEditing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _cityController,
          focusNode: _cityFocusNode,
          readOnly: effectiveReadOnly,
          style: TextStyle(
            color: effectiveReadOnly ? Colors.black87 : Colors.black,
            fontWeight: effectiveReadOnly ? FontWeight.w400 : FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.all(14),
              child: SvgPicture.asset(
                "assets/Images/RegisterScreen/username.svg",
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  effectiveReadOnly ? Colors.grey : const Color(0XFFFF0B01),
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: _cityController.text.isNotEmpty && !effectiveReadOnly
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Color(0XFF8B8989)),
                    onPressed: () {
                      setState(() {
                        _cityController.clear();
                        _citySuggestions = [];
                      });
                    },
                  )
                : null,
            hintText: "City",
            hintStyle: const TextStyle(color: Color(0XFF8D8D8D), fontSize: 14),
            filled: !effectiveReadOnly,
            fillColor: const Color(0XFFF9F9F9).withValues(alpha: 0.5),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(
                color: effectiveReadOnly ? const Color(0XFFE0E0E0) : const Color(0XFF909090),
                width: effectiveReadOnly ? 0.5 : 0.8,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: Color(0XFFFF0B01), width: 1.2),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
          ),
          onChanged: (val) async {
            if (effectiveReadOnly) return;
            if (val.trim().length >= 2) {
              final results = await _searchService.searchExternalLocations(val, featureClass: 'city');
              setState(() {
                _citySuggestions = results;
              });
            } else {
              setState(() => _citySuggestions = []);
            }
          },
        ),
        if (_citySuggestions.isNotEmpty && !effectiveReadOnly)
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 8),
            constraints: const BoxConstraints(maxHeight: 160),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _citySuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _citySuggestions[index];
                final name = suggestion['name'] ?? '';
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_city, size: 18, color: Color(0XFFFF0B01)),
                  title: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  onTap: () {
                    setState(() {
                      _cityController.text = name;
                      _citySuggestions = [];
                    });
                    _areaFocusNode.requestFocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAreaTypeAhead() {
    final bool effectiveReadOnly = !_isEditing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _areaController,
          focusNode: _areaFocusNode,
          readOnly: effectiveReadOnly,
          style: TextStyle(
            color: effectiveReadOnly ? Colors.black87 : Colors.black,
            fontWeight: effectiveReadOnly ? FontWeight.w400 : FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.all(14),
              child: SvgPicture.asset(
                "assets/Images/RegisterScreen/username.svg",
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  effectiveReadOnly ? Colors.grey : const Color(0XFFFF0B01),
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: _areaController.text.isNotEmpty && !effectiveReadOnly
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Color(0XFF8B8989)),
                    onPressed: () {
                      setState(() {
                        _areaController.clear();
                        _areaSuggestions = [];
                      });
                    },
                  )
                : null,
            hintText: "Area",
            hintStyle: const TextStyle(color: Color(0XFF8D8D8D), fontSize: 14),
            filled: !effectiveReadOnly,
            fillColor: const Color(0XFFF9F9F9).withValues(alpha: 0.5),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(
                color: effectiveReadOnly ? const Color(0XFFE0E0E0) : const Color(0XFF909090),
                width: effectiveReadOnly ? 0.5 : 0.8,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: Color(0XFFFF0B01), width: 1.2),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
          ),
          onChanged: (val) async {
            if (effectiveReadOnly) return;
            if (val.trim().length >= 2) {
              final results = await _searchService.searchExternalLocations(
                val,
                featureClass: 'area',
                cityName: _cityController.text.trim(),
              );
              setState(() {
                _areaSuggestions = results;
              });
            } else {
              setState(() => _areaSuggestions = []);
            }
          },
        ),
        if (_areaSuggestions.isNotEmpty && !effectiveReadOnly)
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 8),
            constraints: const BoxConstraints(maxHeight: 160),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _areaSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _areaSuggestions[index];
                final name = suggestion['name'] ?? '';
                final details = suggestion['city'] ?? '';
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.place, size: 18, color: Color(0XFFFF0B01)),
                  title: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: details.isNotEmpty ? Text(details, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)) : null,
                  onTap: () {
                    setState(() {
                      _areaController.text = name;
                      _areaSuggestions = [];
                    });
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDiscountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Discount Settings",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 6),
        const Divider(color: Color(0xFFE5E7EB)),
        const SizedBox(height: 16),
        const Text(
          "Active Discount Mode",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildDiscountModeOption(DiscountMode.NONE, 'No Discount', 'Disable all', Icons.block),
            const SizedBox(width: 8),
            _buildDiscountModeOption(DiscountMode.WEEKDAY, 'Weekday', 'Same discount', Icons.calendar_today),
            const SizedBox(width: 8),
            _buildDiscountModeOption(DiscountMode.CATEGORY, 'Time Slotted', 'Varying slots', Icons.access_time),
          ],
        ),
        const SizedBox(height: 24),
        if (_selectedDiscountMode == DiscountMode.NONE)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Text(
                'Slot discounts are currently disabled.',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        if (_selectedDiscountMode == DiscountMode.WEEKDAY)
          _buildLabeledField(
            "Weekday Discount (%)",
            _buildInputField(
              "assets/Images/HomeScreen/revenue_icon.svg",
              "Weekday Discount",
              _weekdayDiscountController,
              keyboardType: TextInputType.number,
            ),
          ),
        if (_selectedDiscountMode == DiscountMode.CATEGORY)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildLabeledField(
                      "Morning (06 AM - 12 PM)",
                      _buildInputField(
                        "assets/Images/HomeScreen/revenue_icon.svg",
                        "Morning %",
                        _morningController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildLabeledField(
                      "Afternoon (12 PM - 04 PM)",
                      _buildInputField(
                        "assets/Images/HomeScreen/revenue_icon.svg",
                        "Afternoon %",
                        _afternoonController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildLabeledField(
                      "Evening (04 PM - 08 PM)",
                      _buildInputField(
                        "assets/Images/HomeScreen/revenue_icon.svg",
                        "Evening %",
                        _eveningController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildLabeledField(
                      "Night (08 PM - 06 AM)",
                      _buildInputField(
                        "assets/Images/HomeScreen/revenue_icon.svg",
                        "Night %",
                        _nightController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDiscountModeOption(DiscountMode mode, String title, String subtitle, IconData icon) {
    final isSelected = _selectedDiscountMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!_isEditing) return;
          setState(() {
            _selectedDiscountMode = mode;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0XFFFF0B01).withOpacity(0.05) : Colors.grey[50],
            border: Border.all(
              color: isSelected ? const Color(0XFFFF0B01) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: isSelected ? const Color(0XFFFF0B01) : Colors.grey[600]),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: isSelected ? const Color(0XFFFF0B01) : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfileHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.65, size.height);
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height,
      size.width,
      size.height * 0.6,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}