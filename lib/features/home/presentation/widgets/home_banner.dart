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
      eyebrow: 'LONGACRES MALL · 2016 EDITION',
      title: 'THRIFT\nMARKET\nLUSAKA',
      cta: 'SHOP THE DROP',
      bgColor: AppColors.black,
      textColor: AppColors.white,
      accentColor: AppColors.primary,
      imageUrl: 'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=600&q=80&fit=crop',
    ),
    _BannerData(
      eyebrow: 'VINTAGE · STREETWEAR · CULTURE',
      title: 'FIND YOUR\nSTYLE\nHERE',
      cta: 'EXPLORE NOW',
      bgColor: AppColors.primary,
      textColor: AppColors.black,
      accentColor: AppColors.black,
      imageUrl: 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=600&q=80&fit=crop',
    ),
    _BannerData(
      eyebrow: 'CAMERAS · JEWELRY · COLLECTABLES',
      title: 'RARE\nFINDS\nAWAIT',
      cta: 'DISCOVER MORE',
      bgColor: AppColors.white,
      textColor: AppColors.black,
      accentColor: AppColors.black,
      imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600&q=80&fit=crop',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayCurve: Curves.easeInOut,
            onPageChanged: (i, _) => setState(() => _currentIndex = i),
          ),
          items: _banners.map((banner) => _BannerCard(data: banner)).toList(),
        ),
        const SizedBox(height: 10),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: _banners.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: AppColors.primary,
            dotColor: AppColors.grey300,
            dotHeight: 4,
            dotWidth: 4,
            expansionFactor: 4,
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
      color: data.bgColor,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    color: data.accentColor,
                    child: Text(
                      data.eyebrow,
                      style: TextStyle(
                        color: data.bgColor == AppColors.primary ? AppColors.black : (data.accentColor == AppColors.black ? AppColors.white : AppColors.black),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data.title,
                    style: TextStyle(
                      color: data.textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                      fontFamily: 'Poppins',
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    color: data.accentColor,
                    child: Text(
                      data.cta,
                      style: TextStyle(
                        color: data.bgColor == AppColors.primary ? AppColors.white : (data.accentColor == AppColors.primary ? AppColors.black : AppColors.white),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox.expand(
              child: Image.network(
                data.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.grey200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerData {
  final String eyebrow;
  final String title;
  final String cta;
  final Color bgColor;
  final Color textColor;
  final Color accentColor;
  final String imageUrl;
  const _BannerData({
    required this.eyebrow,
    required this.title,
    required this.cta,
    required this.bgColor,
    required this.textColor,
    required this.accentColor,
    required this.imageUrl,
  });
}
