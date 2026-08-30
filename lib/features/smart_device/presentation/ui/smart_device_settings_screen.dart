import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/islamic_katibah_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Commercial Wi-Fi AP Device Model for IoT connection
class DiscoveredWifiDevice {
  final String ssid;
  final String macAddress;
  final int signalStrength;
  final String defaultIp;

  DiscoveredWifiDevice({
    required this.ssid,
    required this.macAddress,
    required this.signalStrength,
    this.defaultIp = '192.168.4.1',
  });
}

/// Screen for scanning NodeMCU SoftAP Wi-Fi networks, connecting, and sending page numbers.
/// Styled in a clean White & Emerald Green Quran App theme.
class SmartDeviceSettingsScreen extends StatefulWidget {
  const SmartDeviceSettingsScreen({super.key});

  @override
  State<SmartDeviceSettingsScreen> createState() =>
      _SmartDeviceSettingsScreenState();
}

class _SmartDeviceSettingsScreenState extends State<SmartDeviceSettingsScreen>
    with SingleTickerProviderStateMixin {
  // Flow State: 0 = Searching Wi-Fi Networks (SoftAP), 1 = Connected Control Dashboard
  int _appStep = 0;

  // Controllers & Debouncers
  final TextEditingController _pageInputController =
      TextEditingController(text: '1');
  Timer? _debounceTimer;

  // Discovery State
  bool _isScanning = true;
  List<DiscoveredWifiDevice> _discoveredDevices = [];
  DiscoveredWifiDevice? _selectedDevice;
  bool _isConnectingToAp = false;

  // Dashboard Connected State
  bool _isConnected = false;
  bool _isOledOn = true;
  double _oledBrightness = 80.0;
  int _selectedDisplayMode = 0; // 0: QR Code Mode, 1: Page Text Mode
  int _currentPageNumber = 1; // 1..604 Quran pages

  // Radar Animation Controller
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.45).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // Auto-start Wi-Fi scan simulation
    _startWifiApScan();
  }

  Future<void> _startWifiApScan() async {
    setState(() {
      _isScanning = true;
      _discoveredDevices = [];
      _selectedDevice = null;
    });

    _pulseController.repeat();

    bool isNodeMcuReachable = false;
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(milliseconds: 1500),
          receiveTimeout: const Duration(milliseconds: 1500),
        ),
      );
      final response = await dio.get('http://192.168.4.1/set_page?page=$_currentPageNumber');
      if (response.statusCode == 200) {
        isNodeMcuReachable = true;
      }
    } catch (_) {
      isNodeMcuReachable = false;
    }

    if (!mounted) return;

    setState(() {
      _isScanning = false;
      _discoveredDevices = [
        DiscoveredWifiDevice(
          ssid: 'Quran_Smart_NodeMCU',
          macAddress: '5C:CF:7F:01:8A:2B',
          signalStrength: isNodeMcuReachable ? 100 : 85,
          defaultIp: '192.168.4.1',
        ),
      ];
      if (isNodeMcuReachable) {
        _selectedDevice = _discoveredDevices.first;
      }
    });
  }

  void _showPasswordDialog(DiscoveredWifiDevice device) {
    final TextEditingController passController =
        TextEditingController(text: '1234');
    String? errorMessage;
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.lock_shield_fill,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'اتصال به ${device.ssid}',
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'لطفاً رمز عبور اکسس‌پوینت این دستگاه را وارد کنید:',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: passController,
                      obscureText: obscurePassword,
                      autofocus: false,
                      style: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'رمز عبور (تست: 1234)',
                        prefixIcon: const Icon(CupertinoIcons.lock_fill, color: AppColors.primary, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? CupertinoIcons.eye_fill
                                : CupertinoIcons.eye_slash_fill,
                            color: Colors.grey,
                            size: 18,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        errorText: errorMessage,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text(
                      'انصراف',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (passController.text.trim() == '1234') {
                        Navigator.pop(dialogCtx);
                        _connectToWifiDevice(
                            device, passController.text.trim());
                      } else {
                        setDialogState(() {
                          errorMessage = 'رمز عبور اشتباه است! (1234)';
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'اتصال و ورود',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _connectToWifiDevice(DiscoveredWifiDevice device, String password) async {
    setState(() {
      _selectedDevice = device;
      _isConnectingToAp = true;
    });

    bool success = false;
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(milliseconds: 3000),
          receiveTimeout: const Duration(milliseconds: 3000),
          validateStatus: (status) => true, // Any status response from 192.168.4.1 means board is alive!
        ),
      );
      // Probe health check route first, then set initial page
      final response = await dio.get('http://${device.defaultIp}/');
      if (response.statusCode != null && response.statusCode! < 500) {
        success = true;
        // Fire initial page setup
        dio.get('http://${device.defaultIp}/set_page?page=$_currentPageNumber').ignore();
      }
    } catch (e) {
      debugPrint('[IoT Connection Probe Error]: $e');
      success = false;
    }

    if (!mounted) return;

    setState(() {
      _isConnectingToAp = false;
    });

    if (success) {
      setState(() {
        _isConnected = true;
        _appStep = 1; // Move to Dashboard
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(CupertinoIcons.checkmark_circle_fill,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ارتباط با وای‌فای ${device.ssid} برقرار شد (IP: ${device.defaultIp})',
                  style: const TextStyle(fontFamily: AppTypography.fontFamily),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // Show Wi-Fi Connection Warning Dialog with detailed guidance & bypass button
      showDialog(
        context: context,
        builder: (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(CupertinoIcons.wifi_exclamationmark, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Text(
                  'ارتباط با 192.168.4.1 برقرار نشد',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'دلایل متداول عدم برقراری ارتباط با NodeMCU:',
                  style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '۱. وای‌فای گوشی به شبکه Quran_Smart_NodeMCU متصل نیست (رمز: 1234).\n'
                  '۲. دیتا (اینترنت همراه 4G/5G) روشن است و اندروید ترافیک را به اینترنت همراه می‌فرستد. (لطفاً دیتای همراه را موقتا خاموش کنید).\n'
                  '۳. پیام اندروید مبنی بر «وای‌فای اینترنت ندارد، آیا متصل بمانید؟» را تأیید نکرده‌اید.',
                  style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12, height: 1.6, color: Colors.black87),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _isConnected = true;
                    _appStep = 1; // Direct test mode
                  });
                },
                child: const Text(
                  'ورود به داشبورد (تست UI)',
                  style: TextStyle(fontFamily: AppTypography.fontFamily, color: Colors.grey, fontSize: 12),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('تلاش مجدد', style: TextStyle(fontFamily: AppTypography.fontFamily)),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _disconnectFromAp() {
    setState(() {
      _isConnected = false;
      _appStep = 0; // Back to Wi-Fi AP scan
      _selectedDevice = null;
    });
    _startWifiApScan();
  }

  Future<void> _sendApiCommand(String action, String params) async {
    if (!_isConnected) return;

    final ip = _selectedDevice?.defaultIp ?? '192.168.4.1';
    final url = 'http://$ip/$action?$params';

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(milliseconds: 3000),
          receiveTimeout: const Duration(milliseconds: 3000),
          validateStatus: (status) => true,
        ),
      );
      await dio.get(url);
      debugPrint('[IoT] Successfully sent command: $url');
    } catch (e) {
      debugPrint('[IoT Error] Failed to send command to NodeMCU: $e');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.paperplane_fill,
                color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'بروزرسانی صفحه OLED: $url',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  color: Colors.white,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _setPageNumber(int page) {
    if (page < 1) page = 1;
    if (page > 604) page = 604;
    setState(() {
      _currentPageNumber = page;
      _pageInputController.text = page.toString();
    });
    _sendApiCommand('set_page', 'page=$page');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageInputController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Pure light background
      ),
      child: Scaffold(
        appBar: IslamicKatibahAppBar(
          surahName: _appStep == 0
              ? 'جستجوی دستگاه (SoftAP)'
              : 'مدیریت دستگاه NodeMCU',
          fontFamily: AppTypography.fontFamily,
          showSearchField: false,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _appStep == 0
                ? _buildWhiteGreenDiscoveryStep()
                : _buildWhiteGreenDashboardStep(),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // STEP 1: WHITE & EMERALD GREEN WI-FI DISCOVERY SCREEN
  // =========================================================
  Widget _buildWhiteGreenDiscoveryStep() {
    return SingleChildScrollView(
      key: const ValueKey('white_green_discovery_step'),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Banner Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.radiowaves_left, size: 16, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'اتصال مستقیم وای‌فای (NodeMCU Access Point)',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Animated Radar Visual (Emerald Green Theme)
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isScanning)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 130 * _pulseAnimation.value,
                        height: 130 * _pulseAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(
                            alpha: (1.45 - _pulseAnimation.value).clamp(0.0, 0.3),
                          ),
                        ),
                      );
                    },
                  ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: const Icon(
                    CupertinoIcons.wifi,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Scan Header Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isScanning
                        ? 'در حال اسکن دستگاه‌های قرآنی...'
                        : 'دستگاه‌های یافت‌شده (${_discoveredDevices.length})',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'دستگاه NodeMCU مورد نظر را انتخاب و متصل شوید',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              IconButton.filledTonal(
                onPressed: _isScanning ? null : _startWifiApScan,
                icon: const Icon(CupertinoIcons.refresh, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                ),
                tooltip: 'اسکن مجدد',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Discovered Devices List
          if (_isScanning)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: const Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'در حال جستجوی سیگنال‌های NodeMCU SoftAP...',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            )
          else if (_discoveredDevices.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Column(
                children: [
                  Icon(CupertinoIcons.wifi_slash, size: 36, color: Colors.orange),
                  SizedBox(height: 10),
                  Text(
                    'هیچ دستگاهی پیدا نشد',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'از روشن بودن NodeMCU و پخش سیگنال وای‌فای مطمئن شوید.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _discoveredDevices.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final device = _discoveredDevices[i];
                final isSelected =
                    _selectedDevice?.macAddress == device.macAddress;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.15),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Wifi Signal Circle
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.wifi,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Device Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device.ssid,
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  'سیگنال ${device.signalStrength}%',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                Text(
                                  ' • IP: ${device.defaultIp}',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Action Button
                      isSelected && _isConnectingToAp
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: AppColors.primary,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _isConnectingToAp
                                  ? null
                                  : () => _showPasswordDialog(device),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'اتصال',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // =========================================================
  // STEP 2: WHITE & EMERALD GREEN CONNECTED DASHBOARD
  // =========================================================
  Widget _buildWhiteGreenDashboardStep() {
    return SingleChildScrollView(
      key: const ValueKey('white_green_dashboard_step'),
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Active Connection Pill Banner ---
          _buildWhiteGreenStatusBanner(),

          const SizedBox(height: 18),

          // --- Page Selection & Quick Stepper Card ---
          _buildWhiteGreenPageSelector(),

          const SizedBox(height: 18),

          // --- Sleek OLED Preview Display ---
          _buildWhiteGreenOledPreview(),

          const SizedBox(height: 18),

          // --- Hardware Controls Panel ---
          _buildWhiteGreenDeviceControls(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWhiteGreenStatusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.checkmark_alt,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'متصل به ${_selectedDevice?.ssid ?? 'NodeMCU'}',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'IP: ${_selectedDevice?.defaultIp ?? '192.168.4.1'} • آماده دریافت دستورات',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _disconnectFromAp,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                'قطع اتصال',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteGreenPageSelector() {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.book_fill,
                  color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'انتخاب صفحه قرآن (۱ تا ۶۰۴)',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stepper + TextField Row
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () => _setPageNumber(_currentPageNumber - 1),
                icon: const Icon(CupertinoIcons.minus, size: 18),
                tooltip: 'صفحه قبلی',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _pageInputController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    hintText: '۱ تا ۶۰۴',
                    suffixText: 'از ۶۰۴',
                    suffixStyle: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (val) {
                    final p = int.tryParse(val);
                    if (p != null) {
                      final validPage = p.clamp(1, 604);
                      setState(() {
                        _currentPageNumber = validPage;
                      });
                      _debounceTimer?.cancel();
                      _debounceTimer = Timer(const Duration(milliseconds: 350), () {
                        _sendApiCommand('set_page', 'page=$validPage');
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: () => _setPageNumber(_currentPageNumber + 1),
                icon: const Icon(CupertinoIcons.add, size: 18),
                tooltip: 'صفحه بعدی',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Quick Jump Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildQuickJumpChip('صفحه ۱ (الفاتحة)', 1),
                const SizedBox(width: 8),
                _buildQuickJumpChip('صفحه ۵۰', 50),
                const SizedBox(width: 8),
                _buildQuickJumpChip('صفحه ۲۰۰', 200),
                const SizedBox(width: 8),
                _buildQuickJumpChip('صفحه ۶۰۴ (الناس)', 604),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickJumpChip(String label, int page) {
    final isSelected = _currentPageNumber == page;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.primary,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: const Color(0xFFF1F5F9),
      onSelected: (_) => _setPageNumber(page),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildWhiteGreenOledPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isOledOn ? AppColors.primary : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'نمایشگر 0.96" OLED سخت‌افزار',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                _selectedDisplayMode == 0 ? 'مد: QR Code' : 'مد: شماره صفحه',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  color: Colors.black54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Screen Content Glass Box (Hardware OLED Dark Center)
          Container(
            width: 210,
            height: 130,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A), // Hardware OLED black screen
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isOledOn ? Colors.cyanAccent.withValues(alpha: 0.8) : Colors.white10,
                width: 1.2,
              ),
            ),
            child: !_isOledOn
                ? const Center(
                    child: Text(
                      '[ صفحه خاموش است ]',
                      style: TextStyle(color: Colors.grey, fontFamily: AppTypography.fontFamily, fontSize: 11),
                    ),
                  )
                : _selectedDisplayMode == 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.qrcode, color: Colors.cyanAccent, size: 54),
                          const SizedBox(height: 6),
                          Text(
                            'QR صفحه $_currentPageNumber',
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppTypography.fontFamily,
                            ),
                          ),
                          Text(
                            'quran://page/$_currentPageNumber',
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'صفحه $_currentPageNumber',
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppTypography.fontFamily,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'قرآن کریم - عثمان طه',
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 10,
                              fontFamily: AppTypography.fontFamily,
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteGreenDeviceControls() {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.slider_horizontal_3,
                  color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'تنظیمات سخت‌افزار',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // OLED Power Switch (Custom Row)
          Row(
            children: [
              Icon(
                CupertinoIcons.power,
                color: _isOledOn ? AppColors.primary : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'صفحه نمایش OLED',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _isOledOn ? 'صفحه روشن است' : 'صفحه خاموش است',
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isOledOn,
                onChanged: (val) {
                  setState(() {
                    _isOledOn = val;
                  });
                  _sendApiCommand('power', 'state=${val ? 1 : 0}');
                },
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
          const Divider(height: 16),

          // Brightness Slider
          Row(
            children: [
              const Icon(CupertinoIcons.sun_max, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'میزان روشنایی OLED:',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '${_oledBrightness.round()}%',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: _oledBrightness,
            min: 0,
            max: 100,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withValues(alpha: 0.15),
            onChanged: (val) {
              setState(() {
                _oledBrightness = val;
              });
            },
            onChangeEnd: (val) {
              _sendApiCommand('brightness', 'value=${val.round()}');
            },
          ),
          const Divider(height: 16),

          // Mode Selector
          const Text(
            'حالت نمایش OLED:',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('QR + شماره صفحه',
                      style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 10)),
                  icon: Icon(CupertinoIcons.qrcode, size: 15),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('فقط شماره صفحه',
                      style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 10)),
                  icon: Icon(CupertinoIcons.doc_text, size: 15),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text('QR کد دوقلو',
                      style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 10)),
                  icon: Icon(CupertinoIcons.qrcode_viewfinder, size: 15),
                ),
              ],
              selected: {_selectedDisplayMode},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary.withValues(alpha: 0.15);
                  }
                  return Colors.transparent;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary;
                  }
                  return Colors.black87;
                }),
              ),
              onSelectionChanged: (set) {
                setState(() {
                  _selectedDisplayMode = set.first;
                });
                _sendApiCommand('mode', 'mode=${set.first}');
              },
            ),
          ),
          const Divider(height: 24),

          // Reboot Hardware Board Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Row(
                        children: [
                          Icon(CupertinoIcons.restart, color: Colors.orange, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'راه‌اندازی مجدد NodeMCU',
                            style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      content: const Text(
                        'آیا از ریست و راه‌اندازی مجدد نرم‌افزاری برد NodeMCU مطمئن هستید؟',
                        style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('انصراف', style: TextStyle(fontFamily: AppTypography.fontFamily, color: Colors.grey)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _sendApiCommand('reboot', '');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('ریست برد', style: TextStyle(fontFamily: AppTypography.fontFamily)),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(CupertinoIcons.restart, size: 18, color: Colors.orange),
              label: const Text(
                'راه‌اندازی مجدد (Reboot) برد',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.orange.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
