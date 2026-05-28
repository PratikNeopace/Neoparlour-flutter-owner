import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/data/models/inventory_model.dart';
import 'package:neo_parlour_owner/providers/inventory_provider.dart';

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
  
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  
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
              border: Border.all(color: const Color(0XFF909090).withOpacity(0.3)),
            ),
            child: SvgPicture.asset(icon, width: 30, height: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _saveInventory() async {
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty || _costController.text.isEmpty) {
      FlushbarHelper.show(context, "Please fill all required fields");
      return;
    }

    String? imageBase64;
    if (_imageFile != null) {
      final bytes = await _imageFile!.readAsBytes();
      imageBase64 = base64Encode(bytes);
    }

    final request = InventoryRequest(
      name: _nameController.text,
      category: _selectedCategory,
      productType: _selectedCategory,
      currentStock: int.tryParse(_quantityController.text) ?? 0,
      costPrice: double.tryParse(_costController.text) ?? 0.0,
      unitType: _selectedUnitType,
      imageBase64: imageBase64,
    );

    try {
      await Provider.of<InventoryProvider>(context, listen: false).addInventory(request);
      if (mounted) {
        FlushbarHelper.show(context, "Item added successfully");
        _nameController.clear();
        _quantityController.clear();
        _costController.clear();
        setState(() {
          _selectedCategory = null;
          _selectedUnitType = UnitType.PIECE;
          _imageFile = null;
        });
      }
    } catch (e) {
      if (mounted) {
        FlushbarHelper.show(context, "Error: $e");
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
          // ================= IMAGE UPLOAD =================
          GestureDetector(
            onTap: _showImageSourcePicker,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0XFF909090)),
                borderRadius: BorderRadius.circular(9),
                image: _imageFile != null
                    ? DecorationImage(
                        image: kIsWeb
                            ? NetworkImage(_imageFile!.path)
                            : FileImage(File(_imageFile!.path)) as ImageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _imageFile == null
                  ? Center(
                      child: SvgPicture.asset(
                        "assets/Images/ServicesScreen/camera_inside.svg",
                        width: 28,
                        height: 28,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconLabel(
                "assets/Images/ServicesScreen/camera_icon.svg",
                "Camera",
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 40),
              _buildIconLabel(
                "assets/Images/ServicesScreen/gallery_icon.svg",
                "Gallery",
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // ================= FORM =================
          _buildTextField("Item Name", "assets/Images/ServicesScreen/service_name_icon.svg", _nameController),
          const SizedBox(height: 20),

          _buildCategoryDropdown(),
          const SizedBox(height: 20),

          _buildUnitTypeDropdown(),
          const SizedBox(height: 20),

          _buildTextField("Quantity", "", _quantityController, keyboardType: TextInputType.number),
          const SizedBox(height: 20),

          _buildTextField("Cost", "", _costController, keyboardType: TextInputType.number),
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
                      : const Text("SAVE", style: TextStyle(color: Colors.white)),
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
                  child: const Text("CANCEL", style: TextStyle(color: Color(0XFF909090))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconLabel(String icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(icon, width: 18, height: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
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
              const Text("Category", style: TextStyle(color: Color(0xFFCBC8C8), fontSize: 14)),
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
          hint: const Text("Unit Type", style: TextStyle(color: Color(0xFFCBC8C8), fontSize: 14)),
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