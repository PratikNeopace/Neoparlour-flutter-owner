import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:neo_parlour_owner/providers/service_provider.dart';
import 'package:neo_parlour_owner/data/models/service_model.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/widgets/premium_image.dart';
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';

class AddServiceScreen extends StatefulWidget {
  final bool showAsTab;
  final int initialTabIndex;

  const AddServiceScreen({
    super.key,
    this.showAsTab = false,
    this.initialTabIndex = 0,
  });

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
   String? _selectedCategory;
   String? _selectedCommonService;
    bool _isCustomServiceName = false;
    int? _lastSyncedServiceId;
    final ScrollController _scrollController = ScrollController();
    String _selectedGender = 'FEMALE';

    String? _getServiceImagePath(String serviceName, String gender) {
      final name = serviceName.toLowerCase().trim().replaceAll(' ', '_');
      final g = gender.toLowerCase();
      
      const basePath = 'assets/Images/Services/Services';

      if (name.contains('hair_cut')) {
        return g == 'female' 
          ? '$basePath/female/hair_cut_female.jpg'
          : '$basePath/male/hair_cut_male.jpeg';
      }
      if (name.contains('coloring')) {
        return g == 'female'
          ? '$basePath/female/coloring_female.jpeg'
          : '$basePath/male/coloring_male.png';
      }
      if (name.contains('hair_spa')) {
        return g == 'female'
          ? '$basePath/female/hair_spa_female.jpeg'
          : '$basePath/male/hair_spa_male.png';
      }
      if (name.contains('hair_styling')) {
        return g == 'female'
          ? '$basePath/female/hair_styling.jpeg'
          : '$basePath/male/hair_styling_male.jpeg';
      }
      if (name.contains('shaving')) {
        return '$basePath/male/shaving.png';
      }
      if (name.contains('hair_wash')) {
        return g == 'female'
          ? '$basePath/female/hair_wash_female.jpeg'
          : '$basePath/male/hair_wash_male.jpeg';
      }
      if (name.contains('straight')) {
         return g == 'female'
          ? '$basePath/female/straightenning_female.jpeg'
          : '$basePath/male/straightenning_male.jpeg';
      }
      
      return null;
    }

  final List<String> _categories = [
    'Hair',
    'Skin',
    'Facial',
    'Nails',
    'Massage',
    'Makeup',
    'Hair Removal',
    'Spa',
    'Unisex',
    'Combo',
    'Threading',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).fetchServices();
      Provider.of<ServiceProvider>(context, listen: false).fetchCommonServices();
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final editingService = serviceProvider.editingService;

   
    if (widget.initialTabIndex == 0 && editingService != null && editingService.id != _lastSyncedServiceId) {
      _lastSyncedServiceId = editingService.id;
      // We use a post frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _populateFields(editingService);
      });
    } else if (editingService == null && _lastSyncedServiceId != null) {
       _lastSyncedServiceId = null;
       WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _clearForm();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

   void _populateFields(NeoService service) {
    setState(() {
      _nameController.text = service.name;
      _priceController.text = service.price.toString();
      _durationController.text = service.duration.toString();
      _selectedCategory = service.category;
      _imageFile = null;
      _isCustomServiceName = true; 
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _priceController.clear();
      _durationController.clear();
      _selectedCategory = null;
      _selectedCommonService = null;
      _isCustomServiceName = false;
      _imageFile = null;
      _lastSyncedServiceId = null;
      _selectedGender = 'FEMALE';
    });
    Provider.of<ServiceProvider>(context, listen: false).clearEditingService();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
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
                    icon: "assets/Images/ServicesScreen/camera_icon.svg",
                    label: "Camera",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildPickerOption(
                    icon: "assets/Images/ServicesScreen/gallery_icon.svg",
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

  Widget _buildPickerOption({required String icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0XFF909090).withValues(alpha: 0.3)),
            ),
            child: SvgPicture.asset(icon, width: 30, height: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  bool _validateForm() {
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim();
    final durationStr = _durationController.text.trim();

    if (_selectedCategory == null) {
      _showError("Please select a category");
      return false;
    }

    if (name.isEmpty) {
      _showError("Service name cannot be empty");
      return false;
    }

    if (priceStr.isEmpty) {
      _showError("Price is required");
      return false;
    }
    final price = double.tryParse(priceStr);
    if (price == null) {
      _showError("Please enter a valid price");
      return false;
    }
    if (price <= 0) {
      _showError("Price must be greater than 0");
      return false;
    }
    if (price > 1000000) {
      _showError("Price cannot exceed 1,000,000");
      return false;
    }

    if (durationStr.isEmpty) {
      _showError("Duration is required");
      return false;
    }
    final duration = int.tryParse(durationStr);
    if (duration == null) {
      _showError("Please enter a valid integer for duration");
      return false;
    }
    if (duration <= 0) {
      _showError("Duration must be greater than 0");
      return false;
    }
    if (duration > 1440) {
      _showError("Duration cannot exceed 1,440 minutes (24 hours)");
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
      final price = double.parse(_priceController.text.trim());
      final duration = int.parse(_durationController.text.trim());
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      
      String? imageBase64;
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        imageBase64 = base64Encode(bytes);
      }

      final editingService = serviceProvider.editingService;
      
      String? finalImage = imageBase64;
      if (finalImage == null && editingService == null) {
        // Try to get automatic image for new service
        finalImage = _getServiceImagePath(_nameController.text, _selectedGender);
      } else {
        finalImage ??= editingService?.image;
      }

      final serviceData = NeoService(
        id: editingService?.id,
        name: _nameController.text.trim(),
        duration: duration,
        price: price,
        category: _selectedCategory!,
        image: finalImage,
        active: editingService?.active ?? true,
        popularityCount: editingService?.popularityCount ?? 0,
      );

      if (editingService != null) {
        await serviceProvider.updateService(serviceData);
        if (!mounted) return;
        FlushbarHelper.show(context, "Service updated successfully!", isSuccess: true);
      } else {
        await serviceProvider.addService(serviceData);
        if (!mounted) return;
        FlushbarHelper.show(context, "Service added successfully!", isSuccess: true);
      }
      
      _clearForm();
    } catch (e) {
      if (mounted) {
        final errorMsg = ErrorHandler.parseError(e);
        FlushbarHelper.show(context, "Error: $errorMsg");
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF9F9F9),
      bottomNavigationBar: widget.showAsTab ? null : const OwnerBottomNavBar(),
      floatingActionButtonLocation: widget.showAsTab ? null : FloatingActionButtonLocation.centerDocked,
      floatingActionButton: widget.showAsTab ? null : FloatingActionButton(
        onPressed: () {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final role = authProvider.user?.role.toUpperCase();
          if (role == 'SALON_OWNER' || role == 'OWNER') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const OwnerHomeScreen()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeStaffScreen()),
              (route) => false,
            );
          }
        },
        backgroundColor: const Color(0XFFFF0B01),
        shape: const CircleBorder(),
        child: SvgPicture.asset("assets/Images/BottomNavigationScreen/home_icon.svg", width: 22, height: 22),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.showAsTab) _buildHeader(context, size),
            Expanded(
              child: CustomRefreshIndicator(
                onRefresh: () async {
                  await Provider.of<ServiceProvider>(context, listen: false).fetchServices();
                },
                color: const Color(0XFFFF0B01),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!widget.showAsTab || widget.initialTabIndex == 0) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(
                                provider.editingService != null ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                                size: 24,
                                color: provider.editingService != null ? Colors.blue : Colors.black,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                provider.editingService != null ? "EDITING SERVICE" : "ADD NEW SERVICE",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: provider.editingService != null ? Colors.blue : Colors.black,
                                ),
                              ),
                              if (provider.editingService != null) ...[
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: _clearForm,
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text("Cancel Edit"),
                                  style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                                ),
                              ],
                            ],
                          ),
                          Divider(
                            color: provider.editingService != null ? Colors.blue : const Color(0XFFFF0B01),
                            thickness: 2,
                            endIndent: provider.editingService != null ? 100 : 180,
                          ),
                          const SizedBox(height: 20),
                          
                          // Image Picker Section
                          GestureDetector(
                            onTap: _showImageSourcePicker,
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0XFF909090)),
                                borderRadius: BorderRadius.circular(9),
                                color: const Color(0XFFF8F8F8),
                              ),
                              child: _imageFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(9),
                                      child: kIsWeb
                                        ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                                        : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                                    )
                                  : provider.editingService != null && (provider.editingService!.imageUrl != null || provider.editingService!.image != null)
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(9),
                                          child: provider.editingService!.imageUrl != null && provider.editingService!.imageUrl!.isNotEmpty
                                            ? PremiumImageWidget(imageUrl: provider.editingService!.imageUrl, width: double.infinity, height: 120)
                                            : provider.editingService!.image!.startsWith('assets/')
                                              ? Image.asset(provider.editingService!.image!, fit: BoxFit.cover)
                                              : Image.memory(base64Decode(provider.editingService!.image!), fit: BoxFit.cover),
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset("assets/Images/ServicesScreen/camera_inside.svg", width: 28, height: 28),
                                              const SizedBox(height: 8),
                                              const Text("Tap to upload service image", style: TextStyle(color: Color(0XFF909090), fontSize: 12)),
                                            ],
                                          ),
                                        ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => _pickImage(ImageSource.camera),
                                child: _buildIconLabel("assets/Images/ServicesScreen/camera_icon.svg", "Camera"),
                              ),
                              const SizedBox(width: 40),
                              GestureDetector(
                                onTap: () => _pickImage(ImageSource.gallery),
                                child: _buildIconLabel("assets/Images/ServicesScreen/gallery_icon.svg", "Gallery"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          
                          // Service Name Selection (Dropdown or Manual)
                          if (!_isCustomServiceName && provider.editingService == null) ...[
                            Consumer<ServiceProvider>(
                              builder: (context, provider, child) {
                                return _buildDropdownField(
                                  "Select Service Name", 
                                  "assets/Images/ServicesScreen/service_name_icon.svg",
                                  items: [
                                    ...provider.commonServices,
                                    "Add custom service..."
                                  ],
                                  value: _selectedCommonService,
                                  onChanged: (val) {
                                    if (val == "Add custom service...") {
                                      setState(() {
                                        _isCustomServiceName = true;
                                        _nameController.clear();
                                      });
                                    } else {
                                      setState(() {
                                        _selectedCommonService = val;
                                        _nameController.text = val ?? "";
                                      });
                                    }
                                  }
                                );
                              },
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _nameController, 
                                    hint: "Service Name", 
                                    icon: "assets/Images/ServicesScreen/service_name_icon.svg"
                                  ),
                                ),
                                if (provider.editingService == null) 
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _isCustomServiceName = false;
                                      _selectedCommonService = null;
                                      _nameController.clear();
                                    }),
                                    child: const Text("Select Preloaded", style: TextStyle(fontSize: 12)),
                                  ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 20),
                          _buildDropdownField("Category", "assets/Images/ServicesScreen/category_icon.svg", value: _selectedCategory),
                          const SizedBox(height: 20),
                          _buildDropdownField(
                            "Gender", 
                            "assets/Images/AddStaffScreen/gender_icon.svg",
                            items: ['MALE', 'FEMALE'],
                            value: _selectedGender,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedGender = val);
                            }
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(controller: _priceController, hint: "Price", icon: "assets/Images/ServicesScreen/price_icon.svg", keyboardType: TextInputType.number),
                          const SizedBox(height: 20),
                          _buildTextField(controller: _durationController, hint: "Duration (min)", icon: "assets/Images/ServicesScreen/duration_icon.svg", keyboardType: TextInputType.number),
                          const SizedBox(height: 30),
                          
                          Row(
                            children: [
                              Expanded(
                                child: Consumer<ServiceProvider>(builder: (context, provider, child) {
                                  return ElevatedButton(
                                    onPressed: provider.isLoading ? null : _handleSave,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0XFFFF0B01),
                                      padding: const EdgeInsets.all(15),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                    ),
                                    child: provider.isLoading
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : Text(provider.editingService != null ? "UPDATE" : "SAVE", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  );
                                }),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _clearForm,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.all(15),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                    side: const BorderSide(color: Color(0XFF909090)),
                                  ),
                                  child: const Text("CANCEL", style: TextStyle(color: Color(0XFF909090), fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                        
                        if (!widget.showAsTab || widget.initialTabIndex == 1) ...[
                          const Text("MANAGE SERVICES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const Divider(color: Color(0XFFFF0B01), thickness: 2, endIndent: 220),
                          const SizedBox(height: 15),
                          
                          _buildServicesList(),
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
  }

  Widget _buildServicesList() {
    return Consumer<ServiceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.services.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.services.isEmpty) {
          return const Center(child: Text("No services found."));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.services.length,
          itemBuilder: (context, index) {
            final service = provider.services[index];
            final isActive = service.active;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (isActive) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: Opacity(
                opacity: isActive ? 1.0 : 0.6,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (service.imageUrl != null && service.imageUrl!.isNotEmpty)
                        ? PremiumImageWidget(
                            imageUrl: service.imageUrl,
                            width: 50,
                            height: 50,
                            borderRadius: BorderRadius.circular(8),
                          )
                        : (service.image != null && service.image!.isNotEmpty)
                          ? (service.image!.startsWith('assets/')
                              ? Image.asset(service.image!, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage())
                              : Image.memory(base64Decode(service.image!), width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage()))
                          : _buildPlaceholderImage(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(service.name,maxLines:1, style: const TextStyle(fontWeight: FontWeight.bold))),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
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
                          Text("${service.category} • ${service.duration} min", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          Text("\u{20B9}${service.price}", style: const TextStyle(color: Color(0XFFFF0B01), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Set editing service in provider so the form tab can see it
                        Provider.of<ServiceProvider>(context, listen: false).setEditingService(service);
                        // Automatically switch to the "Add/Edit" tab
                        DefaultTabController.of(context).animateTo(0);
                      },
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                      tooltip: "Edit",
                    ),
                    IconButton(
                      onPressed: () {
                        if (isActive) {
                          _confirmDeactivate(service.id!);
                        } else {
                          Provider.of<ServiceProvider>(context, listen: false).toggleServiceStatus(service.id!, true);
                        }
                      },
                      icon: Icon(
                        isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: isActive ? Colors.orange : Colors.green,
                        size: 20,
                      ),
                      tooltip: isActive ? "Deactivate" : "Activate",
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

  Future<void> _confirmDeactivate(int id) async {
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Deactivate Service"),
        content: const Text("This service will no longer be visible to customers. Continue?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text("DEACTIVATE"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await serviceProvider.deleteService(id);
        if (!mounted) return;
        FlushbarHelper.show(context, "Service deactivated.", isSuccess: true);
      } catch (e) {
        if (!mounted) return;
        FlushbarHelper.show(context, "Error: $e");
      }
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 50, height: 50,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
    );
  }

  Widget _buildIconLabel(String icon, String label) {
    return Row(
      children: [
        SvgPicture.asset(icon, width: 18, height: 18),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0XFF909090))),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required String icon, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0XFFF8F8F8),
        prefixIcon: Padding(padding: const EdgeInsets.all(12), child: SvgPicture.asset(icon, width: 20, height: 20)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0XFF909090))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0XFFFF0B01))),
      ),
    );
  }

  Widget _buildDropdownField(String hint, String icon, {List<String>? items, String? value, Function(String?)? onChanged}) {
    final displayItems = items ?? _categories;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0XFFF8F8F8), 
        border: Border.all(color: const Color(0XFF909090)), 
        borderRadius: BorderRadius.circular(9)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: displayItems.contains(value) ? value : null,
          hint: Row(
            children: [
              SvgPicture.asset(icon, width: 20, height: 20), 
              const SizedBox(width: 10), 
              Text(hint, style: const TextStyle(fontSize: 14))
            ]
          ),
          items: displayItems.map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: onChanged ?? (val) => setState(() => _selectedCategory = val),
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
            height: size.height * 0.25,
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4A4A4A), Colors.red])),
            child: const Padding(
              padding: EdgeInsets.only(left: 25, bottom: 40),
              child: Align(alignment: Alignment.bottomLeft, child: Text("SERVICES", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500))),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(backgroundColor: Colors.white.withValues(alpha: 0.5), child: const Icon(Icons.arrow_back_ios_new, size: 18)),
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
    path.quadraticBezierTo(size.width, size.height, size.width, size.height * 0.35);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}