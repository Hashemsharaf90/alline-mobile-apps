import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/widgets/category_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/widgets/category_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  final bool isBackButtonExist;

  const CategoryScreen({
    super.key,
    this.isBackButtonExist = false,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final categoryController =
        Provider.of<CategoryController>(context, listen: false);
    if (categoryController.categoryList.isEmpty) {
      categoryController.getCategoryList(false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    final bool canGoBack =
        widget.isBackButtonExist && Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header: Title & Search Field ──────────────────────────
            _buildHeader(context, canGoBack),

            // ─── Main Content ──────────────────────────────────────────
            Expanded(
              child: Consumer<CategoryController>(
                builder: (context, categoryController, _) {
                  final List<CategoryModel> allCategories =
                      categoryController.categoryList;

                  // 1. Loading State (Shimmer skeleton grid)
                  if (allCategories.isEmpty) {
                    return const SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: CategoryGridShimmerWidget(itemCount: 8),
                    );
                  }

                  // 2. Real-time Live Filtered Categories
                  final List<CategoryModel> displayedCategories =
                      _searchQuery.isEmpty
                          ? allCategories
                          : allCategories
                              .where((category) => (category.name ?? '')
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()))
                              .toList();

                  // 3. Empty Search State
                  if (_searchQuery.isNotEmpty && displayedCategories.isEmpty) {
                    return _buildEmptySearchState();
                  }

                  // 4. Main 2-Column Photography-Led Grid
                  return RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    backgroundColor: colors.surface,
                    onRefresh: () async {
                      await categoryController.getCategoryList(true);
                    },
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: displayedCategories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.84,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemBuilder: (context, index) {
                        return CategoryCardWidget(
                          category: displayedCategories[index],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Clean, modern Alline Header with title and live-search bar
  Widget _buildHeader(BuildContext context, bool canGoBack) {
    final colors = AllineThemeColors.of(context);
    return Container(
      color: colors.background,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title Bar
          Row(
            children: [
              if (canGoBack) ...[
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                getTranslated('all_category', context) ?? 'التصنيفات',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Live Filter Search Bar
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.border,
                width: 1.2,
              ),
              boxShadow: Theme.of(context).brightness == Brightness.dark
                  ? null
                  : [
                      BoxShadow(
                        color: colors.textPrimary.withValues(alpha: .04),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                hintText: getTranslated('search_category', context) ??
                    'ابحث عن تصنيف',
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Compact empty state when no category matches user search
  Widget _buildEmptySearchState() {
    final colors = AllineThemeColors.of(context);
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: .09),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              getTranslated('no_category_match', context) ??
                  'لا توجد تصنيفات مطابقة',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              getTranslated('try_another_search', context) ??
                  'جرّب كلمة بحث أخرى',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                getTranslated('clear_search', context) ?? 'مسح البحث',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
