import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageSelected;
  final Color activeColor;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
    this.activeColor = const Color(0XFFFF0B01),
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1 && currentPage == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 0
                ? () => onPageSelected(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 8),
          ..._buildPageNumbers(),
          const SizedBox(width: 8),
          IconButton(
            onPressed: currentPage < totalPages - 1
                ? () => onPageSelected(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> widgets = [];
    
    // Calculate range of 3 pages to show
    int start = currentPage - 1;
    int end = currentPage + 1;

    if (start < 0) {
      start = 0;
      end = (totalPages > 3) ? 2 : totalPages - 1;
    }
    if (end >= totalPages) {
      end = totalPages - 1;
      start = (totalPages > 3) ? totalPages - 3 : 0;
    }

    for (int index = start; index <= end; index++) {
      final isSelected = currentPage == index;
      widgets.add(
        GestureDetector(
          onTap: () => onPageSelected(index),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.white,
              border: Border.all(color: activeColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              (index + 1).toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : activeColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}
