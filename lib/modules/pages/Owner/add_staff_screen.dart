import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/staff_provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/data/models/staff_model.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';

class AddStaffScreen extends StatefulWidget {
  final bool showAsTab;
  final int initialTabIndex;

  const AddStaffScreen({
    super.key,
    this.showAsTab = false,
    this.initialTabIndex = 0,
  });

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  Staff? _editingStaff;
  String _selectedGender = 'MALE'; 
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StaffProvider>(context, listen: false).fetchStaff();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _birthdateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _populateFields(Staff staff) {
    setState(() {
      _editingStaff = staff;
      _nameController.text = staff.name;
      _phoneController.text = staff.phone;
      _emailController.text = staff.email;
      _passwordController.clear(); 
      _addressController.text = staff.address ?? '';
      _birthdateController.text = staff.birthdate?.split('T')[0] ?? '';
      _selectedGender = staff.gender ?? 'MALE';
      _imageFile = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _clearForm() {
    setState(() {
      _editingStaff = null;
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _passwordController.clear();
      _addressController.clear();
      _birthdateController.clear();
      _selectedGender = 'MALE';
      _imageFile = null;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        FlushbarHelper.show(context, "Error picking image: $e");
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Image Source",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPickerOption(
                    icon: Icons.camera_alt_outlined,
                    label: "Camera",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildPickerOption(
                    icon: Icons.photo_library_outlined,
                    label: "Gallery",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0XFF909090).withOpacity(0.3),
              ),
            ),
            child: Icon(icon, size: 30, color: const Color(0XFFFF0B01)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now().subtract(
      const Duration(days: 365 * 18),
    );
    if (_birthdateController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_birthdateController.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0XFFFF0B01),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthdateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  bool _validateForm() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty) {
      _showError("Name cannot be empty");
      return false;
    }
    if (name.length < 2) {
      _showError("Name must be at least 2 characters");
      return false;
    }

    if (phone.isEmpty) {
      _showError("Phone number cannot be empty");
      return false;
    }
    if (phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showError("Please enter a valid 10-digit phone number");
      return false;
    }

    if (email.isEmpty) {
      _showError("Email cannot be empty");
      return false;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showError("Please enter a valid email address");
      return false;
    }

    if (_editingStaff == null && password.isEmpty) {
      _showError("Password is required for new staff");
      return false;
    }
    if (password.isNotEmpty && password.length < 6) {
      _showError("Password must be at least 6 characters long");
      return false;
    }

    if (address.isNotEmpty && address.length < 5) {
      _showError("Address is too short");
      return false;
    }

    return true;
  }

  void _showError(String message) {
    FlushbarHelper.show(context, message);
  }

  Future<void> _handleSave() async {
    if (!_validateForm()) return;

    try {
      final staffProvider = Provider.of<StaffProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      String? imageBase64;
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        imageBase64 = base64Encode(bytes);
      }

      String? fcmToken;
      try {
        String? vapidKey;
        if (kIsWeb) {
          vapidKey = "BIdYnU3B7lY_U7wKzUv3Qv7Jv_Z_qX_L7_X_z_v_x_Z_Y";
        }
        fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: vapidKey);
        print("STAFF REG FCM TOKEN (RAW) => $fcmToken");
      } catch (e) {
        print("Non-fatal error getting FCM token: $e");
      }


      final staffData = Staff(
        id: _editingStaff?.id,
        userId: _editingStaff?.userId,
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        address: _addressController.text,
        birthdate: _birthdateController
            .text, // Model logic will handle date formatting
        salonName: _editingStaff?.salonName ?? authProvider.user?.tenantName,
        salonId: _editingStaff?.salonId ?? int.tryParse(authProvider.user?.tenantName ?? ''),
        active: _editingStaff?.active ?? true,
        role: 'STAFF',
        gender: _selectedGender,
        imageBase64: imageBase64,
        fcmToken: fcmToken,
      );

      if (_editingStaff != null) {
        await staffProvider.updateStaff(staffData);
        staffProvider.clearEditingStaff(); // Clear provider state after update
        FlushbarHelper.show(context, "Staff updated successfully!");
      } else {
        await staffProvider.addStaff(staffData);
        FlushbarHelper.show(context, "Staff added successfully!");
      }

      _clearForm();
      staffProvider.clearEditingStaff();
    } catch (e) {
      if (mounted) {
        final staffProvider = Provider.of<StaffProvider>(context, listen: false);
        FlushbarHelper.show(context, staffProvider.errorMessage ?? "Something went wrong");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<StaffProvider>(
      builder: (context, staffProvider, child) {
        // Sync local state with provider state for editing
        if (staffProvider.editingStaff != _editingStaff && widget.initialTabIndex == 0) {
          final staff = staffProvider.editingStaff;
          if (staff != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _populateFields(staff);
            });
          } else {
             WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _clearForm();
            });
          }
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFFF9F9F9),
          bottomNavigationBar: widget.showAsTab ? null : const OwnerBottomNavBar(),
          body: SafeArea(
            child: Column(
              children: [
                if (!widget.showAsTab) _buildHeader(context, size),
                Expanded(
                  child: CustomRefreshIndicator(
                    onRefresh: () async {
                      await staffProvider.fetchStaff();
                    },
                    color: const Color(0XFFFF0B01),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          MediaQuery.of(context).viewInsets.bottom + 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!widget.showAsTab || widget.initialTabIndex == 0) ...[
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Icon(
                                    _editingStaff != null ? Icons.edit_note_rounded : Icons.person_add_outlined,
                                    size: 24,
                                    color: _editingStaff != null ? Colors.blue : Colors.black,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _editingStaff != null ? "EDITING STAFF" : "ADD NEW STAFF",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: _editingStaff != null ? Colors.blue : Colors.black,
                                    ),
                                  ),
                                  if (_editingStaff != null) ...[
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: () {
                                        staffProvider.clearEditingStaff();
                                        _clearForm();
                                      },
                                      icon: const Icon(Icons.close, size: 16),
                                      label: const Text("Cancel Edit"),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Divider(
                                color: _editingStaff != null ? Colors.blue : const Color(0XFFFF0B01),
                                thickness: 2,
                                endIndent: 180,
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: GestureDetector(
                                  onTap: _showImageSourcePicker,
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.grey[200],
                                        backgroundImage: _imageFile != null
                                            ? (kIsWeb ? NetworkImage(_imageFile!.path) : FileImage(File(_imageFile!.path)) as ImageProvider)
                                            : null,
                                        child: _imageFile == null ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: Color(0XFFFF0B01), shape: BoxShape.circle),
                                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
                              _buildTextField(controller: _nameController, hint: "Full Name", icon: Icons.person_outline),
                              const SizedBox(height: 15),
                              _buildTextField(controller: _phoneController, hint: "Phone Number", icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                              const SizedBox(height: 15),
                              _buildTextField(controller: _emailController, hint: "Email Address", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 15),
                              if (_editingStaff == null) ...[
                                _buildTextField(controller: _passwordController, hint: "Password", icon: Icons.lock_outline, obscureText: true),
                                const SizedBox(height: 15),
                              ],
                              _buildTextField(controller: _addressController, hint: "Address", icon: Icons.location_on_outlined),
                              const SizedBox(height: 15),
                              _buildTextField(controller: _birthdateController, hint: "Birthdate", icon: Icons.cake_outlined, readOnly: true, onTap: _selectDate),
                              const SizedBox(height: 15),
                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: InputDecoration(
                                  hintText: "Gender",
                                  filled: true,
                                  fillColor: const Color(0XFFF8F8F8),
                                  prefixIcon: const Icon(Icons.person_pin_outlined, color: Color(0XFF909090), size: 20),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0XFF909090))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0XFFFF0B01))),
                                ),
                                items: ['MALE', 'FEMALE', 'OTHER'].map((gender) => DropdownMenuItem(value: gender, child: Text(gender))).toList(),
                                onChanged: (value) {
                                  if (value != null) setState(() { _selectedGender = value; });
                                },
                              ),
                              const SizedBox(height: 30),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: staffProvider.isLoading ? null : _handleSave,
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0XFFFF0B01), padding: const EdgeInsets.all(15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
                                      child: staffProvider.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_editingStaff != null ? "UPDATE" : "SAVE", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () { staffProvider.clearEditingStaff(); _clearForm(); },
                                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)), side: const BorderSide(color: Color(0XFF909090))),
                                      child: const Text("CANCEL", style: TextStyle(color: Color(0XFF909090), fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                            ],
                            if (!widget.showAsTab || widget.initialTabIndex == 1) ...[
                              const Text("MANAGE STAFF", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const Divider(color: Color(0XFFFF0B01), thickness: 2, endIndent: 220),
                              const SizedBox(height: 15),
                              _buildStaffList(),
                              const SizedBox(height: 100),
                            ],
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
      },
    );
  }

  Widget _buildStaffList() {
    return Consumer<StaffProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.staffMembers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.staffMembers.isEmpty) {
          return const Center(child: Text("No staff members found."));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.staffMembers.length,
          itemBuilder: (context, index) {
            final staff = provider.staffMembers[index];
            final isActive = staff.active;
            return Container( 
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (isActive)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Opacity(
                opacity: isActive ? 1.0 : 0.6,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          staff.imageBase64 != null &&
                              staff.imageBase64!.isNotEmpty
                          ? (staff.imageBase64!.startsWith('http')
                                ? NetworkImage(staff.imageBase64!)
                                : MemoryImage(base64Decode(staff.imageBase64!))
                                      as ImageProvider)
                          : null,
                      child:
                          (staff.imageBase64 == null ||
                              staff.imageBase64!.isEmpty)
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                staff.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isActive ? "ACTIVE" : "INACTIVE",
                                  style: TextStyle(
                                    color: isActive ? Colors.green : Colors.red,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            staff.phone,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            staff.email,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Provider.of<StaffProvider>(context, listen: false).selectStaffForEdit(staff);
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        try {
                          final msg = await provider.toggleStaffStatus(staff, !isActive);
                          if (context.mounted) {
                            FlushbarHelper.show(context, msg);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            FlushbarHelper.show(context, provider.errorMessage ?? "Failed to update status");
                          }
                        }
                      },
                      icon: Icon(
                        isActive
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: isActive ? Colors.orange : Colors.green,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0XFFF8F8F8),
        prefixIcon: Icon(icon, color: const Color(0XFF909090), size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0XFF909090)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0XFFFF0B01)),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size size) {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderCurveClipper(),
          child: Container(
            height: size.height * 0.2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF4A4A4A), Colors.red]),
            ),
            child: const Padding(
              padding: EdgeInsets.only(left: 25, bottom: 40),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "STAFF",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.5),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black,
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 8,
          right: 22,
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0XFFFF0B01),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                height: 26,
                width: 26,
                child: SvgPicture.asset(
                  "assets/Images/AddStaffScreen/floating_staff.svg",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.55, size.height);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height * 0.35,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

