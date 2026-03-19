import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../domain/entities/vendor_entity.dart';
import '../providers/vendor_provider.dart';

class VendorsScreen extends ConsumerStatefulWidget {
  const VendorsScreen({super.key});

  @override
  ConsumerState<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends ConsumerState<VendorsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allVendors = ref.watch(allVendorsProvider);
    final query = ref.watch(vendorSearchQueryProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 900 ? 3 : 2;

    final filteredList = allVendors.whenData((list) {
      if (query.isEmpty) return list;
      final q = query.toLowerCase();
      return list
          .where((v) =>
              v.storeName.toLowerCase().contains(q) ||
              (v.storeDescription?.toLowerCase().contains(q) ?? false))
          .toList();
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: screenWidth >= 1400 ? 1400 : double.infinity),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.black,
                  elevation: 0,
                  toolbarHeight: 60,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: AppColors.white, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  title: const Text(
                    'VENDORS',
                    style: TextStyle(
                      color: AppColors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(56),
                    child: Container(
                      color: AppColors.black,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _SearchBar(controller: _searchController),
                    ),
                  ),
                ),

                filteredList.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2),
                    ),
                  ),
                  error: (e, _) => SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Error loading vendors: $e',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.grey600)),
                      ),
                    ),
                  ),
                  data: (list) {
                    if (list.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.storefront_outlined,
                                  size: 48, color: AppColors.grey300),
                              const SizedBox(height: 12),
                              Text(
                                query.isNotEmpty
                                    ? 'No vendors match "$query"'
                                    : 'No vendors yet',
                                style: const TextStyle(
                                    color: AppColors.grey500,
                                    fontFamily: 'Poppins',
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 140,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _VendorCard(vendor: list[i])
                              .animate(
                                  delay: Duration(
                                      milliseconds: 60 * (i % 6)))
                              .fadeIn(duration: 400.ms)
                              .slideY(
                                  begin: 0.05,
                                  end: 0,
                                  curve: Curves.easeOutCubic),
                          childCount: list.length,
                        ),
                      ),
                    );
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(2),
      ),
      child: TextField(
        controller: controller,
        onChanged: (v) =>
            ref.read(vendorSearchQueryProvider.notifier).search(v),
        style: const TextStyle(
            color: AppColors.white, fontFamily: 'Poppins', fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search vendors...',
          hintStyle: const TextStyle(
              color: AppColors.grey500, fontFamily: 'Poppins', fontSize: 13),
          prefixIcon:
              const Icon(Icons.search, color: AppColors.grey500, size: 18),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.grey500, size: 16),
                  onPressed: () {
                    controller.clear();
                    ref.read(vendorSearchQueryProvider.notifier).clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final VendorEntity vendor;
  const _VendorCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${RouteNames.vendorStore}/${vendor.id}'),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.grey900,
          borderRadius: BorderRadius.circular(2),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Banner image — fills the card
            if (vendor.bannerUrl != null)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: vendor.bannerUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.grey900),
                ),
              )
            else
              Positioned.fill(child: Container(color: AppColors.grey900)),

            // Dark gradient from bottom
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xDD000000)],
                    stops: [0.2, 1.0],
                  ),
                ),
              ),
            ),

            // Top: logo + verified badge
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  _VendorLogo(
                      logoUrl: vendor.logoUrl, name: vendor.storeName),
                  if (vendor.isVerified) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      color: AppColors.primary,
                      child: const Text(
                        'VERIFIED',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Bottom: name + rating
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vendor.storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 11, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Text(
                        vendor.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            color: AppColors.grey300,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${vendor.reviewCount} reviews',
                        style: const TextStyle(
                            color: AppColors.grey500, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorLogo extends StatelessWidget {
  final String? logoUrl;
  final String name;
  const _VendorLogo({required this.logoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
        color: AppColors.grey900,
      ),
      clipBehavior: Clip.hardEdge,
      child: logoUrl != null
          ? CachedNetworkImage(
              imageUrl: logoUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'V',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
            )
          : Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'V',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
    );
  }
}
