import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/constants/app_colors.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  int _currentIndex = 0;

  final List<_BannerData> _banners = [
    _BannerData(
      title: 'Up to 50% Off\nTop Brands',
      subtitle: 'Limited time deals',
      gradient: [Color(0xFF6C3CE1), Color(0xFF9B72F0)],
      icon: Icons.local_offer_rounded,
    ),
    _BannerData(
      title: 'Free Delivery\nOn Orders K200+',
      subtitle: 'All vendors included',
      gradient: [Color(0xFFFF6B35), Color(0xFFFFAA60)],
      icon: Icons.local_shipping_rounded,
    ),
    _BannerData(
      title: 'New Vendors\nJoined This Week',
      subtitle: 'Discover fresh stores',
      gradient: [Color(0xFF10B981), Color(0xFF34D399)],
      icon: Icons.storefront_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 160,
            viewportFraction: 0.88,
            enlargeCenterPage: true,
            enlargeFactor: 0.1,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayCurve: Curves.easeInOut,
            onPageChanged: (i, _) => setState(() => _currentIndex = i),
          ),
          items: _banners.map((banner) => _BannerCard(data: banner)).toList(),
        ),
        const SizedBox(height: 12),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: _banners.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: AppColors.primary,
            dotColor: AppColors.grey300,
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final _BannerData data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Shop Now',
                    style: TextStyle(
                      color: data.gradient.first,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(data.icon, color: Colors.white.withOpacity(0.25), size: 80),
        ],
      ),
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
  const _BannerData(
      {required this.title,
      required this.subtitle,
      required this.gradient,
      required this.icon});
}
