import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:neo_parlour_owner/data/models/service_model.dart';
import 'package:neo_parlour_owner/data/models/offer_model.dart';
import 'package:neo_parlour_owner/data/models/package_model.dart';
import 'package:neo_parlour_owner/data/services/service_service.dart';
import 'package:neo_parlour_owner/data/services/offer_service.dart';
import 'package:neo_parlour_owner/data/services/package_service.dart';
import 'package:neo_parlour_owner/data/models/appointment_response.dart';

class ExtendSelectServicesScreen extends StatefulWidget {
  final Appointment appointment;

  const ExtendSelectServicesScreen({super.key, required this.appointment});

  @override
  State<ExtendSelectServicesScreen> createState() =>
      _ExtendSelectServicesScreenState();
}

class _ExtendSelectServicesScreenState extends State<ExtendSelectServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ServiceService _serviceService = ServiceService();
  final OfferService _offerService = OfferService();
  final PackageService _packageService = PackageService();

  List<NeoService> _allServices = [];
  List<Offer> _allOffers = [];
  List<ServicePackage> _allPackages = [];

  bool _isLoading = true;
  String _selectedCategory = "All";

  final List<String> _categories = [
    "All",
    "Hair Services",
    "Skin Care",
    "Hair Removal",
    "Nail Care",
    "Makeup",
    "Grooming",
    "Spa & Massage",
    "Hair Treatment"
  ];

  // Selections
  final List<NeoService> _selectedServices = [];
  Offer? _selectedOffer;
  ServicePackage? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final servicesTask = _serviceService.fetchActiveServices();
      final offersTask = _offerService.getAllOffers(page: 0, size: 100);
      final packagesTask = _packageService.fetchPackages(page: 0, size: 100);

      final results = await Future.wait([servicesTask, offersTask, packagesTask]);

      setState(() {
        _allServices = results[0] as List<NeoService>;
        _allOffers = (results[1] as dynamic).content as List<Offer>;
        _allPackages = (results[2] as dynamic).content as List<ServicePackage>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        FlushbarHelper.show(context, "Error fetching data: $e");
      }
    }
  }

  bool _matchesCategory(NeoService service, String category) {
    if (category == "All") return true;
    final serviceCat = service.category.toLowerCase().trim();
    final filterCat = category.toLowerCase().trim();

    if (filterCat == "hair services") {
      return serviceCat.contains("cut") ||
          serviceCat == "hair" ||
          serviceCat == "hair services" ||
          serviceCat == "hair cut";
    } else if (filterCat == "skin care") {
      return serviceCat == "skin care" ||
          serviceCat == "facial" ||
          serviceCat.contains("skin") ||
          serviceCat.contains("facial");
    } else if (filterCat == "hair removal") {
      return serviceCat == "hair removal" || serviceCat.contains("removal");
    } else if (filterCat == "nail care") {
      return serviceCat == "nail care" ||
          serviceCat.contains("nail") ||
          serviceCat.contains("nails");
    } else if (filterCat == "makeup") {
      return serviceCat == "makeup" || serviceCat.contains("makeup");
    } else if (filterCat == "grooming") {
      return serviceCat == "grooming" || serviceCat.contains("grooming");
    } else if (filterCat == "spa & massage") {
      return serviceCat == "spa & massage" ||
          serviceCat.contains("massage") ||
          serviceCat.contains("spa");
    } else if (filterCat == "hair treatment") {
      return serviceCat == "hair treatment" ||
          serviceCat.contains("treatment");
    }

    return serviceCat == filterCat ||
        serviceCat.contains(filterCat) ||
        filterCat.contains(serviceCat);
  }

  int _calculateAdditionalDuration() {
    int duration = 0;
    for (var s in _selectedServices) {
      duration += s.duration;
    }
    if (_selectedPackage != null) {
      for (var s in _selectedPackage!.services) {
        duration += s.duration;
      }
    }
    return duration;
  }

  double _calculateAdditionalPrice() {
    double price = 0;
    for (var s in _selectedServices) {
      price += s.price;
    }
    if (_selectedPackage != null) {
      price += _selectedPackage!.packagePrice;
    }
    if (_selectedOffer != null) {
      if (_selectedOffer!.discountType == DiscountType.FLAT) {
        price -= _selectedOffer!.discountValue;
      } else {
        price -= price * (_selectedOffer!.discountValue / 100);
      }
    }
    return price > 0 ? price : 0;
  }

  void _onConfirmSelection() {
    final addedDuration = _calculateAdditionalDuration();
    if (addedDuration == 0) {
      FlushbarHelper.show(context, "Please select at least one service or package.");
      return;
    }
    Navigator.pop(context, {
      'addedServices': _selectedServices,
      'addedOffer': _selectedOffer,
      'addedPackage': _selectedPackage,
      'addedDuration': addedDuration,
      'addedPrice': _calculateAdditionalPrice(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
        ),
      );
    }

    final addedDuration = _calculateAdditionalDuration();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "EXTEND APPOINTMENT",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0XFFFF0B01),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0XFFFF0B01),
          tabs: const [
            Tab(text: "Services"),
            Tab(text: "Offers"),
            Tab(text: "Packages"),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildServicesTab(),
                _buildOffersTab(),
                _buildPackagesTab(),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Added Duration: $addedDuration min",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "+ ₹${_calculateAdditionalPrice().toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _onConfirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFFFF0B01),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    "Extend",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    final filteredServices =
        _allServices.where((s) => _matchesCategory(s, _selectedCategory)).toList();

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0XFFFF0B01) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: filteredServices.length,
            itemBuilder: (context, index) {
              final service = filteredServices[index];
              final isSelected =
                  _selectedServices.any((s) => s.id == service.id);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(
                    service.name,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    "₹${service.price} • ${service.duration} min",
                    style: GoogleFonts.poppins(
                        color: Colors.grey[600], fontSize: 12),
                  ),
                  trailing: Checkbox(
                    value: isSelected,
                    activeColor: const Color(0XFFFF0B01),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedServices.add(service);
                        } else {
                          _selectedServices
                              .removeWhere((s) => s.id == service.id);
                        }
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOffersTab() {
    if (_allOffers.isEmpty) {
      return Center(child: Text("No Offers Available", style: GoogleFonts.poppins()));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _allOffers.length,
      itemBuilder: (context, index) {
        final offer = _allOffers[index];
        final isSelected = _selectedOffer?.id == offer.id;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            title: Text(
              offer.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              offer.description ?? (offer.discountType == DiscountType.PERCENTAGE 
                  ? "${offer.discountValue.toInt()}% discount" 
                  : "₹${offer.discountValue.toInt()} discount"),
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: Radio<int?>(
              value: offer.id,
              groupValue: _selectedOffer?.id,
              activeColor: const Color(0XFFFF0B01),
              onChanged: (val) {
                setState(() {
                  _selectedOffer = offer;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPackagesTab() {
    if (_allPackages.isEmpty) {
      return Center(child: Text("No Packages Available", style: GoogleFonts.poppins()));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _allPackages.length,
      itemBuilder: (context, index) {
        final package = _allPackages[index];


        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            title: Text(
              package.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              "₹${package.packagePrice}",
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: Radio<int?>(
              value: package.id,
              groupValue: _selectedPackage?.id,
              activeColor: const Color(0XFFFF0B01),
              onChanged: (val) {
                setState(() {
                  _selectedPackage = package;
                });
              },
            ),
          ),
        );
      },
    );
  }
}
