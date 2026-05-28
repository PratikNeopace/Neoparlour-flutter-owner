import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:neo_parlour_owner/data/models/offer_model.dart';
import 'package:neo_parlour_owner/providers/offer_provider.dart';
import 'package:neo_parlour_owner/providers/service_provider.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:neo_parlour_owner/widgets/pagination_widget.dart';

import '../../../data/models/service_model.dart';

class AddOffersScreen extends StatefulWidget {
  const AddOffersScreen({super.key});

  @override
  State<AddOffersScreen> createState() => _AddOffersScreenState();
}

class _AddOffersScreenState extends State<AddOffersScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController totalUsageLimitController = TextEditingController();
  final TextEditingController usageLimitPerCustomerController = TextEditingController();

  DiscountType selectedDiscountType = DiscountType.PERCENTAGE;
  DateTime validFrom = DateTime.now();
  DateTime validTo = DateTime.now().add(const Duration(days: 30));
  List<int> selectedServiceIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OfferProvider>(context, listen: false).fetchOffers();
      Provider.of<ServiceProvider>(context, listen: false).fetchActiveServices();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? validFrom : validTo,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          validFrom = picked;
          if (validTo.isBefore(validFrom)) {
            validTo = validFrom.add(const Duration(days: 1));
          }
        } else {
          validTo = picked;
        }
      });
    }
  }

  void _handleSave() async {
    if (nameController.text.isEmpty || valueController.text.isEmpty) {
      FlushbarHelper.show(context, "Please fill in Offer Name and Value");
      return;
    }

    if (selectedServiceIds.isEmpty) {
      FlushbarHelper.show(context, "Please select at least one service");
      return;
    }

    final offer = Offer(
      name: nameController.text,
      description: descriptionController.text,
      discountType: selectedDiscountType,
      discountValue: double.tryParse(valueController.text) ?? 0.0,
      validFrom: validFrom,
      validTo: validTo,
      applicableServiceIds: selectedServiceIds,
      totalUsageLimit: int.tryParse(totalUsageLimitController.text),
      usageLimitPerCustomer: int.tryParse(usageLimitPerCustomerController.text),
    );

    final success = await Provider.of<OfferProvider>(
      context,
      listen: false,
    ).addOffer(offer);
    if (success) {
      nameController.clear();
      descriptionController.clear();
      valueController.clear();
      totalUsageLimitController.clear();
      usageLimitPerCustomerController.clear();
      setState(() {
        selectedServiceIds = [];
      });
      FlushbarHelper.show(context, "Offer created successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF9F9F9),
      bottomNavigationBar: const OwnerBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: FloatingActionButton(
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
            child: SvgPicture.asset(
              "assets/Images/BottomNavigationScreen/home_icon.svg",
              width: 22,
              height: 22,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 4),
                        Text(
                          "CREATE NEW OFFER",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Color(0XFFFF0B01),
                      thickness: 2,
                      endIndent: 200,
                    ),
                    const SizedBox(height: 20),

                    // Name
                    _buildTextField(
                      "Offer Name",
                      "assets/Images/AddOffersScreen/offers_details_icon.svg",
                      nameController,
                    ),
                    const SizedBox(height: 15),

                    // Description
                    _buildTextField(
                      "Description (Optional)",
                      "assets/Images/AddOffersScreen/offers_details_icon.svg",
                      descriptionController,
                    ),
                    const SizedBox(height: 15),

                    // Value & Type
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            selectedDiscountType == DiscountType.PERCENTAGE
                                ? "Percentage Off (%)"
                                : "Fixed Discount Amount",
                            "assets/Images/AddPackageScreen/percentage_icon.svg",
                            valueController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<DiscountType>(
                          value: selectedDiscountType,
                          items: DiscountType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type == DiscountType.PERCENTAGE
                                        ? "%"
                                        : "Fixed",
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedDiscountType = v!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Usage Limits
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Total Usage Limit",
                            "assets/Images/AddOffersScreen/offers_details_icon.svg",
                            totalUsageLimitController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            "Limit Per Customer",
                            "assets/Images/AddOffersScreen/offers_details_icon.svg",
                            usageLimitPerCustomerController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: _dateButton(
                            "Valid From",
                            validFrom,
                            () => _selectDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _dateButton(
                            "Valid To",
                            validTo,
                            () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Service Selection
                    const Text(
                      "Applicable Services",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildServiceSelector(),

                    const SizedBox(height: 25),

                    // Save Button
                    Consumer<OfferProvider>(
                      builder: (context, provider, child) => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFFFF0B01),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: provider.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "CREATE OFFER",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Existing Offers List
                    const Text(
                      "EXISTING OFFERS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildOffersList(),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSelector() {
    return Consumer<ServiceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const LinearProgressIndicator();
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(9),
          ),
          height: 150,
          child: ListView.builder(
            itemCount: provider.services.length,
            itemBuilder: (context, index) {
              final service = provider.services[index];
              return CheckboxListTile(
                title: Text(service.name),
                value: selectedServiceIds.contains(service.id),
                onChanged: (val) {
                  setState(() {
                    if (val!) {
                      selectedServiceIds.add(service.id!);
                    } else {
                      selectedServiceIds.remove(service.id);
                    }
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOffersList() {
    return Consumer2<OfferProvider, ServiceProvider>(
      builder: (context, offerProvider, serviceProvider, child) {
        if (offerProvider.isLoading && offerProvider.offers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (offerProvider.errorMessage != null && offerProvider.offers.isEmpty) {
          return Text("Error: ${offerProvider.errorMessage}", style: const TextStyle(color: Colors.red));
        }
        if (offerProvider.offers.isEmpty) {
          return const Text("No offers created yet.");
        }
        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: offerProvider.offers.length,
              itemBuilder: (context, index) {
                final offer = offerProvider.offers[index];
            
            // Map IDs to Names - Use names from model if available, otherwise lookup
            String serviceNames = "";
            if (offer.serviceNames.isNotEmpty) {
              serviceNames = offer.serviceNames.join(", ");
            } else {
              serviceNames = offer.applicableServiceIds.map((id) {
                return serviceProvider.services.firstWhere(
                  (s) => s.id == id,
                  orElse: () => NeoService(name: "...", duration: 0, price: 0, category: ""),
                ).name;
              }).join(", ");
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: ListTile(
                title: Text(offer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "${offer.discountValue}${offer.discountType == DiscountType.PERCENTAGE ? '%' : ' OFF'} - Ends ${DateFormat('dd MMM').format(offer.validTo)}",
                      style: const TextStyle(color: Color(0XFFFF0B01), fontWeight: FontWeight.bold),
                    ),
                    if (serviceNames.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.miscellaneous_services, size: 14, color: Colors.blueGrey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              serviceNames,
                              style: const TextStyle(fontSize: 12, color: Color(0XFF606060)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (offer.totalUsageLimit != null || offer.usageLimitPerCustomer != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (offer.usageLimitPerCustomer != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Text("Per Cust: ${offer.usageLimitPerCustomer}", style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w600)),
                            ),
                          if (offer.totalUsageLimit != null)
                            Text("Total Limit: ${offer.totalUsageLimit}", style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        if (offerProvider.totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: PaginationWidget(
              currentPage: offerProvider.currentPage,
              totalPages: offerProvider.totalPages,
              onPageSelected: (page) => offerProvider.goToPage(page),
            ),
          ),
      ],
    );
  },
);
}

  Widget _dateButton(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0XFF909090)),
          borderRadius: BorderRadius.circular(9),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM, yyyy').format(date),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    String icon,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0XFFF8F8F8),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(icon, width: 20, height: 20),
        ),
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

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: HeaderCurveClipper(),
          child: Container(
            height: 225,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/Images/ScheduleScreen/background_schedule.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
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
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.4),
              child: const Icon(Icons.chevron_left, color: Colors.black),
            ),
          ),
        ),
        const Positioned(
          bottom: 30,
          left: 23,
          child: Text(
            "OFFERS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Positioned(
          right: 30,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0XFFFF0B01),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              "assets/Images/AddOffersScreen/floating_button_icon.svg",
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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
