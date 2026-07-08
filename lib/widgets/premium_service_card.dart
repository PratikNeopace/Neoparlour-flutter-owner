import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/data/models/service_model.dart';
import 'package:neo_parlour_owner/widgets/premium_image.dart';

class PremiumServiceCard extends StatelessWidget {
  final NeoService service;
  final bool isActive;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onToggleVisibility;

  const PremiumServiceCard({
    super.key,
    required this.service,
    required this.isActive,
    required this.index,
    required this.onEdit,
    required this.onToggleVisibility,
  });

  Widget _buildPlaceholderImage() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[100],
      child: const Icon(Icons.image_not_supported, size: 24, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(service.id ?? index.toString()),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.6,
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.drag_indicator, color: Color(0XFFC4C4C4)),
              ),
            ),
            const SizedBox(width: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: (service.imageUrl != null && service.imageUrl!.isNotEmpty)
                  ? PremiumImageWidget(
                      imageUrl: service.imageUrl,
                      width: 70,
                      height: 70,
                      borderRadius: BorderRadius.circular(18),
                    )
                  : (service.image != null && service.image!.isNotEmpty)
                      ? (service.image!.startsWith('assets/')
                          ? Image.asset(service.image!, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage())
                          : Image.memory(base64Decode(service.image!), width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage()))
                      : _buildPlaceholderImage(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive ? "Active" : "Inactive",
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${service.category} • ${service.duration} min",
                    style: const TextStyle(color: Color(0XFF8A8A8A), fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "\u{20B9}${service.price.toStringAsFixed(0)}",
                    style: const TextStyle(color: Color(0XFFFF0B01), fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  color: Colors.blue,
                  onTap: onEdit,
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  icon: isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: isActive ? Colors.amber : Colors.green,
                  onTap: onToggleVisibility,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.3)),
          color: color.withValues(alpha: 0.05),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
