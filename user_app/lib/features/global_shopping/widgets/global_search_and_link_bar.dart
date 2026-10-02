import 'package:flutter/material.dart';

class GlobalSearchAndLinkBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddLinkTap;
  final VoidCallback onClearSearch;

  const GlobalSearchAndLinkBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onAddLinkTap,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF015FC9);
    const borderColor = Color(0xFFE1E8F2);
    const navyColor = Color(0xFF071B49);
    const secondaryTextColor = Color(0xFF6D85AF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Search Input Field (takes available space, height 54px)
            Expanded(
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: navyColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ابحث في المنتجات المعروضة',
                    hintStyle: const TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8EA5C8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: InputBorder.none,
                    isDense: true,
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF8EA5C8)),
                            onPressed: onClearSearch,
                          )
                        : const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF8EA5C8),
                            size: 22,
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Add Link Primary Button (height 54px matching design token)
            InkWell(
              onTap: onAddLinkTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'إضافة رابط منتج',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.add_link_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'يمكنك إضافة رابط أي منتج من متجر عالمي وسنقوم بتوفيره لك بشكل منفصل.',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: secondaryTextColor,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
