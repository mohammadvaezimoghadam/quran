import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart' hide BarcodeFormat;
import 'package:permission_handler/permission_handler.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/page_navigation_controller.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';

class PageNavigationBottomSheet extends ConsumerStatefulWidget {
  const PageNavigationBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PageNavigationBottomSheet(),
    );
  }

  @override
  ConsumerState<PageNavigationBottomSheet> createState() => _PageNavigationBottomSheetState();
}

class _PageNavigationBottomSheetState extends ConsumerState<PageNavigationBottomSheet> {
  final _pageController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.unrestricted,
    formats: [BarcodeFormat.qrCode],
  );
  bool _showScanner = false;
  bool _isProcessingScanner = false;

  @override
  void dispose() {
    _pageController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await _scannerController.start();
      if (mounted) setState(() {});
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      await _scannerController.start();
      if (mounted) setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      String? rawValue;

      try {
        final BarcodeCapture? capture = await _scannerController.analyzeImage(image.path);
        if (capture != null && capture.barcodes.isNotEmpty) {
          rawValue = capture.barcodes.first.rawValue;
        }
      } catch (_) {
        // MobileScanner failed, fallback below
      }

      // Fallback to ZXing2 if MobileScanner's analyzeImage failed (which is common on Android)
      if (rawValue == null) {
        try {
          final bytes = await File(image.path).readAsBytes();
          final decodedImage = img.decodeImage(bytes);
          if (decodedImage != null) {
            final pixels = Int32List(decodedImage.width * decodedImage.height);
            int i = 0;
            for (final p in decodedImage) {
              pixels[i++] = (p.a.toInt() << 24) | (p.r.toInt() << 16) | (p.g.toInt() << 8) | p.b.toInt();
            }
            LuminanceSource source = RGBLuminanceSource(decodedImage.width, decodedImage.height, pixels);
            BinaryBitmap bitmap = BinaryBitmap(HybridBinarizer(source));
            Result result = QRCodeReader().decode(bitmap);
            rawValue = result.text;
          }
        } catch (_) {
          // ZXing2 fallback failed
        }
      }

      setState(() => _isProcessingScanner = false);
      
      if (rawValue != null) {
         ref.read(pageNavigationControllerProvider.notifier).processQrData(rawValue);
         return;
      }
      
      if (mounted) {
         if (context.canPop()) {
           context.pop();
         }
         AppSnackBar.showError(context, 'هیچ کد QR معتبری در این تصویر یافت نشد.');
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessingScanner) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? rawValue = barcodes.first.rawValue;
      if (rawValue != null) {
        setState(() {
          _isProcessingScanner = true;
        });
        
        ref.read(pageNavigationControllerProvider.notifier).processQrData(rawValue).then((_) {
          if (mounted) {
            setState(() {
              _isProcessingScanner = false;
              _showScanner = false; // go back on fail so they can see error, on success it pops anyway
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(pageNavigationControllerProvider.select((s) => s.isLoading));

    ref.listen(pageNavigationControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        if (context.canPop()) {
           context.pop();
        }
        AppSnackBar.showError(context, next.errorMessage!);
      }
      
      if (next.target != null && next.target != previous?.target) {
        if (context.canPop()) {
           context.pop();
        }
        
        ref.read(quranDisplaySettingsControllerProvider.notifier).toggleArabicText(true);
        context.pushNamed(
          quranReaderRoute,
          pathParameters: {'id': next.target!.surahId.toString()},
          queryParameters: {
            'name': next.target!.surahName, 
            'ayah': next.target!.ayahNumber.toString(),
          },
        );
      }
    });

    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final navBarPadding = MediaQuery.viewPaddingOf(context).bottom;
    final bottomSpacing = keyboardInset > 0
        ? keyboardInset + 16.0
        : (navBarPadding > 0 ? navBarPadding + 16.0 : 24.0);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: bottomSpacing,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 5),
          ],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: _showScanner ? _buildScannerView(context) : _buildInputView(context, isLoading),
        ),
      ),
    );
  }

  Widget _buildInputView(BuildContext context, bool isLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppConstants.pageNavigationTitle,
          style: AppTypography.sectionHeader.copyWith(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        20.vSpace,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _pageController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'شماره صفحه (۱ تا ۶۰۴)',
                  hintStyle: AppTypography.searchHint.copyWith(color: AppColors.outline),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white.withValues(alpha: 0.05) 
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
            12.hSpace,
            ElevatedButton(
              onPressed: isLoading ? null : () {
                final text = _pageController.text.trim();
                final pageNum = int.tryParse(text);
                if (pageNum != null) {
                  ref.read(pageNavigationControllerProvider.notifier).processPageNumber(pageNum);
                } else {
                   if (context.canPop()) {
                     context.pop();
                   }
                   AppSnackBar.showError(context, 'لطفاً یک عدد معتبر وارد کنید');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'تایید',
                      style: AppTypography.bottomSheetActionLabel,
                    ),
            ),
          ],
        ),
        24.vSpace,
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.outline)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'یا',
                style: AppTypography.searchHint.copyWith(color: AppColors.outline),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.outline)),
          ],
        ),
        24.vSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                   setState(() => _showScanner = true);
                },
                icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                label: Text(
                  'اسکن دوربین', 
                  style: AppTypography.buttonLabel.copyWith(color: AppColors.primary, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            12.hSpace,
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library, color: AppColors.primary),
                label: Text(
                  'انتخاب گالری', 
                  style: AppTypography.buttonLabel.copyWith(color: AppColors.primary, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScannerView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'اسکن کد صفحه',
              style: AppTypography.sectionHeader.copyWith(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _showScanner = false),
            ),
          ],
        ),
        16.vSpace,
        SizedBox(
          height: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                  errorBuilder: (context, error, child) {
                    return Container(
                      color: Colors.black87,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_outlined, color: Colors.orangeAccent, size: 44),
                          const SizedBox(height: 12),
                          const Text(
                            'دسترسی به دوربین فعال نیست',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'برای اسکن کد QR صفحه قرآن، نیاز به دسترسی دوربین است.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _requestCameraPermission,
                            icon: const Icon(Icons.security, size: 16),
                            label: const Text(
                              'اعطای دسترسی به دوربین',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: ScannerOverlayPainter(
                        borderColor: Colors.white.withValues(alpha: 0.8),
                        borderWidth: 4.0,
                        cornerLength: 24.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isProcessingScanner)
           const Padding(
             padding: EdgeInsets.only(top: 16.0),
             child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
           )
        else 
           Padding(
             padding: const EdgeInsets.only(top: 16.0),
             child: Text(
               'QR کد را در کادر بالا قرار دهید',
               textAlign: TextAlign.center,
               style: AppTypography.searchHint,
             ),
           ),
      ],
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double cornerLength;

  ScannerOverlayPainter({
    required this.borderColor,
    this.borderWidth = 4.0,
    this.cornerLength = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Top Left
    canvas.drawLine(const Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, cornerLength), paint);

    // Top Right
    canvas.drawLine(Offset(w, 0), Offset(w - cornerLength, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cornerLength), paint);

    // Bottom Left
    canvas.drawLine(Offset(0, h), Offset(cornerLength, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - cornerLength), paint);

    // Bottom Right
    canvas.drawLine(Offset(w, h), Offset(w - cornerLength, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
