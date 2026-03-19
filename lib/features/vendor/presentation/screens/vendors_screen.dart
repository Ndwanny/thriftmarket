import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
    final crossAxisCount = screenWidth >= 900 ? 3 : screenWidth >= 600 ? 2 : 1;

    final vendors = allVendors.whenData((list) {
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
              slivers: [
                // App bar
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

                // Results
                vendors.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2),
                    ),
                  ),
                  error: (e, _) => SliverFillRemaining(
                    child: Center(
                      child: Text('Error: $e',
                          style:
                              const TextStyle(color: AppColors.grey600)),
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
                    return crossAxisCount == 1
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => Padding(
                                padding: EdgeInsets.fromLTRB(
                                    16, i == 0 ? 16 : 8, 16, 0),
                                child: _VendorCard(vendor: list[i]),
                              ),
                              childCount: list.length,
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.55,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (_, i) => _VendorCard(vendor: list[i]),
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
        onChanged: (v) => ref.read(vendorSearchQueryProvider.notifier).search(v),
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
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(2),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Banner image
            if (vendor.bannerUrl != null)
              CachedNetworkImage(
                imageUrl: vendor.bannerUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.grey900),
              )
            else
              Container(color: AppColors.grey900),

            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xCC000000),
                  ],
                  stops: [0.3, 1.0],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo + verified badge
                  Row(
                    children: [
                      _VendorLogo(logoUrl: vendor.logoUrl, name: vendor.storeName),
                      if (vendor.isVerified)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
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
                  ),
                  const Spacer(),
                  // Store name
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
                  const SizedBox(height: 4),
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
                      const SizedBox(width: 8),
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
      width: 36,
      height: 36,
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
              errorWidget: (_, __, ___) => _Initials(name: name),
            )
          : _Initials(name: name),
    );
  }
}

class _Initials extends StatelessWidget {
  final String name;
  const _Initials({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'V',
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
    );
  }
}
