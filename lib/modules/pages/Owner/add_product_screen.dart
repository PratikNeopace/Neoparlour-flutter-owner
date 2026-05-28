import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';
import 'package:neo_parlour_owner/providers/product_provider.dart';
import 'package:neo_parlour_owner/data/models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  final bool showAsTab;
  final int initialTabIndex;

  const AddProductScreen({
    super.key,
    this.showAsTab = false,
    this.initialTabIndex = 0,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  Uint8List? _mainImageBytes;
  final List<Uint8List> _additionalImagesBytes = [];
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _restockLevelController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountPriceController = TextEditingController();

  String _productType = 'RETAIL';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _restockLevelController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickMainImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _mainImageBytes = bytes;
      });
    }
  }

  Future<void> _pickAdditionalImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _additionalImagesBytes.add(bytes);
      });
    }
  }

  bool _validateForm() {
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim();
    final discountStr = _discountPriceController.text.trim();
    final stockStr = _stockController.text.trim();

    if (_mainImageBytes == null) {
      _showError("Main Product Image is compulsory");
      return false;
    }

    if (name.isEmpty) {
      _showError("Product Name is required");
      return false;
    }

    if (priceStr.isEmpty) {
      _showError("Price is required");
      return false;
    }
    final price = double.tryParse(priceStr);
    if (price == null || price <= 0) {
      _showError("Please enter a valid price greater than 0");
      return false;
    }

    if (discountStr.isNotEmpty) {
      final discount = double.tryParse(discountStr);
      if (discount == null || discount < 0) {
        _showError("Please enter a valid discount price");
        return false;
      }
      if (discount >= price) {
        _showError("Discount price must be less than the regular price");
        return false;
      }
    }

    if (stockStr.isNotEmpty) {
      final stock = int.tryParse(stockStr);
      if (stock == null || stock < 0) {
        _showError("Please enter a valid stock quantity");
        return false;
      }
    }

    return true;
  }

  void _showError(String message) {
    FlushbarHelper.show(context, message);
  }

  Future<void> _saveProduct() async {
    if (!_validateForm()) return;

    try {
      final price = double.parse(_priceController.text.trim());
      final discountPrice = _discountPriceController.text.isNotEmpty 
          ? double.parse(_discountPriceController.text.trim()) 
          : null;
      final stock = _stockController.text.isNotEmpty 
          ? int.parse(_stockController.text.trim()) 
          : null;
      final restockLevel = _restockLevelController.text.isNotEmpty 
          ? int.parse(_restockLevelController.text.trim()) 
          : null;

      final mainImageBase64 = base64Encode(_mainImageBytes!);
      List<String> additionalImagesBase64 = _additionalImagesBytes.map((bytes) => base64Encode(bytes)).toList();

      final product = ProductModel(
        salonId: 1, 
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        discountPrice: discountPrice,
        category: _categoryController.text.trim(),
        stock: stock,
        restockLevel: restockLevel,
        productType: _productType,
        imageBase64: mainImageBase64,
        additionalImagesBase64: additionalImagesBase64,
        active: _isActive,
      );

      final success = await context.read<ProductProvider>().addProduct(product);

      if (success) {
        if (mounted) {
          FlushbarHelper.show(context, "Product added successfully!", isSuccess: true);
          if (!widget.showAsTab) {
            Navigator.pop(context);
          } else {
            _clearForm();
            context.read<ProductProvider>().fetchProducts();
          }
        }
      } else {
        if (mounted) {
          _showError("Failed to add product");
        }
      }
    } catch (e) {
      if (mounted) {
        _showError("Error saving product: $e");
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _categoryController.clear();
    _descriptionController.clear();
    _stockController.clear();
    _restockLevelController.clear();
    _priceController.clear();
    _discountPriceController.clear();
    setState(() {
      _mainImageBytes = null;
      _additionalImagesBytes.clear();
      _productType = 'RETAIL';
      _isActive = true;
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
                  await context.read<ProductProvider>().fetchProducts();
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
                          const Text("PRODUCT LIST", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const Divider(color: Color(0XFFFF0B01), thickness: 2, endIndent: 220),
                          const SizedBox(height: 15),
                          _buildProductsList(),
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
        if (!widget.showAsTab) ...[
          Row(
            children: const [
              Icon(Icons.add, size: 20),
              SizedBox(width: 4),
              Text("ADD PRODUCTS", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            ],
          ),
          const Divider(color: Color(0XFFFF0B01), thickness: 2, endIndent: 200),
          const SizedBox(height: 20),
        ],

        const Text("Main Product Image", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Container(
          height: _mainImageBytes != null ? 150 : 70,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0XFF909090)),
            borderRadius: BorderRadius.circular(9),
            image: _mainImageBytes != null
                ? DecorationImage(image: MemoryImage(_mainImageBytes!), fit: BoxFit.cover)
                : null,
          ),
          child: _mainImageBytes == null
              ? Center(child: SvgPicture.asset("assets/Images/AddProductScreen/inside_camera.svg", width: 28, height: 28))
              : null,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconLabel("assets/Images/AddProductScreen/camera_icon.svg", "Camera", onTap: () => _pickMainImage(ImageSource.camera)),
            const SizedBox(width: 20),
            _buildIconLabel("assets/Images/AddProductScreen/gallery_icon.svg", "Gallery", onTap: () => _pickMainImage(ImageSource.gallery)),
          ],
        ),

        const SizedBox(height: 25),
        const Text("Additional Images", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        if (_additionalImagesBytes.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _additionalImagesBytes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          image: DecorationImage(image: MemoryImage(_additionalImagesBytes[index]), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _additionalImagesBytes.removeAt(index);
                            });
                          },
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.close, size: 16, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0XFF909090)),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(child: SvgPicture.asset("assets/Images/AddProductScreen/inside_camera.svg", width: 28, height: 28)),
          ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconLabel("assets/Images/AddProductScreen/camera_icon.svg", "Camera", onTap: () => _pickAdditionalImage(ImageSource.camera)),
            const SizedBox(width: 20),
            _buildIconLabel("assets/Images/AddProductScreen/gallery_icon.svg", "Gallery", onTap: () async {
              final List<XFile> pickedFiles = await _picker.pickMultiImage();
              if (pickedFiles.isNotEmpty) {
                for (var file in pickedFiles) {
                  final bytes = await file.readAsBytes();
                  setState(() {
                    _additionalImagesBytes.add(bytes);
                  });
                }
              }
            }),
          ],
        ),

        const SizedBox(height: 25),
        _buildTextField("Product Name", "assets/Images/AddProductScreen/product_details_icon.svg", controller: _nameController),
        const SizedBox(height: 20),
        _buildDropdownField(
          "Product Type",
          "assets/Images/AddProductScreen/product_type_icon.svg",
          value: _productType,
          items: ['RETAIL', 'WHOLESALE'],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _productType = val;
              });
            }
          },
        ),
        const SizedBox(height: 20),
        _buildTextField("Category", "assets/Images/AddProductScreen/product_type_icon.svg", controller: _categoryController),
        const SizedBox(height: 20),
        _buildTextField("Product Description", "assets/Images/AddProductScreen/product_description_icon.svg", controller: _descriptionController),
        const SizedBox(height: 20),
        _buildTextField("Stock", "assets/Images/AddProductScreen/product_quantity_icon.svg", controller: _stockController, keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        _buildTextField("Restock Level", "assets/Images/AddProductScreen/product_quantity_icon.svg", controller: _restockLevelController, keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        _buildTextField("Price", "assets/Images/AddProductScreen/rate_icon.svg", controller: _priceController, keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        _buildTextField("Discount Price", "assets/Images/AddProductScreen/rate_icon.svg", controller: _discountPriceController, keyboardType: TextInputType.number),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0XFFF8F8F8),
            border: Border.all(color: const Color(0XFF909090)),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Active", style: TextStyle(fontSize: 16, color: Color(0xFF606060))),
              Switch(
                value: _isActive,
                onChanged: (val) {
                  setState(() {
                    _isActive = val;
                  });
                },
                activeColor: const Color(0XFFFF0B01),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        Consumer<ProductProvider>(
          builder: (context, provider, child) {
            return Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("SAVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (!widget.showAsTab) {
                        Navigator.pop(context);
                      } else {
                        _clearForm();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    ),
                    child: const Text("CANCEL", style: TextStyle(color: Color(0XFF909090))),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.products.isEmpty) {
          return const Center(child: Text("No products found."));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.products.length,
          itemBuilder: (context, index) {
            final product = provider.products[index];
            Widget imageWidget = const Icon(Icons.shopping_bag_outlined, color: Color(0XFFFF0B01));
            
            if (product.imageBase64 != null && product.imageBase64!.isNotEmpty) {
              try {
                imageWidget = Image.memory(
                  base64Decode(product.imageBase64!),
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const Icon(Icons.image_not_supported, color: Color(0XFFFF0B01)),
                );
              } catch (e) {
                // Ignore base64 decode errors
              }
            }

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
                    clipBehavior: Clip.hardEdge,
                    child: imageWidget,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(product.category ?? "No Category", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("\u{20B9}${product.price}", style: const TextStyle(color: Color(0XFFFF0B01), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(product.id),
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(int? id) async {
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
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
      final success = await context.read<ProductProvider>().deleteProduct(id);
      if (success && mounted) {
        FlushbarHelper.show(context, 'Product deleted successfully');
      }
    }
  }

  Widget _buildIconLabel(String icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(icon, width: 18, height: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, String icon, {TextEditingController? controller, TextInputType? keyboardType}) {
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

  Widget _buildDropdownField(String hint, String icon, {required String value, required List<String> items, required void Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0XFFF8F8F8),
        border: Border.all(color: const Color(0XFF909090)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Row(
            children: [
              SvgPicture.asset(icon, width: 20, height: 20),
              const SizedBox(width: 10),
              Text(hint),
            ],
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  SvgPicture.asset(icon, width: 20, height: 20),
                  const SizedBox(width: 10),
                  Text(item),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
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
                image: AssetImage("assets/Images/AddProductScreen/add_product_background_image.jpg"), 
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 25, bottom: 20),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    const Color(0XFFFF3502).withOpacity(0.7)
                  ],
                ),
              ),
              child: const Text("PRODUCTS",
                  style: TextStyle(
                      color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500)
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
        Positioned(
          right: 10,
          bottom: 20,
          child: CircleAvatar(
            backgroundColor: const Color(0XFFFF0B01),
            radius: 30,
            child: SvgPicture.asset(
              "assets/Images/AddProductScreen/add_product_floating_bg_img.svg",
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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