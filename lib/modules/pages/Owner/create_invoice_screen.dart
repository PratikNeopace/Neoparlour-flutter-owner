import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final TextEditingController _noteController = TextEditingController();
  int _quantity = 1;

  final Color _focusedColor = const Color(0XFFFF0B01);
  final Color _unfocusedColor = const Color(0XFF909090);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      bottomNavigationBar: const OwnerBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _focusedColor,
        shape: const CircleBorder(),
        child: SvgPicture.asset(
          "assets/Images/BottomNavigationScreen/home_icon.svg",
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("BILL TO (OPTIONAL)", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildTextField(hint: "Search By Name, Number", imagePath: "assets/Images/CreateInvoiceScreen/name_icon.svg"),
                  const SizedBox(height: 15),
                  _buildDropdown(hint: "Select Service", items: ["Hair Cut", "Spa", "Facial"], imagePath: "assets/Images/CreateInvoiceScreen/service_icon.svg"),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(hint: "Amount", imagePath: "assets/Images/CreateInvoiceScreen/amount_icon.svg")),
                      const SizedBox(width: 15),
                      _buildQuantitySelector(),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown(hint: "Discount", imagePath: "assets/Images/CreateInvoiceScreen/discount_icon.svg", items: ["10%", "20%"])),
                      const SizedBox(width: 5),
                      Expanded(child: _buildDropdown(hint: "Taxes", imagePath: "assets/Images/CreateInvoiceScreen/tax_icon.svg", items: ["GST 5%", "GST 18%"])),
                    ],
                  ),
                  const Divider(height: 40, color: Colors.grey),
                  _buildPayableRow(),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown(hint: "₹450", items: ["₹450", "₹500"])),
                      const SizedBox(width: 5),
                      Expanded(child: _buildDropdown(hint: "Phonepe", items: ["Phonepe", "Cash", "Card"])),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text("INVOICE NOTE"),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: _inputDecoration("Note"),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: _focusedColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text("SUBMIT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? imagePath}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: imagePath != null ? Padding(padding: const EdgeInsets.all(12.0), child: SvgPicture.asset(imagePath, width: 20, height: 20)) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: _unfocusedColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: _focusedColor, width: 2)),
    );
  }

  Widget _buildTextField({required String hint, String? imagePath}) {
    return TextField(decoration: _inputDecoration(hint, imagePath: imagePath));
  }

  Widget _buildDropdown({required String hint, required List<String> items, String? imagePath}) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() {}),
      child: Builder(builder: (context) {
        final isFocused = Focus.of(context).hasFocus;
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: isFocused ? _focusedColor : _unfocusedColor, width: isFocused ? 2 : 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
              hint: Row(children: [
                if (imagePath != null) ...[SvgPicture.asset(imagePath, width: 20, height: 20), const SizedBox(width: 10)],
                Text(hint, style: const TextStyle(color: Colors.grey)),
              ]),
              icon: Icon(Icons.keyboard_arrow_down, color: isFocused ? _focusedColor : _unfocusedColor),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: (val) {},
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _quantity > 1 ? _quantity-- : null),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(5)),
            child: const Icon(Icons.remove, size: 20),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text("$_quantity", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        GestureDetector(
          onTap: () => setState(() => _quantity++),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(5)),
            child: const Icon(Icons.add, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderCurveClipper(),
          child: Container(
            height: 225,
            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/Images/CreateInvoiceScreen/background_image.jpg"), fit: BoxFit.cover)),
            child: Container(
              padding: const EdgeInsets.only(left: 25, bottom: 20),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.transparent, const Color(0XFFFF3502).withOpacity(0.7)])),
              child: const Text("CREATE INVOICE", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: GestureDetector(onTap: () => Navigator.pop(context), child: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.5), child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black))),
        ),

        Positioned(
          right: 10,
          bottom: 20,
          child: CircleAvatar(
            backgroundColor: const Color(0XFFFF0B01),
            radius: 30,
            child: SvgPicture.asset(
              "assets/Images/CreateInvoiceScreen/floating_img.svg",
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayableRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("AMOUNT PAYABLE", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("₹${450 * _quantity}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _focusedColor)),
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