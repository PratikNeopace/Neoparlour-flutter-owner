import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:neo_parlour_owner/providers/service_provider.dart';
import 'package:neo_parlour_owner/data/models/service_model.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';
import 'package:neo_parlour_owner/widgets/premium_service_card.dart';

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
  final TextEditingController _customCategoryController = TextEditingController();
  bool _isCustomCategory = false;
  
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
    "Hair Services",
    "Skin Care",
    "Hair Removal",
    "Nail Care",
    "Makeup",
    "Grooming",
    "Spa & Massage",
    "Bridal Packages",
    "Hair Treatment",
    "Other(Type Custom Category)"
  ];

  final Map<String, List<String>> _categorySubCategories = {
    "Hair Services": [
      "Hair Cut",
      "Hair Styling",
      "Hair Wash",
      "Blow Dry",
      "Hair Coloring",
      "Highlights / Streaks",
      "Hair Spa",
      "Hair Treatment",
      "Keratin Treatment",
      "Hair Smoothening",
      "Hair Straightening",
      "Perming / Curling",
      "Hair Extensions"
    ],
    "Skin Care": [
      "Facial",
      "Cleanup",
      "Skin Polishing",
      "Bleaching",
      "De-Tan Treatment",
      "Face Treatment",
      "Anti-Aging Treatment",
      "Acne Treatment",
      "Skin Brightening Treatment",
      "Chemical Peel"
    ],
    "Hair Removal": [
      "Waxing",
      "Threading",
      "Eyebrow Shaping",
      "Upper Lip",
      "Forehead",
      "Full Face Waxing",
      "Full Body Waxing"
    ],
    "Nail Care": [
      "Manicure",
      "Pedicure",
      "Nail Cutting",
      "Nail Shaping",
      "Nail Art",
      "Nail Extensions",
      "Gel Polish"
    ],
    "Makeup": [
      "Party Makeup",
      "Bridal Makeup",
      "Engagement Makeup",
      "Reception Makeup",
      "HD Makeup",
      "Basic Makeup"
    ],
    "Grooming": [
      "Beard Trim",
      "Beard Styling",
      "Shaving",
      "Moustache Styling",
      "Eyebrow Styling",
      "Eyelash Services"
    ],
    "Spa & Massage": [
      "Head Massage",
      "Body Massage",
      "Relaxation Massage",
      "Aroma Therapy",
      "Body Scrub",
      "Body Wrap"
    ],
    "Bridal Packages": [
      "Bridal Hair",
      "Bridal Makeup",
      "Bridal Facial",
      "Bridal Manicure/Pedicure",
      "Pre-Bridal Package"
    ],
    "Hair Treatment": [
      "Hair Fall Treatment",
      "Dandruff Treatment",
      "Scalp Treatment",
      "Damage Repair",
      "Protein Treatment"
    ],
  };

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
    _customCategoryController.dispose();
    super.dispose();
  }

  void _populateFields(NeoService service) {
    setState(() {
      _nameController.text = service.name;
      _priceController.text = service.price.toString();
      _durationController.text = service.duration.toString();

      final cat = service.category;
      if (_categories.contains(cat) && cat != "Other(Type Custom Category)") {
        _selectedCategory = cat;
        _isCustomCategory = false;
        _customCategoryController.clear();

        final subs = _categorySubCategories[cat] ?? [];
        if (subs.contains(service.name)) {
          _selectedCommonService = service.name;
          _isCustomServiceName = false;
        } else {
          _selectedCommonService = "Other(Type Custom Category)";
          _isCustomServiceName = true;
        }
      } else {
        _selectedCategory = "Other(Type Custom Category)";
        _isCustomCategory = true;
        _customCategoryController.text = cat;
        _selectedCommonService = "Other(Type Custom Category)";
        _isCustomServiceName = true;
      }
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
      _customCategoryController.clear();
      _selectedCategory = null;
      _selectedCommonService = null;
      _isCustomServiceName = false;
      _isCustomCategory = false;
      _lastSyncedServiceId = null;
      _selectedGender = 'FEMALE';
    });
    Provider.of<ServiceProvider>(context, listen: false).clearEditingService();
  }



  bool _validateForm() {
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim();
    final durationStr = _durationController.text.trim();

    if (_selectedCategory == null) {
      _showError("Please select a category");
      return false;
    }

    if (_isCustomCategory && _customCategoryController.text.trim().isEmpty) {
      _showError("Custom category name cannot be empty");
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
      
      final editingService = serviceProvider.editingService;
      
      String? finalImage;
      if (editingService == null) {
        // Try to get automatic image for new service
        finalImage = _getServiceImagePath(_nameController.text, _selectedGender);
      } else {
        finalImage = editingService.image;
      }

      final categoryValue = _isCustomCategory 
          ? _customCategoryController.text.trim() 
          : _selectedCategory!;

      final serviceData = NeoService(
        id: editingService?.id,
        name: _nameController.text.trim(),
        duration: duration,
        price: price,
        category: categoryValue,
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
            Expanded(
              child: CustomRefreshIndicator(
                onRefresh: () async {
                  await Provider.of<ServiceProvider>(context, listen: false).fetchServices();
                },
                color: const Color(0XFFFF0B01),
                child: (!widget.showAsTab || widget.initialTabIndex == 0)
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: widget.showAsTab ? null : _scrollController,
                      child: Column(
                        children: [
                          if (!widget.showAsTab) _buildHeader(context, size),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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

                          // ─── CATEGORY (First) ────────────────────────────────────────
                          // Standard category dropdown
                          if (!_isCustomCategory) ...[
                            _buildDropdownField(
                              "Category",
                              "assets/Images/ServicesScreen/category_icon.svg",
                              items: _categories,
                              value: _selectedCategory,
                              onChanged: (val) {
                                setState(() {
                                  if (val == "Other(Type Custom Category)") {
                                    _selectedCategory = val;
                                    _isCustomCategory = true;
                                    _customCategoryController.clear();
                                  } else {
                                    _selectedCategory = val;
                                    _isCustomCategory = false;
                                    _customCategoryController.clear();
                                  }
                                  // Reset service name when category changes
                                  _selectedCommonService = null;
                                  _isCustomServiceName = false;
                                  _nameController.clear();
                                });
                              },
                            ),
                          ] else ...[
                            // Custom category text field
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _customCategoryController,
                                    hint: "Type Custom Category",
                                    icon: "assets/Images/ServicesScreen/category_icon.svg",
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => setState(() {
                                    _isCustomCategory = false;
                                    _selectedCategory = null;
                                    _customCategoryController.clear();
                                    _selectedCommonService = null;
                                    _isCustomServiceName = false;
                                    _nameController.clear();
                                  }),
                                  child: const Text("Select Preloaded", style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 20),

                          // ─── SERVICE NAME (Second, filtered by category) ───────────────
                          if (!_isCustomCategory) ...[
                            // Only show subcategory dropdown when a standard category is selected
                            if (_selectedCategory != null && provider.editingService == null) ...[
                              if (!_isCustomServiceName) ...[
                                _buildDropdownField(
                                  "Select Service Name",
                                  "assets/Images/ServicesScreen/service_name_icon.svg",
                                  items: [
                                    ...(_categorySubCategories[_selectedCategory!] ?? []),
                                    "Other(Type Custom Category)",
                                  ],
                                  value: (_categorySubCategories[_selectedCategory!] ?? []).contains(_selectedCommonService)
                                      ? _selectedCommonService
                                      : null,
                                  onChanged: (val) {
                                    if (val == "Other(Type Custom Category)") {
                                      setState(() {
                                        _isCustomServiceName = true;
                                        _selectedCommonService = null;
                                        _nameController.clear();
                                      });
                                    } else {
                                      setState(() {
                                        _selectedCommonService = val;
                                        _nameController.text = val ?? "";
                                      });
                                    }
                                  },
                                ),
                              ] else ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _nameController,
                                        hint: "Service Name",
                                        icon: "assets/Images/ServicesScreen/service_name_icon.svg",
                                      ),
                                    ),
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
                            ] else if (provider.editingService != null) ...[
                              // Editing mode – show text field directly
                              _buildTextField(
                                controller: _nameController,
                                hint: "Service Name",
                                icon: "assets/Images/ServicesScreen/service_name_icon.svg",
                              ),
                            ] else ...[
                              // No category selected yet – show disabled placeholder
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0XFFF0F0F0),
                                  border: Border.all(color: const Color(0XFF909090)),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset("assets/Images/ServicesScreen/service_name_icon.svg", width: 20, height: 20),
                                    const SizedBox(width: 10),
                                    const Text("Select a category first", style: TextStyle(fontSize: 14, color: Color(0XFFB0B0B0))),
                                  ],
                                ),
                              ),
                            ],
                          ] else ...[
                            // Custom category selected – service name is always a text field
                            _buildTextField(
                              controller: _nameController,
                              hint: "Service Name",
                              icon: "assets/Images/ServicesScreen/service_name_icon.svg",
                            ),
                          ],
                          const SizedBox(height: 20),

                          // ─── GENDER ─────────────────────────────────────────────────
                          _buildDropdownField(
                            "Gender",
                            "assets/Images/AddStaffScreen/gender_icon.svg",
                            items: ['MALE', 'FEMALE'],
                            value: _selectedGender,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedGender = val);
                            },
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
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildManageServicesList(context, size),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageServicesList(BuildContext context, Size size) {
    return Consumer<ServiceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.services.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return ReorderableListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, widget.showAsTab ? 0 : 20, 20, 100),
          proxyDecorator: (Widget child, int index, Animation<double> animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                final double animValue = Curves.easeInOut.transform(animation.value);
                final double scale = 1.0 + (0.03 * animValue);
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: child,
            );
          },
          onReorder: (oldIndex, newIndex) {
            provider.reorderServicesShift(oldIndex, newIndex);
          },
          header: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.showAsTab) _buildHeader(context, size),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Service List (Customer Preview)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                ],
              ),
              const SizedBox(height: 4),
              const Text("Preview how customers will see your services.", style: TextStyle(color: Colors.grey, fontSize: 15)),
              const SizedBox(height: 16),
              _buildCustomerPreview(),
              
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Manage Services", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black)),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.swap_vert, size: 16),
                    label: const Text("Reorder"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Text("ⓘ ", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text("Hold and drag services to change display order.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 16),
              
              if (provider.services.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No services found."))),
            ],
          ),
          itemCount: provider.services.length,
          itemBuilder: (context, index) {
            final service = provider.services[index];
            final isActive = service.active;
            return PremiumServiceCard(
              key: ValueKey(service.id ?? index.toString()),
              service: service,
              isActive: isActive,
              index: index,
              onEdit: () {
                Provider.of<ServiceProvider>(context, listen: false).setEditingService(service);
                if (DefaultTabController.maybeOf(context) != null) {
                  DefaultTabController.of(context).animateTo(1);
                }
              },
              onToggleVisibility: () {
                if (isActive) {
                  _confirmDeactivate(service.id!);
                } else {
                  Provider.of<ServiceProvider>(context, listen: false).toggleServiceStatus(service.id!, true);
                }
              },
            );
          },
        );
      },
    );
  }

  String _getCategoryIconSvg(String category) {
    final categoryLower = category.toLowerCase().trim();
    if (categoryLower.contains("color") || categoryLower == "coloring") {
      return "assets/Images/HomeScreen/hair_coloring_services.svg";
    } else if (categoryLower.contains("spa") || categoryLower.contains("span")) {
      return "assets/Images/HomeScreen/hair_spa_services.svg";
    } else if (categoryLower.contains("styling")) {
      return "assets/Images/HomeScreen/hair_styling_services.svg";
    } else if (categoryLower.contains("wash")) {
      return "assets/Images/HomeScreen/hair_wash_services.svg";
    } else if (categoryLower.contains("shav")) {
      return "assets/Images/HomeScreen/shaving_services.svg";
    } else if (categoryLower.contains("straight")) {
      return "assets/Images/HomeScreen/straightning_services.svg";
    } else if (categoryLower.contains("cut") || categoryLower == "hair" || categoryLower == "hair services" || categoryLower == "hair cut") {
      return "assets/Images/HomeScreen/hair_cut_services.svg";
    } else if (categoryLower == "skin care" || categoryLower == "facial" || categoryLower.contains("skin") || categoryLower.contains("facial") || categoryLower.contains("lighting")) {
      return "assets/Images/HomeScreen/Skin care.svg";
    } else if (categoryLower == "hair removal" || categoryLower.contains("removal")) {
      return "assets/Images/HomeScreen/Hair removal.svg";
    } else if (categoryLower == "nail care" || categoryLower.contains("nail")) {
      return "assets/Images/HomeScreen/Nail care.svg";
    } else if (categoryLower == "makeup" || categoryLower.contains("makeup")) {
      return "assets/Images/HomeScreen/makeup.svg";
    } else if (categoryLower == "grooming" || categoryLower.contains("grooming")) {
      return "assets/Images/HomeScreen/grooming.svg";
    } else if (categoryLower == "spa & massage" || categoryLower.contains("massage")) {
      return "assets/Images/HomeScreen/spa & massage.svg";
    } else if (categoryLower == "hair treatment" || categoryLower.contains("treatment")) {
      return "assets/Images/HomeScreen/Hair treatment.svg";
    } else if (categoryLower == "more") {
      return "assets/Images/HomeScreen/more_services.svg";
    } else {
      return "assets/Images/HomeScreen/common_service.svg";
    }
  }

  Widget _buildCustomerPreview() {
    return Consumer<ServiceProvider>(
      builder: (context, provider, child) {
        if (provider.services.isEmpty) return const SizedBox.shrink();
        
        // Extract unique categories in the order they appear in the services list
        final List<String> displayCategories = [];
        for (final service in provider.services) {
          final cat = service.category;
          if (cat.isNotEmpty && !displayCategories.contains(cat)) {
            displayCategories.add(cat);
          }
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 90,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 110,
          ),
          itemCount: displayCategories.length,
          itemBuilder: (context, index) {
            final catName = displayCategories[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0XFFF8F9FB),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(_getCategoryIconSvg(catName), width: 28, height: 28),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      catName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.5), 
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black)
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
    path.quadraticBezierTo(size.width, size.height, size.width, size.height * 0.35);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}