import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/di_container.dart' as di;
import 'package:sixvalley_vendor_app/features/more/screens/html_view_screen.dart';
import 'package:sixvalley_vendor_app/features/order/screens/select_location_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/business_pages_model.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:url_launcher/url_launcher.dart';

enum _MerchantFlowStage {
  registration,
  otp,
  onboarding,
  status,
}

class MerchantOnboardingScreen extends StatefulWidget {
  const MerchantOnboardingScreen({super.key});

  @override
  State<MerchantOnboardingScreen> createState() =>
      _MerchantOnboardingScreenState();
}

class _MerchantOnboardingScreenState extends State<MerchantOnboardingScreen> {
  static const _onboardingTokenKey = 'merchant_onboarding_access_token';
  static const _onboardingRefreshTokenKey = 'merchant_onboarding_refresh_token';
  static const _secureStorage = FlutterSecureStorage();

  // State Management
  _MerchantFlowStage _stage = _MerchantFlowStage.registration;
  int _onboardingStep = 1; // 1: Store info, 2: Identity, 3: Location, 4: Review

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _storeDescController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  final Dio _dio = di.sl<DioClient>().dio!;
  final _picker = ImagePicker();

  bool _loading = false;
  String? _challengeId;
  String? _token;
  String? _refreshToken;

  // Onboarding Data & Status
  String _approvalStatus = 'pending_approval';
  String? _approvalNote;
  bool _locationComplete = false;
  String? _locationLabel;
  double? _latitude;
  double? _longitude;
  String? _uploadedDocName;
  bool _docUploaded = false;
  List<dynamic> _documents = [];

  // UI state toggles
  bool _termsAccepted = false;
  bool _showPassword = false;
  Timer? _otpTimer;
  int _otpSeconds = 0;

  @override
  void initState() {
    super.initState();
    _restoreOnboardingSession();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeDescController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _otpTimer?.cancel();
    super.dispose();
  }

  // --- Session & Backend Operations ---

  Future<void> _restoreOnboardingSession() async {
    String? token;
    String? refreshToken;

    try {
      token = await _secureStorage.read(key: _onboardingTokenKey);
      refreshToken = await _secureStorage.read(key: _onboardingRefreshTokenKey);
    } catch (_) {
      // Graceful fallback on platform secure storage read failure
    }

    // Legacy migration: read legacy plaintext tokens from SharedPreferences if missing in secure storage
    if ((token == null || token.isEmpty) &&
        (refreshToken == null || refreshToken.isEmpty)) {
      try {
        final preferences = await SharedPreferences.getInstance();
        final legacyToken = preferences.getString(_onboardingTokenKey);
        final legacyRefreshToken = preferences.getString(_onboardingRefreshTokenKey);

        if (legacyToken != null && legacyToken.isNotEmpty) {
          token = legacyToken;
          await _secureStorage.write(key: _onboardingTokenKey, value: legacyToken);
          await preferences.remove(_onboardingTokenKey);
        }
        if (legacyRefreshToken != null && legacyRefreshToken.isNotEmpty) {
          refreshToken = legacyRefreshToken;
          await _secureStorage.write(key: _onboardingRefreshTokenKey, value: legacyRefreshToken);
          await preferences.remove(_onboardingRefreshTokenKey);
        }
      } catch (_) {}
    } else {
      // If tokens already exist in secure storage, purge any legacy plaintext tokens from SharedPreferences
      try {
        final preferences = await SharedPreferences.getInstance();
        await preferences.remove(_onboardingTokenKey);
        await preferences.remove(_onboardingRefreshTokenKey);
      } catch (_) {}
    }

    if ((token == null || token.isEmpty) &&
            (refreshToken == null || refreshToken.isEmpty) ||
        !mounted) {
      return;
    }
    setState(() {
      _token = token;
      _refreshToken = refreshToken;
    });
    await _loadOnboardingStatus();
  }

  Options get _identityOptions =>
      Options(headers: {'Authorization': 'Bearer $_token'});

  Future<void> _loadOnboardingStatus({bool allowRefresh = true}) async {
    if (_token == null && !await _refreshOnboardingSession()) return;
    setState(() => _loading = true);
    try {
      final response = await _dio.get(
        '/api/v4/identity/merchant/onboarding/status',
        options: _identityOptions,
      );
      if (!mounted) return;
      final data = response.data;
      setState(() {
        _approvalStatus = data['approval_status']?.toString() ?? 'pending_approval';
        _approvalNote = data['approval_note']?.toString();
        _locationComplete = data['shop_location_complete'] == true;
        _locationLabel = _locationComplete ? 'تم تحديد موقع المتجر' : null;
        _documents = List<dynamic>.from(data['documents'] ?? []);

        for (final item in _documents) {
          if (item is Map && item['document_type'] == 'identity') {
            _docUploaded = true;
            _uploadedDocName = 'وثيقة الهوية الرسمية';
            break;
          }
        }

        // Determine destination stage
        if (_approvalStatus == 'active' ||
            _approvalStatus == 'approved' ||
            _approvalStatus == 'rejected' ||
            _approvalStatus == 'suspended' ||
            _approvalStatus == 'changes_requested') {
          _stage = _MerchantFlowStage.status;
        } else if (_docUploaded && _locationComplete) {
          _stage = _MerchantFlowStage.status;
        } else {
          _stage = _MerchantFlowStage.onboarding;
          _onboardingStep = !_docUploaded ? 2 : (!_locationComplete ? 3 : 4);
        }
      });
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        if (allowRefresh && await _refreshOnboardingSession()) {
          await _loadOnboardingStatus(allowRefresh: false);
        } else {
          await _clearOnboardingSession();
        }
      } else if (error.response?.statusCode == 403) {
        final msg = error.response?.data is Map ? error.response?.data['message']?.toString() : null;
        setState(() {
          _approvalStatus = 'suspended';
          _approvalNote = msg ?? 'هذا الحساب موقوف أو غير مصرح له بالدخول.';
          _stage = _MerchantFlowStage.status;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _refreshOnboardingSession() async {
    if (_refreshToken == null || _refreshToken!.isEmpty) return false;
    try {
      final response = await _dio.post(
        '/api/v4/identity/session/refresh',
        data: {'refresh_token': _refreshToken},
      );
      final token = response.data['access_token']?.toString();
      final refreshToken = response.data['refresh_token']?.toString();
      if (token == null || token.isEmpty || refreshToken == null || refreshToken.isEmpty) {
        return false;
      }
      await _secureStorage.write(key: _onboardingTokenKey, value: token);
      await _secureStorage.write(key: _onboardingRefreshTokenKey, value: refreshToken);
      try {
        final preferences = await SharedPreferences.getInstance();
        await preferences.remove(_onboardingTokenKey);
        await preferences.remove(_onboardingRefreshTokenKey);
      } catch (_) {}
      if (mounted) {
        setState(() {
          _token = token;
          _refreshToken = refreshToken;
        });
      }
      return true;
    } on DioException {
      return false;
    }
  }

  Future<void> _clearOnboardingSession() async {
    try {
      await _secureStorage.delete(key: _onboardingTokenKey);
      await _secureStorage.delete(key: _onboardingRefreshTokenKey);
    } catch (_) {}
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_onboardingTokenKey);
      await preferences.remove(_onboardingRefreshTokenKey);
    } catch (_) {}
    if (mounted) {
      setState(() {
        _token = null;
        _refreshToken = null;
        _stage = _MerchantFlowStage.registration;
        _challengeId = null;
      });
    }
  }

  // --- Registration & OTP Calls ---

  Future<void> _startRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      _showMessage('يرجى الموافقة على شروط الاستخدام وسياسة الخصوصية للمتابعة.', error: true);
      return;
    }

    setState(() => _loading = true);
    final phone = _phoneController.text.trim();
    final formattedPhone = phone.startsWith('+967') ? phone : (phone.startsWith('967') ? '+$phone' : '+967$phone');

    try {
      final response = await _dio.post(
        '/api/v4/identity/merchant/registration/start',
        data: {
          'store_name': _storeNameController.text.trim(),
          'phone': formattedPhone,
          'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          'password': _passwordController.text,
          'password_confirmation': _passwordController.text, // Backend rule requires confirmed
        },
      );
      if (!mounted) return;
      setState(() {
        _challengeId = response.data['challenge_id']?.toString();
        _stage = _MerchantFlowStage.otp;
      });
      _startOtpTimer();
      _showMessage('تم إرسال رمز التحقق إلى هاتفك عبر رسالة نصية/واتساب.');
    } on DioException catch (error) {
      _showMessage(_errorText(error), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      _showMessage('أدخل رمز التحقق المكون من 6 أرقام.', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final response = await _dio.post(
        '/api/v4/identity/merchant/registration/verify',
        data: {
          'challenge_id': _challengeId,
          'otp': _otpController.text.trim(),
        },
      );

      final session = response.data['session'] ?? response.data;
      final token = session['access_token']?.toString();
      final refreshToken = session['refresh_token']?.toString();

      if (token == null || token.isEmpty || refreshToken == null || refreshToken.isEmpty) {
        throw StateError('Missing onboarding session.');
      }

      await _secureStorage.write(key: _onboardingTokenKey, value: token);
      await _secureStorage.write(key: _onboardingRefreshTokenKey, value: refreshToken);
      try {
        final preferences = await SharedPreferences.getInstance();
        await preferences.remove(_onboardingTokenKey);
        await preferences.remove(_onboardingRefreshTokenKey);
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _token = token;
        _refreshToken = refreshToken;
        _stage = _MerchantFlowStage.onboarding;
        _onboardingStep = 1;
      });

      await _loadOnboardingStatus();
      _showMessage('تم إنشاء حسابك بنجاح. أكمل خطوات توثيق المتجر.');
    } on DioException catch (error) {
      _showMessage(_errorText(error), error: true);
    } catch (_) {
      _showMessage('تعذر حفظ جلسة التسجيل. يرجى المحاولة مرة أخرى.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    setState(() => _otpSeconds = 120);
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      if (_otpSeconds <= 1) {
        timer.cancel();
        setState(() => _otpSeconds = 0);
      } else {
        setState(() => _otpSeconds--);
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_otpSeconds > 0 || _loading) return;
    await _startRegistration();
  }

  // --- Step 2: Document Upload ---

  Future<void> _uploadIdentity() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() => _loading = true);
    try {
      await _dio.post(
        '/api/v4/identity/merchant/onboarding/documents',
        data: FormData.fromMap({
          'document_type': 'identity',
          'document': await MultipartFile.fromFile(file.path, filename: file.name),
        }),
        options: _identityOptions,
      );
      if (!mounted) return;
      setState(() {
        _uploadedDocName = file.name;
        _docUploaded = true;
      });
      await _loadOnboardingStatus();
      _showMessage('تم رفع وثيقة الهوية بنجاح للمراجعة.');
    } on DioException catch (error) {
      _showMessage(_errorText(error), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- Step 3: Location Operations ---

  Future<void> _useCurrentLocation() async {
    setState(() => _loading = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('خدمة الموقع الجغرافي (GPS) غير مفعلة.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw StateError('يلزم السماح بالوصول إلى الموقع لمتابعة التسجيل.');
      }
      final position = await Geolocator.getCurrentPosition();
      final lat = position.latitude;
      final lon = position.longitude;

      await _dio.put(
        '/api/v4/identity/merchant/onboarding/location',
        data: {
          'latitude': lat,
          'longitude': lon,
          'address': 'تم التحديد عبر GPS (${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)})',
        },
        options: _identityOptions,
      );

      if (!mounted) return;
      setState(() {
        _latitude = lat;
        _longitude = lon;
        _locationComplete = true;
        _locationLabel = 'الموقع الحالي عبر GPS';
      });
      await _loadOnboardingStatus();
      _showMessage('تم حفظ موقع المتجر بنجاح.');
    } on DioException catch (error) {
      _showMessage(_errorText(error), error: true);
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Bad state: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectLocationOnMap() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectLocationScreen(
          googleMapController: null,
          onLocationSelected: (latitude, longitude, address) async {
            if (latitude == 0 && longitude == 0) return;
            setState(() => _loading = true);
            try {
              final finalAddress = (address != null && address.trim().isNotEmpty)
                  ? address.trim()
                  : 'موقع محدد على الخريطة (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})';

              await _dio.put(
                '/api/v4/identity/merchant/onboarding/location',
                data: {
                  'latitude': latitude,
                  'longitude': longitude,
                  'address': finalAddress,
                },
                options: _identityOptions,
              );
              if (!mounted) return;
              setState(() {
                _latitude = latitude;
                _longitude = longitude;
                _locationComplete = true;
                _locationLabel = finalAddress;
              });
              await _loadOnboardingStatus();
              _showMessage('تم تحديد وتحديث موقع المتجر.');
            } on DioException catch (error) {
              _showMessage(_errorText(error), error: true);
            } finally {
              if (mounted) setState(() => _loading = false);
            }
          },
        ),
      ),
    );
  }

  // --- Step 4: Submission ---

  Future<void> _submitOnboardingForReview() async {
    setState(() => _loading = true);
    try {
      await _loadOnboardingStatus();
      if (!mounted) return;
      setState(() {
        _stage = _MerchantFlowStage.status;
      });
      _showMessage('تم إرسال طلب انضمام متجرك للمراجعة بنجاح!');
    } catch (_) {
      _showMessage('حدث خطأ أثناء إرسال الطلب، يرجى المحاولة مجددًا.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- Helpers & Utilities ---

  String _maskedPhone() {
    final phone = _phoneController.text.trim();
    if (phone.length < 7) return phone;
    return '+967 ${phone.substring(0, 2)} *** ${phone.substring(phone.length - 2)}';
  }

  String _errorText(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      return data['message']?.toString() ?? 'تعذر إتمام الطلب، تحقق من المدخلات.';
    }
    return 'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت.';
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: error ? AllineColors.error : AllineColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openBusinessPage(String slug) {
    final splash = Provider.of<SplashController>(context, listen: false);
    final page = _pageBySlug(slug, splash.defaultBusinessPages);
    if (page != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => HtmlViewScreen(page: page)),
      );
    }
  }

  BusinessPageModel? _pageBySlug(String slug, List<BusinessPageModel>? pages) {
    for (final page in pages ?? <BusinessPageModel>[]) {
      if (page.slug == slug) return page;
    }
    return null;
  }

  Future<void> _openWhatsAppSupport() async {
    const phone = '967775667733';
    final message = 'مرحبًا، لدي استفسار بخصوص طلب انضمام متجري (${_storeNameController.text.trim()}) على منصة Alline.';
    final appUri = Uri.parse('whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}');
    final webUri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    if (!await launchUrl(appUri, mode: LaunchMode.externalApplication)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : AllineColors.softBlue;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: _buildAppBar(context, isDark),
        body: SafeArea(
          child: _loading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AllineColors.primary),
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: _buildCurrentStageView(context, isDark),
                ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    String title = 'إنشاء حساب مورد';
    if (_stage == _MerchantFlowStage.otp) {
      title = 'التحقق من رقم الهاتف';
    } else if (_stage == _MerchantFlowStage.onboarding) {
      title = 'إكمال بيانات المتجر';
    } else if (_stage == _MerchantFlowStage.status) {
      title = 'حالة اعتماد المتجر';
    }

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: isDark ? Colors.white : AllineColors.navyText,
        ),
        onPressed: () {
          if (_stage == _MerchantFlowStage.otp) {
            setState(() => _stage = _MerchantFlowStage.registration);
          } else if (_stage == _MerchantFlowStage.onboarding && _onboardingStep > 1) {
            setState(() => _onboardingStep--);
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AllineColors.navyText,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }

  Widget _buildCurrentStageView(BuildContext context, bool isDark) {
    switch (_stage) {
      case _MerchantFlowStage.registration:
        return _buildRegistrationView(context, isDark);
      case _MerchantFlowStage.otp:
        return _buildOtpView(context, isDark);
      case _MerchantFlowStage.onboarding:
        return _buildOnboardingStepperView(context, isDark);
      case _MerchantFlowStage.status:
        return _buildStatusView(context, isDark);
    }
  }

  // ==========================================
  // STAGE 1: REGISTRATION VIEW
  // ==========================================

  Widget _buildRegistrationView(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : AllineColors.border;
    final primaryTextColor = isDark ? Colors.white : AllineColors.navyText;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AllineColors.coolGray;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AllineColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: AllineColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إنشاء حساب مورد',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'أنشئ حساب متجرك وابدأ خطوات الانضمام إلى Alline.',
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Store Name Field
          _buildInputLabel('اسم المتجر', isRequired: true, isDark: isDark),
          const SizedBox(height: 6),
          TextFormField(
            controller: _storeNameController,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText: 'أدخل اسم المتجر',
              prefixIcon: Icons.store_outlined,
              isDark: isDark,
            ),
            validator: (value) {
              if (value == null || value.trim().length < 2) {
                return 'اسم المتجر يجب أن يكون حرفين على الأقل.';
              }
              if (value.trim().length > 255) {
                return 'اسم المتجر طويل جداً.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone Number Field (+967 Yemen)
          _buildInputLabel('رقم الهاتف', isRequired: true, isDark: isDark),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText: '7XXXXXXXX',
              prefixIcon: Icons.phone_android_rounded,
              isDark: isDark,
              prefixWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsetsDirectional.only(end: 10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: borderColor),
                  ),
                ),
                child: Text(
                  '+967',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AllineColors.navyText,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'رقم الهاتف مطلوب.';
              }
              final clean = value.replaceAll(RegExp(r'\D'), '');
              if (clean.length < 9) {
                return 'رقم الهاتف يجب أن يتكون من 9 أرقام (مثال: 777123456).';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Field
          _buildInputLabel('كلمة المرور', isRequired: true, isDark: isDark),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText: 'أدخل كلمة المرور (8 خانات على الأقل)',
              prefixIcon: Icons.lock_outline_rounded,
              isDark: isDark,
              suffixWidget: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: secondaryTextColor,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'كلمة المرور يجب أن لا تقل عن 8 خانات.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email Field (Optional)
          _buildInputLabel('البريد الإلكتروني', isRequired: false, isDark: isDark),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            textInputAction: TextInputAction.done,
            decoration: _inputDecoration(
              hintText: 'example@email.com',
              prefixIcon: Icons.email_outlined,
              isDark: isDark,
            ),
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
                  return 'صيغة البريد الإلكتروني غير صحيحة.';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Terms and Privacy Checkbox
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: _termsAccepted,
                  activeColor: AllineColors.primary,
                  onChanged: (val) => setState(() => _termsAccepted = val ?? false),
                ),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'أوافق على ',
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryTextColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openBusinessPage('terms-and-conditions'),
                        child: const Text(
                          'شروط الاستخدام',
                          style: TextStyle(
                            fontSize: 13,
                            color: AllineColors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                      Text(
                        ' و ',
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryTextColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openBusinessPage('privacy-policy'),
                        child: const Text(
                          'سياسة الخصوصية',
                          style: TextStyle(
                            fontSize: 13,
                            color: AllineColors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Primary CTA Button
          ElevatedButton(
            onPressed: (!_termsAccepted || _loading) ? null : _startRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: AllineColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: AllineColors.primary.withValues(alpha: 0.4),
            ),
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'إرسال رمز التحقق',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
          ),
          const SizedBox(height: 18),

          // Link to Login
          Center(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, fontFamily: 'Tajawal', color: primaryTextColor),
                    children: const [
                      TextSpan(text: 'لديك حساب بالفعل؟ '),
                      TextSpan(
                        text: 'تسجيل الدخول',
                        style: TextStyle(
                          color: AllineColors.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STAGE 2: OTP VIEW
  // ==========================================

  Widget _buildOtpView(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : AllineColors.border;
    final primaryTextColor = isDark ? Colors.white : AllineColors.navyText;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AllineColors.coolGray;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // OTP Hero Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AllineColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  color: AllineColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'التحقق من رقم الهاتف',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'أدخل رمز التحقق المكون من 6 أرقام المرسل إلى:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _maskedPhone(),
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Pin Code Text Field
        Directionality(
          textDirection: TextDirection.ltr,
          child: PinCodeTextField(
            appContext: context,
            length: 6,
            controller: _otpController,
            autoDisposeControllers: false,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enableActiveFill: true,
            autoFocus: true,
            onChanged: (_) {},
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(12),
              fieldHeight: 52,
              fieldWidth: 44,
              activeColor: AllineColors.primary,
              selectedColor: AllineColors.primary,
              inactiveColor: borderColor,
              activeFillColor: cardBg,
              selectedFillColor: cardBg,
              inactiveFillColor: cardBg,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Verify CTA
        ElevatedButton(
          onPressed: _loading ? null : _verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: AllineColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'تحقق',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Resend Timer & Button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: (_otpSeconds == 0 && !_loading) ? _resendOtp : null,
              icon: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: _otpSeconds == 0 ? AllineColors.primary : secondaryTextColor,
              ),
              label: Text(
                _otpSeconds > 0
                    ? 'إعادة الإرسال بعد $_otpSeconds ثانية'
                    : 'إعادة إرسال الرمز',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  color: _otpSeconds == 0 ? AllineColors.primary : secondaryTextColor,
                ),
              ),
            ),
          ],
        ),

        // Change Phone Number Button
        Center(
          child: TextButton(
            onPressed: () {
              setState(() => _stage = _MerchantFlowStage.registration);
            },
            child: const Text(
              'تغيير رقم الهاتف',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: AllineColors.coolGray,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STAGE 3: MULTI-STEP ONBOARDING
  // ==========================================

  Widget _buildOnboardingStepperView(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stepper Progress Header
        _buildStepperHeader(context, isDark),
        const SizedBox(height: 20),

        // Active Step Content
        if (_onboardingStep == 1) _buildStep1StoreInfo(context, isDark),
        if (_onboardingStep == 2) _buildStep2Identity(context, isDark),
        if (_onboardingStep == 3) _buildStep3Location(context, isDark),
        if (_onboardingStep == 4) _buildStep4Review(context, isDark),
      ],
    );
  }

  Widget _buildStepperHeader(BuildContext context, bool isDark) {
    final steps = ['البيانات', 'الهوية', 'الموقع', 'المراجعة'];
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : AllineColors.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (index) {
              final stepNum = index + 1;
              final isPassed = stepNum < _onboardingStep;
              final isCurrent = stepNum == _onboardingStep;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isPassed
                            ? AllineColors.success
                            : (isCurrent ? AllineColors.primary : Colors.transparent),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (isPassed || isCurrent) ? Colors.transparent : borderColor,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: isPassed
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '$stepNum',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent ? Colors.white : AllineColors.coolGray,
                                ),
                              ),
                      ),
                    ),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isPassed ? AllineColors.success : borderColor,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final isCurrent = index + 1 == _onboardingStep;
              return Text(
                steps[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? AllineColors.primary : AllineColors.coolGray,
                  fontFamily: 'Tajawal',
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- Step 1: Store Information ---

  Widget _buildStep1StoreInfo(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : AllineColors.border;
    final primaryTextColor = isDark ? Colors.white : AllineColors.navyText;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AllineColors.coolGray;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الخطوة 1: بيانات المتجر الأساسية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'تأكد من صحة اسم المتجر ونبذة مختصرة عن نشاطك التجاري.',
            style: TextStyle(fontSize: 13, color: secondaryTextColor, fontFamily: 'Tajawal'),
          ),
          const SizedBox(height: 18),

          _buildInputLabel('اسم المتجر', isRequired: true, isDark: isDark),
          const SizedBox(height: 6),
          TextFormField(
            controller: _storeNameController,
            decoration: _inputDecoration(
              hintText: 'اسم المتجر التجاري',
              prefixIcon: Icons.storefront_outlined,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 14),

          _buildInputLabel('وصف المتجر (اختياري)', isRequired: false, isDark: isDark),
          const SizedBox(height: 6),
          TextFormField(
            controller: _storeDescController,
            maxLines: 3,
            decoration: _inputDecoration(
              hintText: 'اكتب نبذة مختصرة عن البضائع والمنتجات التي تبيعها...',
              prefixIcon: Icons.description_outlined,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_storeNameController.text.trim().isEmpty) {
                  _showMessage('يرجى إدخال اسم المتجر للمتابعة.', error: true);
                  return;
                }
                setState(() => _onboardingStep = 2);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AllineColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('التالي: توثيق الهوية', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 2: Identity Document ---

  Widget _buildStep2Identity(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : AllineColors.border;
    final primaryTextColor = isDark ? Colors.white : AllineColors.navyText;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AllineColors.coolGray;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الخطوة 2: توثيق الهوية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ارفع مستند الهوية المطلوب (بطاقة شخصية، جواز سفر، أو سجل تجاري) لإتمام مراجعة طلب المورد.',
            style: TextStyle(fontSize: 13, color: secondaryTextColor, fontFamily: 'Tajawal'),
          ),
          const SizedBox(height: 20),

          // Upload Card with all states
          InkWell(
            onTap: _loading ? null : _uploadIdentity,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: _docUploaded
                    ? AllineColors.success.withValues(alpha: 0.08)
                    : (isDark ? const Color(0xFF111827) : AllineColors.softBlue),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _docUploaded ? AllineColors.success : AllineColors.primary,
                  style: _docUploaded ? BorderStyle.solid : BorderStyle.none,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _docUploaded ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                    size: 48,
                    color: _docUploaded ? AllineColors.success : AllineColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _docUploaded ? 'تم رفع وثيقة الهوية بنجاح' : 'اضغط هنا لرفع وثيقة الهوية',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _docUploaded ? AllineColors.success : primaryTextColor,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _uploadedDocName ?? 'الصيغ المدعومة: JPG, PNG, PDF (أقصى حجم 5 ميجابايت)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  if (_docUploaded) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _uploadIdentity,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('استبدال الوثيقة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AllineColors.primary,
                        side: const BorderSide(color: AllineColors.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _onboardingStep = 1),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('السابق', style: TextStyle(fontFamily: 'Tajawal')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: !_docUploaded ? null : () => setState(() => _onboardingStep = 3),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllineColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('التالي: موقع المتجر', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Step 3: Store Location ---

  Widget _buildStep3Location(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : AllineColors.border;
    final primaryTextColor = isDark ? Colors.white : AllineColors.navyText;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AllineColors.coolGray;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الخطوة 3: موقع المتجر الجغرافي',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'حدد موقع متجرك الفعلي لمساعدتنا في ربط خدمات التوصيل وتوجيه العملاء.',
            style: TextStyle(fontSize: 13, color: secondaryTextColor, fontFamily: 'Tajawal'),
          ),
          const SizedBox(height: 20),

          // Option 1: Current GPS
          InkWell(
            onTap: _loading ? null : _useCurrentLocation,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : AllineColors.softBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AllineColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.my_location_rounded, color: AllineColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'استخدام موقعي الحالي',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: primaryTextColor,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        Text(
                          'التقاط الإحداثيات مباشرة عبر GPS',
                          style: TextStyle(fontSize: 12, color: secondaryTextColor, fontFamily: 'Tajawal'),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AllineColors.coolGray),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Option 2: Select on Map
          InkWell(
            onTap: _loading ? null : _selectLocationOnMap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : AllineColors.softBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AllineColors.orange.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.map_outlined, color: AllineColors.orange),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تحديد الموقع على الخريطة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: primaryTextColor,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        Text(
                          'اختيار نقطة المتجر بدقة على خريطة صنعاء/اليمن',
                          style: TextStyle(fontSize: 12, color: secondaryTextColor, fontFamily: 'Tajawal'),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AllineColors.coolGray),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Selected Location Card
          if (_locationComplete) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AllineColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AllineColors.success),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AllineColors.success, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'تم حفظ موقع المتجر بنجاح',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AllineColors.success,
                            fontSize: 13,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        Text(
                          _locationLabel ?? 'الموقع محدد',
                          style: TextStyle(fontSize: 12, color: primaryTextColor, fontFamily: 'Tajawal'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _onboardingStep = 2),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('السابق', style: TextStyle(fontFamily: 'Tajawal')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: !_locationComplete ? null : () => setState(() => _onboardingStep = 4),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllineColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('التالي: مراجعة الطلب', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Step 4: Review & Submit ---

  Widget _buildStep4Review(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : AllineColors.border;
    final primaryTextColor = isDark ? Colors.white : AllineColors.navyText;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AllineColors.coolGray;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الخطوة 4: مراجعة وإرسال الطلب',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'تأكد من اكتمال وصحة البيانات المدخلة قبل إرسال طلبك لفريق مراجعة Alline.',
            style: TextStyle(fontSize: 13, color: secondaryTextColor, fontFamily: 'Tajawal'),
          ),
          const SizedBox(height: 18),

          _buildReviewCard(
            title: 'بيانات المتجر',
            content: _storeNameController.text.trim(),
            subContent: _storeDescController.text.trim().isNotEmpty ? _storeDescController.text.trim() : null,
            icon: Icons.storefront_rounded,
            onEdit: () => setState(() => _onboardingStep = 1),
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _buildReviewCard(
            title: 'رقم الهاتف المسجل',
            content: _maskedPhone(),
            icon: Icons.phone_android_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _buildReviewCard(
            title: 'البريد الإلكتروني',
            content: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : 'غير محدد (اختياري)',
            icon: Icons.email_outlined,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _buildReviewCard(
            title: 'وثيقة الهوية',
            content: _docUploaded ? '✓ تم رفع الوثيقة بنجاح' : 'لم يتم الرفع',
            icon: Icons.badge_outlined,
            onEdit: () => setState(() => _onboardingStep = 2),
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _buildReviewCard(
            title: 'موقع المتجر',
            content: _locationComplete ? (_locationLabel ?? 'تم تحديد الموقع') : 'لم يتم التحديد',
            subContent: (_latitude != null && _longitude != null)
                ? 'الإحداثيات: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'
                : null,
            icon: Icons.location_on_outlined,
            onEdit: () => setState(() => _onboardingStep = 3),
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _onboardingStep = 3),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('السابق', style: TextStyle(fontFamily: 'Tajawal')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitOnboardingForReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllineColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'إرسال طلب التسجيل',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Tajawal'),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String title,
    required String content,
    String? subContent,
    required IconData icon,
    VoidCallback? onEdit,
    required bool isDark,
  }) {
    final borderColor = isDark ? const Color(0xFF374151) : AllineColors.border;
    final primaryTextColor = isDark ? Colors.white : AllineColors.navyText;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AllineColors.coolGray;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : AllineColors.softBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AllineColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 11, color: secondaryTextColor, fontFamily: 'Tajawal')),
                Text(content, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryTextColor, fontFamily: 'Tajawal')),
                if (subContent != null)
                  Text(subContent, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: secondaryTextColor, fontFamily: 'Tajawal')),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: AllineColors.primary),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }

  // ==========================================
  // STAGE 4: STATUS VIEWS (Pending, Rejected, etc.)
  // ==========================================

  Widget _buildStatusView(BuildContext context, bool isDark) {
    if (_approvalStatus == 'active' || _approvalStatus == 'approved') {
      return _buildApprovedStatus(context, isDark);
    } else if (_approvalStatus == 'changes_requested') {
      return _buildChangesRequestedStatus(context, isDark);
    } else if (_approvalStatus == 'rejected') {
      return _buildRejectedStatus(context, isDark);
    } else if (_approvalStatus == 'suspended') {
      return _buildSuspendedStatus(context, isDark);
    } else {
      return _buildPendingApprovalStatus(context, isDark);
    }
  }

  // 1. Pending Approval
  Widget _buildPendingApprovalStatus(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : AllineColors.border;
    final primaryTextColor = isDark ? Colors.white : AllineColors.navyText;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AllineColors.coolGray;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AllineColors.orange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 38,
                  color: AllineColors.orange,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'طلبك قيد المراجعة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'تم استلام بيانات متجرك بنجاح. سيقوم فريق Alline بمراجعة الطلب قبل تفعيل حسابك.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: secondaryTextColor, fontFamily: 'Tajawal'),
              ),
              const SizedBox(height: 24),

              // Status Progression Stepper
              _buildProgressRow('✓ إنشاء الحساب', done: true, isDark: isDark),
              _buildProgressRow('✓ التحقق من الهاتف', done: true, isDark: isDark),
              _buildProgressRow('✓ استكمال بيانات المتجر', done: true, isDark: isDark),
              _buildProgressRow('● مراجعة الطلب من الإدارة', active: true, isDark: isDark),
              _buildProgressRow('○ تفعيل الحساب وبدء البيع', isDark: isDark),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ElevatedButton.icon(
          onPressed: _loading ? null : () => _loadOnboardingStatus(),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('تحديث الحالة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AllineColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),

        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('العودة إلى تسجيل الدخول', style: TextStyle(fontFamily: 'Tajawal')),
        ),
      ],
    );
  }

  // 2. Changes Requested
  Widget _buildChangesRequestedStatus(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : AllineColors.border;
    final primaryTextColor = isDark ? Colors.white : AllineColors.navyText;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AllineColors.coolGray;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AllineColors.orange.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit_note_rounded, size: 36, color: AllineColors.orange),
          ),
          const SizedBox(height: 16),
          Text(
            'مطلوب تعديل بعض البيانات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'طلب فريق المراجعة تعديل الملاحظات أدناه للموافقة على طلب انضمامك.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: secondaryTextColor, fontFamily: 'Tajawal'),
          ),
          const SizedBox(height: 16),

          if (_approvalNote != null && _approvalNote!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : AllineColors.softBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                'ملاحظات الإدارة: $_approvalNote',
                style: TextStyle(fontSize: 13, color: primaryTextColor, fontFamily: 'Tajawal'),
              ),
            ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              setState(() {
                _stage = _MerchantFlowStage.onboarding;
                _onboardingStep = 2; // Jump to identity/location
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AllineColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('تعديل البيانات المطلوبة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 3. Rejected
  Widget _buildRejectedStatus(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : AllineColors.border;
    final primaryTextColor = isDark ? Colors.white : AllineColors.navyText;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AllineColors.coolGray;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AllineColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_outlined, size: 36, color: AllineColors.error),
          ),
          const SizedBox(height: 16),
          Text(
            'تعذر اعتماد طلبك',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _approvalNote ?? 'نعتذر، لم يتم قبول طلب الانضمام لعدم استيفاء الشروط.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: secondaryTextColor, fontFamily: 'Tajawal'),
          ),
          const SizedBox(height: 24),

          OutlinedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await _clearOnboardingSession();
              if (mounted) navigator.pop();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('العودة إلى تسجيل الدخول', style: TextStyle(fontFamily: 'Tajawal')),
          ),
        ],
      ),
    );
  }

  // 4. Approved / Active
  Widget _buildApprovedStatus(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : AllineColors.border;
    final primaryTextColor = isDark ? Colors.white : AllineColors.navyText;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AllineColors.coolGray;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AllineColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, size: 36, color: AllineColors.success),
          ),
          const SizedBox(height: 16),
          Text(
            'تم اعتماد متجرك بنجاح!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تهانينا! أصبح متجرك معتمداً ونشطاً في منصة Alline. يمكنك الآن تسجيل الدخول وإدارة المنتجات والطلبات.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: secondaryTextColor, fontFamily: 'Tajawal'),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await _clearOnboardingSession();
              if (mounted) navigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AllineColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('تسجيل الدخول إلى لوحة التحكم', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 5. Suspended
  Widget _buildSuspendedStatus(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : AllineColors.border;
    final primaryTextColor = isDark ? Colors.white : AllineColors.navyText;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AllineColors.coolGray;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AllineColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_rounded, size: 36, color: AllineColors.error),
          ),
          const SizedBox(height: 16),
          Text(
            'تم تعليق حساب المتجر',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _approvalNote ?? 'تم تعليق هذا المتجر من قبل الإدارة. يرجى مراجعة الدعم الفني.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: secondaryTextColor, fontFamily: 'Tajawal'),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _openWhatsAppSupport,
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('التواصل مع الدعم عبر واتساب', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AllineColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await _clearOnboardingSession();
              if (mounted) navigator.pop();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('العودة إلى تسجيل الدخول', style: TextStyle(fontFamily: 'Tajawal')),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, {bool done = false, bool active = false, required bool isDark}) {
    final primaryTextColor = isDark ? Colors.white : AllineColors.navyText;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AllineColors.coolGray;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : (active ? Icons.radio_button_checked : Icons.radio_button_unchecked),
            size: 18,
            color: done ? AllineColors.success : (active ? AllineColors.orange : secondaryTextColor),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: (done || active) ? FontWeight.bold : FontWeight.normal,
              color: active ? AllineColors.orange : (done ? primaryTextColor : secondaryTextColor),
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  // --- Common Input Decoration ---

  Widget _buildInputLabel(String label, {required bool isRequired, required bool isDark}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AllineColors.navyText,
            fontFamily: 'Tajawal',
          ),
        ),
        if (isRequired)
          const Text(' *', style: TextStyle(color: AllineColors.error, fontWeight: FontWeight.bold)),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    required bool isDark,
    Widget? prefixWidget,
    Widget? suffixWidget,
  }) {
    final borderColor = isDark ? const Color(0xFF374151) : AllineColors.border;
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 13,
        color: isDark ? const Color(0xFF6B7280) : AllineColors.coolGray,
        fontFamily: 'Tajawal',
      ),
      filled: true,
      fillColor: cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      prefixIcon: prefixWidget ?? Icon(prefixIcon, size: 20, color: AllineColors.coolGray),
      suffixIcon: suffixWidget,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AllineColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AllineColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AllineColors.error, width: 1.5),
      ),
    );
  }
}
