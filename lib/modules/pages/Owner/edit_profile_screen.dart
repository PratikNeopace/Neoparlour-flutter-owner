import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/providers/salon_provider.dart';
import 'package:neo_parlour_owner/core/utils/download_helper.dart';
import 'package:neo_parlour_owner/modules/pages/email_login_screen.dart';
import 'package:neo_parlour_owner/widgets/premium_image.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:neo_parlour_owner/core/data/services/search_service.dart';
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
  final TextEditingController _weekdayDiscountController = TextEditingController();
  String _selectedGender = 'Select Gender';
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
        _selectedGender = user.gender ?? 'Select Gender';
        _addressController.text = user.address ?? '';
        _cityController.text = user.cityName ?? '';
        _areaController.text = user.areaName ?? '';
        
        // Salon Profile Data
        if (salon != null) {
          _salonNameController.text = salon.salonName ?? '';
          _homeChargesController.text = salon.homeServiceCharges?.toString() ?? '0';
          _weekdayDiscountController.text = salon.weekdayDiscount?.toString() ?? '0';
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
          _homeChargesController.text = user.homeServiceCharges?.toString() ?? '0';
          _weekdayDiscountController.text = '0';
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
      'gender': _selectedGender == 'Select Gender' ? null : _selectedGender,
      'salonId': user.salonId,
      'salonName': _salonNameController.text,
      'address': _addressController.text.isEmpty ? null : _addressController.text,
      'cityName': _cityController.text.isEmpty ? null : _cityController.text,
      'areaName': _areaController.text.isEmpty ? null : _areaController.text,
      'role': user.role,
      'active': user.active,
      'imageBase64': user.imageBase64,
      'latitude': user.latitude,
      'longitude': user.longitude,
      'password': null,
      'fcmToken': user.fcmToken,
    };

    if (user.role == 'STAFF') {
      data['homeServiceCharges'] = null;
      data['updatedAt'] = null;
      data['openingTime'] = null;
      data['closingTime'] = null;
    } else {
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

    final Map<String, dynamic> data = {
      'salonId': salon.salonId,
      'name': null,
      'phone': salon.phone,
      'email': salon.email,
      'salonName': _salonNameController.text,
      'cityName': salon.city,
      'areaName': salon.area,
      'address': _addressController.text,
      'birthdate': null,
      'latitude': user?.latitude,
      'longitude': user?.longitude,
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
      'weekdayDiscount': double.tryParse(_weekdayDiscountController.text),
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
              final success = await authProvider.deleteAccount();
              if (success && mounted) {
                // Return to login or splash
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const EmailLoginScreen()),
                  (route) => false,
                );
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
            : const Text(
                "SAVE CHANGES",
                style: TextStyle(
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
      child: const Text(
        "Delete Account",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
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
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: true,
        child: authProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)))
            : SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      MediaQuery.of(context).viewPadding.bottom +
                      60,
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
                              child: const Text(
                                "EDIT PROFILE",
                                style: TextStyle(
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
                                _isEditing ? "CANCEL" : "EDIT",
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
                              Tab(text: (authProvider.user?.role == 'SALON_OWNER' || authProvider.user?.role == 'OWNER') ? "OWNER PROFILE" : "STAFF PROFILE"),
                              if (authProvider.user?.role == 'SALON_OWNER' || authProvider.user?.role == 'OWNER')
                                const Tab(text: "SALON PROFILE"),
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
                                      _buildSectionHeader("Personal Details"),
                                      const SizedBox(height: 15),
                                      _buildInputField(
                                        "assets/Images/EditProfileScreen/enter_name_icon.svg",
                                        "Full Name",
                                        _nameController,
                                      ),
                                      const SizedBox(height: 15),
                                      _buildInputField(
                                        "assets/Images/EditProfileScreen/dob_icon.svg",
                                        "Date Of Birth",
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
                                        _selectedGender,
                                      ),
                                      const SizedBox(height: 15),
                                      _buildInputField(
                                        "assets/Images/EditProfileScreen/mobile_number_icon.svg",
                                        "Mobile Number",
                                        _phoneController,
                                        keyboardType: TextInputType.phone,
                                      ),
                                      const SizedBox(height: 25),
                                      _buildSectionHeader("Contact Info"),
                                      const SizedBox(height: 15),
                                      _buildInputField(
                                        "assets/Images/EditProfileScreen/enter_name_icon.svg",
                                        "Address",
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
                                       const SizedBox(height: 40),
                                    ],
                                  ),
                                ),
                                // Tab 2: Salon Profile (Only for Owners)
                                if (authProvider.user?.role == 'SALON_OWNER' || authProvider.user?.role == 'OWNER')
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 120),
                                    child: Column(
                                      children: [
                                        _buildSectionHeader("Salon Details"),
                                        const SizedBox(height: 15),
                                        _buildInputField(
                                          "assets/Images/AddPackageScreen/package_details_icon.svg",
                                          "Salon Name",
                                          _salonNameController,
                                        ),
                                        const SizedBox(height: 15),
                                        _buildInputField(
                                          "assets/Images/RegisterScreen/username.svg",
                                          "Salon Code",
                                          TextEditingController(text: _salonCode),
                                          readOnly: true,
                                        ),
                                        const SizedBox(height: 15),
                                        _buildInputField(
                                          "assets/Images/EditProfileScreen/mobile_number_icon.svg",
                                          "Salon Phone",
                                          TextEditingController(text: _salonPhone),
                                          readOnly: true,
                                        ),
                                        const SizedBox(height: 25),
                                        _buildSectionHeader("Business Hours & Fees"),
                                         if (authProvider.user?.role == 'SALON_OWNER' || authProvider.user?.role == 'OWNER')
                                         Row(
                                          children: [
                                            Expanded(
                                              child: _buildTimePickerField("Opening Time", _openingTime, (t) => setState(() => _openingTime = t)),
                                            ),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: _buildTimePickerField("Closing Time", _closingTime, (t) => setState(() => _closingTime = t)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                        const SizedBox(height: 15),
                                         _buildWeeklyOffDropdown(),
                                         const SizedBox(height: 15),
                                         Row(
                                           children: [
                                             Expanded(
                                               child: _buildLabeledField(
                                                 "Home Service Charges (₹)",
                                                 _buildInputField(
                                                   "assets/Images/HomeScreen/revenue_icon.svg",
                                                   "Home Service Charges",
                                                   _homeChargesController,
                                                   keyboardType: TextInputType.number,
                                                 ),
                                               ),
                                             ),
                                             const SizedBox(width: 15),
                                             Expanded(
                                               child: _buildLabeledField(
                                                 "Weekday Discount (%)",
                                                 _buildInputField(
                                                   "assets/Images/HomeScreen/revenue_icon.svg",
                                                   "Weekday Discount",
                                                   _weekdayDiscountController,
                                                   keyboardType: TextInputType.number,
                                                 ),
                                               ),
                                             ),
                                           ],
                                         ),
                                         const SizedBox(height: 35),
                                         _buildSalonMediaSection(),
                                         const SizedBox(height: 35),
                                        _buildSaveButton(Provider.of<SalonProvider>(context).isLoading, _saveSalonProfile),
                                        const SizedBox(height: 35),
                                        _buildQRCodeSection(),
                                        const SizedBox(height: 40),
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
            const Text(
              "SALON QR CODE",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    label: const Text("DOWNLOAD QR"),
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

  Widget _buildInputField(String icon, String hint, TextEditingController controller, {bool readOnly = false, VoidCallback? onTap, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    final bool effectiveReadOnly = readOnly || !_isEditing;
    
    return TextField(
      controller: controller,
      readOnly: effectiveReadOnly,
      onTap: !_isEditing ? null : onTap,
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

  Widget _buildTimePickerField(String label, String currentTime, Function(String) onTimeSelected) {
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
              final formattedTime = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
              onTimeSelected(formattedTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: _isEditing ? const Color(0XFFF9F9F9) : Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: !_isEditing ? const Color(0XFFE0E0E0) : const Color(0XFF909090),
                width: !_isEditing ? 0.5 : 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentTime, 
                  style: TextStyle(
                    color: _isEditing ? Colors.black : Colors.black87, 
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.access_time, color: _isEditing ? const Color(0XFFFF0B01) : const Color(0XFF909090), size: 18),
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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._salonGalleryImageUrls.map((url) {
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(url.toString()),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _salonGalleryImageUrls.remove(url)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 16, color: Colors.red),
                        ),
                      ),
                    ),
                ],
              );
            }),
            ..._salonGalleryImagesBase64.map((base64Image) {
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: MemoryImage(base64Decode(base64Image)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _salonGalleryImagesBase64.remove(base64Image)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 16, color: Colors.red),
                        ),
                      ),
                    ),
                ],
              );
            }),
            if (_isEditing)
               GestureDetector(
                onTap: () {
                   _selectedDocumentType = "SALON_GALLERY";
                   _showUploadOptions(context);
                },
                child: Container(
                  width: 80,
                  height: 80,
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
      ],
    );
  }

  Widget _buildImageUploadBox(String docType, String? currentBase64, String? currentUrl) {
    bool hasImage = currentBase64 != null || (currentUrl != null && currentUrl.isNotEmpty);
    ImageProvider? imageProvider;
    if (currentBase64 != null) {
      imageProvider = MemoryImage(base64Decode(currentBase64));
    } else if (currentUrl != null && currentUrl.isNotEmpty) {
      imageProvider = NetworkImage(currentUrl);
    }

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
          image: hasImage
              ? DecorationImage(image: imageProvider!, fit: BoxFit.cover)
              : null,
        ),
        child: !hasImage
            ? const Center(child: Icon(Icons.add_photo_alternate, color: Colors.grey, size: 30))
            : (_isEditing ? Align(
                alignment: Alignment.topRight,
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
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 18, color: Colors.red),
                  ),
                ),
              ) : null),
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

  Future<void> _pickDocumentFromGallery() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
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
          _handleUploadedFile(file.name, base64Encode(bytes));
        } else {
          if (mounted) FlushbarHelper.show(context, "Could not retrieve file content.");
        }
      }
    } catch (e) {
      if (mounted) FlushbarHelper.show(context, "Error picking file: $e");
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        _handleUploadedFile(photo.name, base64Encode(bytes));
      }
    } catch (e) {
      if (mounted) FlushbarHelper.show(context, "Error taking photo: $e");
    }
  }

  void _handleUploadedFile(String name, String base64Content) {
    if (_selectedDocumentType == null) return;

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