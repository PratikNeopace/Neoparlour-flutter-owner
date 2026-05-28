import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:neo_parlour_owner/providers/package_provider.dart';
import 'package:neo_parlour_owner/providers/service_provider.dart';
import 'package:neo_parlour_owner/data/models/package_model.dart';
import 'package:neo_parlour_owner/data/models/service_model.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';
import 'package:neo_parlour_owner/widgets/pagination_widget.dart';

class AddPackageScreen extends StatefulWidget {
  final bool showAsTab;
  final int initialTabIndex;

  const AddPackageScreen({
    super.key,
    this.showAsTab = false,
    this.initialTabIndex = 0,
  });

  @override
  State<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends State<AddPackageScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _usageLimitController = TextEditingController();
  final _totalUsageLimitController = TextEditingController();

  final List<NeoService> _selectedServices = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchActiveServices();
      context.read<PackageProvider>().fetchPackages();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _usageLimitController.dispose();
    _totalUsageLimitController.dispose();
    super.dispose();
  }

  void _savePackage() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      FlushbarHelper.show(context, 'Please fill all required fields');
      return;
    }

    final package = ServicePackage(
      name: _nameController.text,
      packagePrice: double.tryParse(_priceController.text) ?? 0.0,
      description: _descriptionController.text,
      usageLimitPerCustomer: int.tryParse(_usageLimitController.text),
      totalUsageLimit: int.tryParse(_totalUsageLimitController.text),
      services: _selectedServices,
    );

    final success = await context.read<PackageProvider>().addPackage(package);
    if (success) {
      if (mounted) {
        FlushbarHelper.show(context, 'Package added successfully');
        if (!widget.showAsTab) {
          Navigator.pop(context);
        } else {
          _clearForm();
          context.read<PackageProvider>().fetchPackages();
        }
      }
    } else {
      if (mounted) {
        FlushbarHelper.show(context, 'Failed to add package');
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _usageLimitController.clear();
    _totalUsageLimitController.clear();
    setState(() {
      _selectedServices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            if (!widget.showAsTab) _buildHeader(context),
            Expanded(
              child: CustomRefreshIndicator(
                onRefresh: () async {
                  await context.read<PackageProvider>().fetchPackages();
                  await context.read<ServiceProvider>().fetchActiveServices();
                },
                color: const Color(0XFFFF0B01),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!widget.showAsTab || widget.initialTabIndex == 0) ...[
                          _buildFormSection(),
                        ],
                        if (!widget.showAsTab || widget.initialTabIndex == 1) ...[
                          if (widget.showAsTab) const SizedBox(height: 10),
                          const Text("PACKAGE LIST", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const Divider(color: Color(0XFFFF0B01), thickness: 2, endIndent: 220),
                          const SizedBox(height: 15),
                          _buildPackagesList(),
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

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ADD NEW PACKAGE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const Divider(color: Color(0XFFFF0B01), thickness: 2, endIndent: 200),
        const SizedBox(height: 20),
        _buildInputField(_nameController, "Package Name", "assets/Images/AddPackageScreen/package_details_icon.svg"),
        const SizedBox(height: 15),
        _buildInputField(_descriptionController, "Description", "assets/Images/AddPackageScreen/package_details_icon.svg", maxLines: 3),
        const SizedBox(height: 15),
        _buildInputField(_priceController, "Package Price", "assets/Images/AddPackageScreen/rate_icon.svg", keyboardType: TextInputType.number),
        const SizedBox(height: 15),
        _buildInputField(_usageLimitController, "Usage Limit Per Customer (Optional)", "assets/Images/AddPackageScreen/coupon_icon.svg", keyboardType: TextInputType.number),
        const SizedBox(height: 15),
        _buildInputField(_totalUsageLimitController, "Total Usage Limit (Optional)", "assets/Images/AddPackageScreen/coupon_icon.svg", keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        _buildServiceSelection(),
        const SizedBox(height: 30),
        Consumer<PackageProvider>(
          builder: (context, provider, child) {
            return ElevatedButton(
              onPressed: provider.isLoading ? null : _savePackage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFFFF0B01),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              ),
              child: provider.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("SAVE PACKAGE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, String iconPath, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0XFF909090), fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(iconPath, width: 20, height: 20),
        ),
        filled: true,
        fillColor: const Color(0XFFF8F8F8),
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

  Widget _buildServiceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SELECT SERVICES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        InkWell(
          onTap: _showServicePicker,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0XFF909090)),
              borderRadius: BorderRadius.circular(9),
              color: const Color(0XFFF8F8F8),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline, color: Color(0XFFFF0B01)),
                const SizedBox(width: 10),
                Text(
                  _selectedServices.isEmpty ? "Tap to add services" : "${_selectedServices.length} services selected",
                  style: const TextStyle(color: Color(0XFF909090)),
                ),
              ],
            ),
          ),
        ),
        if (_selectedServices.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _selectedServices.map((service) => Chip(
              label: Text(service.name),
              onDeleted: () {
                setState(() {
                  _selectedServices.removeWhere((s) => s.id == service.id);
                });
              },
            )).toList(),
          ),
        ],
      ],
    );
  }

  void _showServicePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Select Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Consumer<ServiceProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: provider.services.length,
                    itemBuilder: (context, index) {
                      final service = provider.services[index];
                      final isSelected = _selectedServices.any((s) => s.id == service.id);
                      return CheckboxListTile(
                        title: Text(service.name),
                        subtitle: Text("\u{20B9}${service.price}"),
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedServices.add(service);
                            } else {
                              _selectedServices.removeWhere((s) => s.id == service.id);
                            }
                          });
                          Navigator.pop(context);
                          _showServicePicker(); 
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackagesList() {
    return Consumer<PackageProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.packages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.packages.isEmpty) {
          return const Center(child: Text("No packages found."));
        }
        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.packages.length,
              itemBuilder: (context, index) {
                final package = provider.packages[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0XFFFF0B01).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, color: Color(0XFFFF0B01)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(package.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          package.services.map((s) => s.name).join(", "),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (package.usageLimitPerCustomer != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text("Per Cust: ${package.usageLimitPerCustomer}", style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.w600)),
                              ),
                            if (package.totalUsageLimit != null)
                              Text("Limit: ${package.usedCount}/${package.totalUsageLimit}", style: TextStyle(color: (package.totalUsageLimit != null && package.usedCount >= package.totalUsageLimit!) ? Colors.red : Colors.green, fontSize: 10, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("\u{20B9}${package.packagePrice}", style: const TextStyle(color: Color(0XFFFF0B01), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (provider.totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: PaginationWidget(
              currentPage: provider.currentPage,
              totalPages: provider.totalPages,
              onPageSelected: (page) {
                provider.goToPage(page: page);
              },
            ),
          ),
      ],
    );
  },
);
}

  void _confirmDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Package"),
        content: const Text("Are you sure you want to delete this package?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("DELETE"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<PackageProvider>().deletePackage(id);
      if (success && mounted) {
        FlushbarHelper.show(context, 'Package deleted successfully');
      }
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderCurveClipper(),
          child: Container(
            height: 225,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Images/CreateInvoiceScreen/background_image.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 25, bottom: 40),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    const Color(0XFFFF3502).withOpacity(0.7),
                  ],
                ),
              ),
              child: const Text(
                "PACKAGES",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
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
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
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