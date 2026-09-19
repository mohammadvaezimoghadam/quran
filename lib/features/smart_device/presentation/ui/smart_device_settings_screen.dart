import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../common/widgets/app_modal_header.dart';
import '../../../../common/widgets/app_snackbar.dart';
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
  Color get primaryColor => Theme.of(context).colorScheme.primary;

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
              child: Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppModalHeader(
                        title: 'اتصال به ${device.ssid}',
                        onClose: () => Navigator.pop(dialogCtx),
                        bottomSpacing: 10,
                      ),
                      const Text(
                        'لطفاً رمز عبور اکسس‌پوینت این دستگاه را وارد کنید:',
                        textAlign: TextAlign.center,
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
                          prefixIcon: Icon(CupertinoIcons.lock_fill, color: primaryColor, size: 18),
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
                            borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 1.8),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
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
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
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
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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

      AppSnackBar.showSuccess(
        context,
        'ارتباط با وای‌فای ${device.ssid} برقرار شد (IP: ${device.defaultIp})',
      );
    } else {
      // Show Wi-Fi Connection Warning Dialog with detailed guidance & bypass button
      showDialog(
        context: context,
        builder: (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppModalHeader(
                    title: 'عدم برقراری ارتباط با دستگاه',
                    onClose: () => Navigator.pop(ctx),
                    bottomSpacing: 10,
                  ),
                  const Text(
                    'دلایل متداول عدم برقراری ارتباط با NodeMCU:',
                    style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '۱. وای‌فای گوشی به شبکه Quran_Smart_NodeMCU متصل نیست (رمز: 1234).\n'
                    '۲. دیتا (اینترنت همراه 4G/5G) روشن است و اندروید ترافیک را به اینترنت همراه می‌فرستد. (لطفاً دیتای همراه را موقتا خاموش کنید).\n'
                    '۳. پیام اندروید مبنی بر «وای‌فای اینترنت ندارد، آیا متصل بمانید؟» را تأیید نکرده‌اید.',
                    style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
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
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('تلاش مجدد', style: TextStyle(fontFamily: AppTypography.fontFamily)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
    AppSnackBar.showSuccess(context, 'بروزرسانی صفحه OLED: $url');
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
        scaffoldBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 4.0,
              left: 12.0,
              right: 6.0,
              bottom: 8.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF16191C)
                  : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE5E5EA),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'بازگشت',
                  icon: Icon(
                    CupertinoIcons.chevron_forward,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  splashRadius: 22,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                Expanded(
                  child: Text(
                    _appStep == 0
                        ? 'جستجوی دستگاه (SoftAP)'
                        : 'مدیریت دستگاه NodeMCU',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
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
              color: primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.radiowaves_left, size: 16, color: primaryColor),
                const SizedBox(width: 6),
                Text(
                  'اتصال مستقیم وای‌فای (NodeMCU Access Point)',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
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
                          color: primaryColor.withValues(
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
                      color: primaryColor.withValues(alpha: 0.4),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
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
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
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
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  foregroundColor: primaryColor,
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
              child: Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
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
                          ? primaryColor
                          : primaryColor.withValues(alpha: 0.15),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.05),
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
                          color: primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.wifi,
                          color: primaryColor,
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
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
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
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: primaryColor,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _isConnectingToAp
                                  ? null
                                  : () => _showPasswordDialog(device),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
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
        border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
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
          Row(
            children: [
              Icon(CupertinoIcons.book_fill,
                  color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'انتخاب صفحه قرآن (۱ تا ۶۰۴)',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
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
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  foregroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _pageInputController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
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
                      borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: primaryColor, width: 1.8),
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
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  foregroundColor: primaryColor,
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
          color: isSelected ? Colors.white : primaryColor,
        ),
      ),
      selected: isSelected,
      selectedColor: primaryColor,
      backgroundColor: const Color(0xFFF1F5F9),
      onSelected: (_) => _setPageNumber(page),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? primaryColor : primaryColor.withValues(alpha: 0.2),
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
        border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 1.5),
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
                      color: _isOledOn ? primaryColor : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'نمایشگر 0.96" OLED سخت‌افزار',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      color: primaryColor,
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
        border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
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
          Row(
            children: [
              Icon(CupertinoIcons.slider_horizontal_3,
                  color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'تنظیمات سخت‌افزار',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
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
                color: _isOledOn ? primaryColor : Colors.grey,
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
                activeTrackColor: primaryColor,
              ),
            ],
          ),
          const Divider(height: 16),

          // Brightness Slider
          Row(
            children: [
              Icon(CupertinoIcons.sun_max, size: 18, color: primaryColor),
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
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          Slider(
            value: _oledBrightness,
            min: 0,
            max: 100,
            activeColor: primaryColor,
            inactiveColor: primaryColor.withValues(alpha: 0.15),
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
                    return primaryColor.withValues(alpha: 0.15);
                  }
                  return Colors.transparent;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return primaryColor;
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
                    child: Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppModalHeader(
                              title: 'راه‌اندازی مجدد NodeMCU',
                              onClose: () => Navigator.pop(ctx),
                              bottomSpacing: 12,
                            ),
                            const Text(
                              'آیا از ریست و راه‌اندازی مجدد نرم‌افزاری برد NodeMCU مطمئن هستید؟',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 13, height: 1.5),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('انصراف', style: TextStyle(fontFamily: AppTypography.fontFamily, color: Colors.grey)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
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
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
