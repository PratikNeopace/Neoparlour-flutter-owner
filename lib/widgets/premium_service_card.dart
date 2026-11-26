import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/salon_provider.dart';
import 'package:neo_parlour_owner/data/models/service_model.dart';

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
            // Photo removed as requested
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
                  Builder(
                    builder: (context) {
                      final profile = Provider.of<SalonProvider>(context, listen: false).salonProfile;
                      final bool hasGst = (profile?.includeGstInInvoice ?? false) &&
                          (profile?.gstin != null && profile!.gstin!.trim().isNotEmpty);

                      return Row(
                        children: [
                          Text(
                            "\u{20B9}${service.price.toStringAsFixed(0)}",
                            style: const TextStyle(color: Color(0XFFFF0B01), fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          if (hasGst) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "Incl. 18% GST",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
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
