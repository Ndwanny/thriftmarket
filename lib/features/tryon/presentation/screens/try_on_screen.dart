import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/try_on_provider.dart';

/// Full-screen try-on experience pushed on top of the product detail page.
class TryOnScreen extends ConsumerWidget {
  final String productTitle;
  final String garmentImageUrl;

  const TryOnScreen({
    super.key,
    required this.productTitle,
    required this.garmentImageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tryOnProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.white, size: 20),
          onPressed: () {
            ref.read(tryOnProvider.notifier).reset();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'VIRTUAL TRY-ON',
          style: TextStyle(
            color: AppColors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        actions: [
          if (state.status == TryOnStatus.success)
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.primary, size: 22),
              tooltip: 'Try again',
              onPressed: () => ref.read(tryOnProvider.notifier).reset(),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _TryOnBody(
                state: state,
                garmentImageUrl: garmentImageUrl,
              ),
            ),
            if (state.status == TryOnStatus.idle ||
                state.status == TryOnStatus.error)
              _PickerBar(garmentImageUrl: garmentImageUrl),
          ],
        ),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────

class _TryOnBody extends StatelessWidget {
  final TryOnState state;
  final String garmentImageUrl;

  const _TryOnBody({required this.state, required this.garmentImageUrl});

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      TryOnStatus.idle => _IdleView(garmentImageUrl: garmentImageUrl),
      TryOnStatus.pickingImage => const _LoadingView(
          message: 'Opening camera...'),
      TryOnStatus.loading => _LoadingView(
          personImageBytes: state.personImageBytes,
          garmentImageUrl: garmentImageUrl,
          message: 'Generating your try-on...',
        ),
      TryOnStatus.success => _ResultView(
          personImageBytes: state.personImageBytes,
          resultImageBytes: state.resultImageBytes!,
          garmentImageUrl: garmentImageUrl,
        ),
      TryOnStatus.error => _ErrorView(message: state.errorMessage),
    };
  }
}

// ── Idle ─────────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  final String garmentImageUrl;
  const _IdleView({required this.garmentImageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Garment preview
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              garmentImageUrl,
              height: 260,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 260,
                color: AppColors.grey900,
                child: const Icon(Icons.image_outlined,
                    size: 48, color: AppColors.grey600),
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.04, end: 0),
          const SizedBox(height: 32),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(Icons.checkroom_rounded,
                color: AppColors.black, size: 26),
          ).animate(delay: 100.ms).scale(begin: const Offset(0.6, 0.6)),
          const SizedBox(height: 16),
          const Text(
            'Virtual Try-On',
            style: TextStyle(
              color: AppColors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          const Text(
            'Take a full-body photo or upload from your gallery.\nWe\'ll show you how this item looks on you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.grey400,
              fontFamily: 'Poppins',
              fontSize: 13,
              height: 1.6,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final Uint8List? personImageBytes;
  final String? garmentImageUrl;
  final String? message;

  const _LoadingView({this.personImageBytes, this.garmentImageUrl, this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (personImageBytes != null && garmentImageUrl != null) ...[
            Row(
              children: [
                Expanded(
                  child: _ImageFrame(
                    label: 'YOU',
                    child: Image.memory(
                      personImageBytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: AppColors.black, size: 18),
                  ),
                ),
                Expanded(
                  child: _ImageFrame(
                    label: 'ITEM',
                    child: Image.network(
                      garmentImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.grey900),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
          const SizedBox(height: 20),
          Text(
            message ?? 'Generating your try-on...',
            style: const TextStyle(
              color: AppColors.grey300,
              fontFamily: 'Poppins',
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This may take 10–20 seconds',
            style: TextStyle(
              color: AppColors.grey600,
              fontFamily: 'Poppins',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result ────────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  final Uint8List? personImageBytes;
  final Uint8List resultImageBytes;
  final String garmentImageUrl;

  const _ResultView({
    required this.personImageBytes,
    required this.resultImageBytes,
    required this.garmentImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Result image — big and prominent
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.memory(
              resultImageBytes,
              fit: BoxFit.contain,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 16),
          // Before / garment comparison row
          Row(
            children: [
              Expanded(
                child: _ImageFrame(
                  label: 'ORIGINAL',
                  child: personImageBytes != null
                      ? Image.memory(
                          personImageBytes!,
                          fit: BoxFit.cover,
                        )
                      : Container(color: AppColors.grey900),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ImageFrame(
                  label: 'GARMENT',
                  child: Image.network(
                    garmentImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.grey900),
                  ),
                ),
              ),
            ],
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String? message;
  const _ErrorView({this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 52, color: AppColors.grey600),
          const SizedBox(height: 16),
          const Text(
            'Try-On Unavailable',
            style: TextStyle(
              color: AppColors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message ?? 'Something went wrong. Please try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.grey400,
              fontFamily: 'Poppins',
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom picker bar ─────────────────────────────────────────────────────

class _PickerBar extends ConsumerWidget {
  final String garmentImageUrl;
  const _PickerBar({required this.garmentImageUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(tryOnProvider).status == TryOnStatus.loading ||
        ref.watch(tryOnProvider).status == TryOnStatus.pickingImage;

    void pick(ImageSource source) {
      ref.read(tryOnProvider.notifier).tryOn(
            garmentImageUrl: garmentImageUrl,
            source: source,
          );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.grey900,
        border: Border(top: BorderSide(color: AppColors.grey800)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: loading ? null : () => pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('GALLERY'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.grey600),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: loading ? null : () => pick(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_rounded, size: 18),
              label: const Text('CAMERA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared frame widget ───────────────────────────────────────────────────

class _ImageFrame extends StatelessWidget {
  final String label;
  final Widget child;
  const _ImageFrame({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.grey900,
          ),
          clipBehavior: Clip.hardEdge,
          child: child,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.grey500,
            fontFamily: 'Poppins',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
