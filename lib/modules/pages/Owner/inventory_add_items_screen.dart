import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/data/models/inventory_model.dart';
import 'package:neo_parlour_owner/providers/inventory_provider.dart';
import 'package:neo_parlour_owner/l10n/generated/app_localizations.dart';

class AddInventoryScreen extends StatefulWidget {
  const AddInventoryScreen({super.key});

  @override
  State<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  ProductType? _selectedCategory;
  UnitType _selectedUnitType = UnitType.PIECE;
  
  List<UnitType> _getAvailableUnits(ProductType? category) {
    if (category == null) return UnitType.values;
    
    switch (category) {
      case ProductType.tool:
      case ProductType.equipment:
      case ProductType.accessory:
        return [UnitType.PIECE, UnitType.BOTTLE];
      case ProductType.chemical:
      case ProductType.consumable:
      case ProductType.cosmetic:
        return [
          UnitType.GRAM, 
          UnitType.KG, 
          UnitType.ML, 
          UnitType.LITER, 
          UnitType.BOTTLE, 
          UnitType.PIECE
        ];
      case ProductType.retail:
      case ProductType.supply:
        return [
          UnitType.PIECE, 
          UnitType.BOTTLE, 
          UnitType.ML, 
          UnitType.GRAM
        ];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _saveInventory() async {
    if (_nameController.text.trim().isEmpty) {
      FlushbarHelper.show(context, "Item Name is required");
      return;
    }

    final quantityStr = _quantityController.text.trim();
    if (quantityStr.isEmpty) {
      FlushbarHelper.show(context, "Quantity is required");
      return;
    }
    final quantity = int.tryParse(quantityStr);
    if (quantity == null) {
      FlushbarHelper.show(context, "Please enter a valid quantity");
      return;
    }
    if (quantity < 0) {
      FlushbarHelper.show(context, "Quantity cannot be negative");
      return;
    }
    if (quantity > 1000000) {
      FlushbarHelper.show(context, "Quantity cannot exceed 1,000,000");
      return;
    }

    final costStr = _costController.text.trim();
    if (costStr.isEmpty) {
      FlushbarHelper.show(context, "Cost price is required");
      return;
    }
    final cost = double.tryParse(costStr);
    if (cost == null) {
      FlushbarHelper.show(context, "Please enter a valid cost price");
      return;
    }
    if (cost < 0) {
      FlushbarHelper.show(context, "Cost price cannot be negative");
      return;
    }
    if (cost > 1000000) {
      FlushbarHelper.show(context, "Cost price cannot exceed 1,000,000");
      return;
    }

    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    final request = InventoryRequest(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      productType: _selectedCategory,
      currentStock: quantity,
      costPrice: cost,
      unitType: _selectedUnitType,
    );

    try {
      await inventoryProvider.addInventory(request);
      if (mounted) {
        FlushbarHelper.show(context, "Item added successfully", isSuccess: true);
        _nameController.clear();
        _quantityController.clear();
        _costController.clear();
        setState(() {
          _selectedCategory = null;
          _selectedUnitType = UnitType.PIECE;
        });
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = ErrorHandler.parseError(e);
        FlushbarHelper.show(context, "Error: $errorMsg");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<InventoryProvider>().isLoading;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= FORM =================
          _buildTextField(AppLocalizations.of(context)!.itemNameLabel, "assets/Images/ServicesScreen/service_name_icon.svg", _nameController),
          const SizedBox(height: 20),

          _buildCategoryDropdown(),
          const SizedBox(height: 20),

          _buildUnitTypeDropdown(),
          const SizedBox(height: 20),

          _buildTextField(AppLocalizations.of(context)!.quantityLabel, "", _quantityController, keyboardType: TextInputType.number),
          const SizedBox(height: 20),

          _buildTextField(AppLocalizations.of(context)!.costLabel, "", _costController, keyboardType: TextInputType.number),
          const SizedBox(height: 30),

          // ================= BUTTONS =================
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveInventory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(AppLocalizations.of(context)!.saveBtn, style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.cancelBtn, style: const TextStyle(color: Color(0XFF909090))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, String icon, TextEditingController controller, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCBC8C8), fontSize: 14),
        filled: true,
        fillColor: const Color(0XFFF8F8F8),
        prefixIcon: icon.isEmpty
            ? null
            : Padding(
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

  Widget _buildCategoryDropdown() {
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
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0XFF909090)),
          hint: Row(
            children: [
              SvgPicture.asset("assets/Images/ServicesScreen/category_icon.svg", width: 20, height: 20),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.categoryLabel, style: const TextStyle(color: Color(0xFFCBC8C8), fontSize: 14)),
            ],
          ),
          items: ProductType.values.map((ProductType value) {
            final name = value.name[0].toUpperCase() + value.name.substring(1);
            return DropdownMenuItem<ProductType>(
              value: value,
              child: Text(name),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCategory = newValue;
              // Reset unit type if current one is not available for new category
              final availableUnits = _getAvailableUnits(newValue);
              if (!availableUnits.contains(_selectedUnitType)) {
                _selectedUnitType = UnitType.PIECE;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildUnitTypeDropdown() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0XFFF8F8F8),
        border: Border.all(color: const Color(0XFF909090)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UnitType>(
          value: _selectedUnitType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0XFF909090)),
          hint: Text(AppLocalizations.of(context)!.unitTypeLabel, style: const TextStyle(color: Color(0xFFCBC8C8), fontSize: 14)),
          items: _getAvailableUnits(_selectedCategory).map((UnitType type) {
            return DropdownMenuItem<UnitType>(
              value: type,
              child: Text(type.name),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedUnitType = newValue!;
            });
          },
        ),
      ),
    );
  }
}