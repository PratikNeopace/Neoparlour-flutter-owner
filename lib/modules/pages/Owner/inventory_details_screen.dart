import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/data/models/inventory_model.dart';
import 'package:neo_parlour_owner/data/models/staff_model.dart';
import 'package:neo_parlour_owner/providers/inventory_provider.dart';
import 'package:neo_parlour_owner/providers/staff_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/assigned_staff_screen.dart';
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';
import 'package:neo_parlour_owner/widgets/pagination_widget.dart';
import 'package:neo_parlour_owner/widgets/premium_image.dart';

class InventoryDetailsScreen extends StatefulWidget {
  const InventoryDetailsScreen({super.key});

  @override
  State<InventoryDetailsScreen> createState() => _InventoryDetailsScreenState();
}

class _InventoryDetailsScreenState extends State<InventoryDetailsScreen> {
  ProductType? _selectedFilterCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(context, listen: false).fetchInventory();
      Provider.of<StaffProvider>(context, listen: false).fetchStaff();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.inventoryItems.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)));
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => provider.fetchInventory(),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        if (provider.inventoryItems.isEmpty) {
          return const Center(child: Text("No inventory items found"));
        }

        return CustomRefreshIndicator(
          onRefresh: () => provider.fetchInventory(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDropdownField("Categories", "assets/Images/ServicesScreen/category_icon.svg"),
                const SizedBox(height: 25),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.inventoryItems.where((item) {
                    if (_selectedFilterCategory == null) return true;
                    return item.category == _selectedFilterCategory;
                  }).length,
                  separatorBuilder: (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final filteredItems = provider.inventoryItems.where((item) {
                      if (_selectedFilterCategory == null) return true;
                      return item.category == _selectedFilterCategory;
                    }).toList();
                    return _buildInventoryCard(filteredItems[index]);
                  },
                ),
                const SizedBox(height: 20),
                PaginationWidget(
                  currentPage: provider.currentPage,
                  totalPages: provider.totalPages,
                  onPageSelected: (page) => provider.fetchInventory(page: page),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInventoryCard(InventoryResponse item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF808080),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                    ? PremiumImageWidget(
                        imageUrl: item.imageUrl,
                        width: 30,
                        height: 30,
                        shape: BoxShape.circle,
                      )
                    : (item.imageBase64 != null && item.imageBase64!.isNotEmpty)
                        ? Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: MemoryImage(base64Decode(item.imageBase64!)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : const Icon(Icons.inventory_2_outlined, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  item.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  "Qty - ${item.currentStock}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text("Category : ${item.category?.name ?? 'N/A'}", overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 10),
                    Expanded(child: Text("Unit : ${item.unitType.name}", overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text("Cost : ₹${item.costPrice}"),
                    const Spacer(),
                    if (item.reorderLevel != null)
                      Text("Reorder : ${item.reorderLevel}", style: TextStyle(color: (item.currentStock <= item.reorderLevel!) ? Colors.red : Colors.grey)),
                  ],
                ),
                const Divider(height: 25),
                Row(
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton(
                          onPressed: () => _showAssignStaffDialog(item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFFFF0B01),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text("Assign Staff", style: TextStyle(fontSize: 12)),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssignedStaffScreen(inventory: item),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0XFFFF0B01),
                            side: const BorderSide(color: Color(0XFFFF0B01)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text("View Assigned Staff", style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const Spacer(),

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignStaffDialog(InventoryResponse item) {
    int? selectedStaffId;
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setDialogState) {
            return Consumer<StaffProvider>(
              builder: (consumerContext, staffProvider, _) {
                return AlertDialog(
                  title: Text("Assign ${item.name}"),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Select Staff Member"),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: selectedStaffId,
                              hint: const Text("Choose Staff"),
                              items: staffProvider.staffMembers.map((Staff staff) {
                                return DropdownMenuItem<int>(
                                  value: staff.id,
                                  child: Text(staff.name),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setDialogState(() => selectedStaffId = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text("Allocated Quantity"),
                        const SizedBox(height: 10),
                        TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter quantity",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text("Notes (Optional)"),
                        const SizedBox(height: 10),
                        TextField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Add notes...",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text("CANCEL"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedStaffId == null || quantityController.text.isEmpty) {
                          FlushbarHelper.show(context, "Please select staff and enter quantity");
                          return;
                        }

                        final quantity = double.tryParse(quantityController.text);
                        if (quantity == null || quantity <= 0) {
                          FlushbarHelper.show(context, "Invalid quantity");
                          return;
                        }

                        final request = StaffInventoryRequest(
                          staffId: selectedStaffId!,
                          inventoryId: item.id,
                          allocatedQuantity: quantity,
                          notes: notesController.text,
                        );

                        try {
                          await inventoryProvider.assignInventory(request);
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          if (mounted) {
                            FlushbarHelper.show(context, "Inventory assigned successfully", isSuccess: true);
                          }
                        } catch (e) {
                          if (mounted) {
                            FlushbarHelper.show(context, "Error: $e");
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0XFFFF0B01)),
                      child: const Text("ASSIGN", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDropdownField(String hint, String icon) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0XFFF8F8F8),
        border: Border.all(color: const Color(0XFF909090)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ProductType>(
          isExpanded: true,
          value: _selectedFilterCategory,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0XFF909090)),
          hint: Row(
            children: [
              SvgPicture.asset(icon, width: 20, height: 20),
              const SizedBox(width: 10),
              Text(hint, style: const TextStyle(color: Color(0xFFCBC8C8), fontSize: 14)),
            ],
          ),
          items: [
            const DropdownMenuItem<ProductType>(
              value: null,
              child: Text("All Categories"),
            ),
            ...ProductType.values.map((ProductType value) {
              final name = value.name[0].toUpperCase() + value.name.substring(1);
              return DropdownMenuItem<ProductType>(
                value: value,
                child: Text(name),
              );
            }),
          ],
          onChanged: (newValue) {
            setState(() {
              _selectedFilterCategory = newValue;
            });
          },
        ),
      ),
    );
  }
}