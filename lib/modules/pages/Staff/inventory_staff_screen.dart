import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/providers/inventory_provider.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/staff_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/data/models/inventory_model.dart';
import 'package:neo_parlour_owner/providers/staff_provider.dart';
import 'package:neo_parlour_owner/widgets/usage_details_dialog.dart';

class InventoryStaffScreen extends StatefulWidget {
  const InventoryStaffScreen({super.key});

  @override
  State<InventoryStaffScreen> createState() => _InventoryStaffScreenState();
}

class _InventoryStaffScreenState extends State<InventoryStaffScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int? _selectedFromInventoryId;
  int? _selectedToStaffId;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<InventoryProvider>(context, listen: false)
            .fetchStaffOwnInventory(authProvider.user!.id);
      }
      Provider.of<StaffProvider>(context, listen: false).fetchStaff();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Making the header height responsive
    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = screenHeight * 0.25;

    return Scaffold(
      // FIX: Prevents layout overflow when keyboard appears
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF9F9F9),
      bottomNavigationBar: const StaffBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final role = authProvider.user?.role;
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
        elevation: 4,
        shape: const CircleBorder(),
        child: SvgPicture.asset("assets/Images/BottomNavigationScreen/home_icon.svg"),
      ),
      body: Column(
        children: [
          _buildHeader(headerHeight),

          // ================= TABS =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Color(0XFFFF0B01),
              labelColor: Colors.black,
              unselectedLabelColor: const Color(0xFFCBC8C8),
              indicatorWeight: 2,
              tabs:  [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/Images/Staff/InventoryStaffScreen/inventory_icon.svg"),
                      SizedBox(width: 8),
                      Text("Inventory")
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/Images/Staff/InventoryStaffScreen/swap_inventory_icon.svg"),
                      SizedBox(width: 8),
                      Text("Swap Inventory")
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ================= TAB CONTENT =================
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInventoryList(),
                _buildSwapInventoryForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Inventory Tab List ---
  Widget _buildInventoryList() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        if (provider.isAssignmentsLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)));
        }

        if (provider.errorMessage != null && provider.staffOwnInventory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Error: ${provider.errorMessage}", style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    if (authProvider.user != null) {
                      provider.fetchStaffOwnInventory(authProvider.user!.id);
                    }
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        if (provider.staffOwnInventory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text("No inventory assigned to you yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: provider.staffOwnInventory.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final assignment = provider.staffOwnInventory[index];
            return _buildStaffInventoryCard(assignment);
          },
        );
      },
    );
  }

  Widget _buildStaffInventoryCard(StaffInventoryResponse assignment) {
    final assignedDate = assignment.assignedAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(assignment.assignedAt!.toLocal())
        : 'Unknown Date';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0XFFFF0B01).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2, color: Color(0XFFFF0B01), size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.inventoryName ?? "Unknown Item",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Assigned by: ${assignment.assignedBy ?? 'Owner'}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatDetail("Allocated", "${assignment.allocatedQuantity}"),
              _buildStatDetail("Remaining", "${assignment.remainingQuantity ?? assignment.allocatedQuantity}",
                  isAlert: (assignment.remainingQuantity ?? assignment.allocatedQuantity) <= 0),
              _buildStatDetail("Appointments", "${assignment.appointmentCount ?? 0}"),
            ],
          ),
          if (assignment.notes != null && assignment.notes!.isNotEmpty) ...[
            const Divider(height: 30),
            const Text(
              "NOTES",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.grey, letterSpacing: 0.5),
            ),
            const SizedBox(height: 5),
            Text(
              assignment.notes!,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                assignedDate,
                style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => _showUsageDetailsDialog(assignment),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0XFFFF0B01),
                      side: const BorderSide(color: Color(0XFFFF0B01)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("View Usages", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _showOpenProductDialog(assignment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFFFF0B01),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("USE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUsageDetailsDialog(StaffInventoryResponse assignment) {
    showDialog(
      context: context,
      builder: (context) => UsageDetailsDialog(assignmentId: assignment.id, itemName: assignment.inventoryName ?? "Item"),
    );
  }

  void _showOpenProductDialog(StaffInventoryResponse assignment) {
    final TextEditingController qController = TextEditingController(text: "1");
    final TextEditingController nController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Use ${assignment.inventoryName}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Quantity to open",
                hintText: "Enter quantity",
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nController,
              decoration: const InputDecoration(
                labelText: "Notes (Optional)",
                hintText: "Enter notes",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0XFFFF0B01)),
            onPressed: () async {
              final qty = double.tryParse(qController.text);
              if (qty == null || qty <= 0) {
                FlushbarHelper.show(context, "Enter a valid quantity");
                return;
              }

              try {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                await context.read<InventoryProvider>().openProduct(
                  assignment.id,
                  qty,
                  nController.text.isEmpty ? null : nController.text,
                  auth.user?.id ?? 0,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  FlushbarHelper.show(context, "Product opened successfully", isSuccess: true);
                }
              } catch (e) {
                if (context.mounted) {
                  final errorMsg = context.read<InventoryProvider>().errorMessage ?? e.toString().replaceAll('Exception: ', '');
                  FlushbarHelper.show(context, errorMsg);
                }
              }
            },
            child: const Text("Use", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDetail(String label, String value, {bool isAlert = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isAlert ? const Color(0XFFFF0B01) : Colors.black87,
          ),
        ),
      ],
    );
  }

  // --- Swap Inventory Tab Form ---
  Widget _buildSwapInventoryForm() {
    final inventoryProvider = context.watch<InventoryProvider>();
    final staffProvider = context.watch<StaffProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Select Item to Swap
          _buildDropdownField<int>(
            hint: "Select Item to Swap",
            icon: "assets/Images/Staff/InventoryStaffScreen/item_name_icon.svg",
            value: _selectedFromInventoryId,
            items: inventoryProvider.staffOwnInventory.map((item) {
              return DropdownMenuItem<int>(
                value: item.id,
                child: Text(item.inventoryName ?? 'Unknown Item'),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedFromInventoryId = val),
          ),
          const SizedBox(height: 20),

          // Select Target Staff
          if (staffProvider.errorMessage != null && staffProvider.staffMembers.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade50,
              child: Text(
                "Error loading staff: ${staffProvider.errorMessage}",
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            )
          else
            _buildDropdownField<int>(
              hint: "Swap With Staff",
              icon: "assets/Images/Staff/InventoryStaffScreen/category_icon.svg", // reusing icon
              value: _selectedToStaffId,
              items: staffProvider.staffMembers.map((staff) {
                return DropdownMenuItem<int>(
                  value: staff.id,
                  child: Text(staff.name),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedToStaffId = val),
            ),
          const SizedBox(height: 20),

          // Quantity
          _buildTextField("Quantity", "assets/Images/Staff/InventoryStaffScreen/quantity_icon.svg", controller: _quantityController, isNumber: true),
          const SizedBox(height: 20),

          // Notes
          _buildTextField("Notes", "assets/Images/Staff/InventoryStaffScreen/category_icon.svg", controller: _notesController),
          const SizedBox(height: 40),

          _buildActionButtons(inventoryProvider.isLoading),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // --- Reusable Button Row ---
  Widget _buildActionButtons(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSwapRequest,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9))),
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("SUBMIT REQUEST", style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
               setState(() {
                  _selectedFromInventoryId = null;
                  _selectedToStaffId = null;
                  _quantityController.clear();
                  _notesController.clear();
               });
            },
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9))),
            child: const Text("CLEAR", style: TextStyle(color: Color(0XFF909090))),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSwapRequest() async {
    if (_selectedFromInventoryId == null || _selectedToStaffId == null || _quantityController.text.trim().isEmpty) {
      FlushbarHelper.show(context, "Please select an item, a staff member, and enter a quantity.");
      return;
    }

    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      FlushbarHelper.show(context, "Please enter a valid quantity.");
      return;
    }

    try {
      await context.read<InventoryProvider>().requestInventorySwap(
        fromStaffInventoryId: _selectedFromInventoryId!,
        toStaffId: _selectedToStaffId!,
        quantity: quantity,
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;
      FlushbarHelper.show(context, "Inventory swap request submitted successfully!", isSuccess: true);
      setState(() {
        _selectedFromInventoryId = null;
        _selectedToStaffId = null;
        _quantityController.clear();
        _notesController.clear();
      });
      _tabController.animateTo(0);
    } catch (e) {
      if (!mounted) return;
      FlushbarHelper.show(context, context.read<InventoryProvider>().errorMessage ?? "Failed to swap inventory");
    }
  }


  // --- Header ---
  Widget _buildHeader(double height) {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderCurveClipper(),
          child: Container(
            height: height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/Images/InventoryScreen/background_two_image.jpg"),
                  fit: BoxFit.cover),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 25, bottom: 20),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    const Color(0XFFFF3502).withValues(alpha: 0.7)
                  ],
                ),
              ),
              child: const Text("INVENTORY",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ),
        Positioned(
          right: 30,
          bottom: 15,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration:
            const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2, color: Colors.white, size: 24),
          ),
        ),
         Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String hint, String icon, {TextEditingController? controller, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCBC8C8), fontSize: 14),
        filled: true,
        fillColor: const Color(0XFFF8F8F8),

        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            icon,
            width: 14,
            height: 14,
            fit: BoxFit.scaleDown,
            colorFilter: const ColorFilter.mode(Color(0xFF909090), BlendMode.srcIn),
          ),
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Color(0XFF909090))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Color(0XFFFF0B01))),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String hint,
    required String icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0XFFF8F8F8),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0XFF909090)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0XFF909090)),
          hint: Row(
            children: [
              SvgPicture.asset(
                icon,
                width: 14,
                height: 14,
                fit: BoxFit.scaleDown,
                colorFilter: const ColorFilter.mode(Color(0xFF909090), BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              Text(hint, style: const TextStyle(color: Color(0xFFCBC8C8), fontSize: 14)),
            ],
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// --- Header Clipper ---
class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.55, size.height);
    path.quadraticBezierTo(
        size.width, size.height, size.width, size.height * 0.35);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
