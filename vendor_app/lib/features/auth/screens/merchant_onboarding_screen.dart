import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

class MerchantOnboardingScreen extends StatefulWidget {
  const MerchantOnboardingScreen({super.key});

  @override
  State<MerchantOnboardingScreen> createState() =>
      _MerchantOnboardingScreenState();
}

class _MerchantOnboardingScreenState extends State<MerchantOnboardingScreen> {
  static const _onboardingTokenKey = 'merchant_onboarding_access_token';
  static const _onboardingRefreshTokenKey = 'merchant_onboarding_refresh_token';
  final _formKey = GlobalKey<FormState>();
  final _storeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  final _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final _picker = ImagePicker();

  bool _loading = false;
  String? _challengeId;
  String? _token;
  String? _refreshToken;
  String _approvalStatus = 'pending_approval';
  String? _approvalNote;
  bool _locationComplete = false;
  List<dynamic> _documents = [];

  @override
  void initState() {
    super.initState();
    _restoreOnboardingSession();
  }

  @override
  void dispose() {
    _storeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _dio.close();
    super.dispose();
  }

  Future<void> _restoreOnboardingSession() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_onboardingTokenKey);
    final refreshToken = preferences.getString(_onboardingRefreshTokenKey);
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

  Future<void> _startRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final response = await _dio
          .post('/api/v4/identity/merchant/registration/start', data: {
        'store_name': _storeController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
      });
      if (!mounted) return;
      setState(() => _challengeId = response.data['challenge_id']?.toString());
      _showMessage('تم إرسال رمز التحقق إلى رقم الهاتف.');
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
      final response = await _dio
          .post('/api/v4/identity/merchant/registration/verify', data: {
        'challenge_id': _challengeId,
        'otp': _otpController.text.trim(),
      });
      // The identity API returns the token pair directly. Accept a wrapped
      // response as well, so the onboarding session remains compatible with
      // a future API envelope without touching the legacy vendor session.
      final session = response.data['session'] ?? response.data;
      final token = session['access_token']?.toString();
      final refreshToken = session['refresh_token']?.toString();
      if (token == null ||
          token.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        throw StateError('Missing onboarding session.');
      }
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_onboardingTokenKey, token);
      await preferences.setString(_onboardingRefreshTokenKey, refreshToken);
      if (!mounted) return;
      setState(() {
        _token = token;
        _refreshToken = refreshToken;
      });
      await _loadOnboardingStatus();
      _showMessage('تم إنشاء الطلب وهو الآن قيد مراجعة المسؤول.');
    } on DioException catch (error) {
      _showMessage(_errorText(error), error: true);
    } catch (_) {
      _showMessage('تعذر حفظ جلسة التسجيل. أعد المحاولة.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Options get _identityOptions =>
      Options(headers: {'Authorization': 'Bearer $_token'});

  Future<void> _loadOnboardingStatus({bool allowRefresh = true}) async {
    if (_token == null && !await _refreshOnboardingSession()) return;
    try {
      final response = await _dio.get(
          '/api/v4/identity/merchant/onboarding/status',
          options: _identityOptions);
      if (!mounted) return;
      setState(() {
        _approvalStatus =
            response.data['approval_status']?.toString() ?? 'pending_approval';
        _approvalNote = response.data['approval_note']?.toString();
        _locationComplete = response.data['shop_location_complete'] == true;
        _documents = List<dynamic>.from(response.data['documents'] ?? []);
      });
      if (_approvalStatus == 'active') {
        await _clearOnboardingSession();
      }
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        if (allowRefresh && await _refreshOnboardingSession()) {
          await _loadOnboardingStatus(allowRefresh: false);
        } else {
          await _clearOnboardingSession();
        }
      }
    }
  }

  Future<bool> _refreshOnboardingSession() async {
    if (_refreshToken == null || _refreshToken!.isEmpty) return false;
    try {
      final response = await _dio.post('/api/v4/identity/session/refresh',
          data: {'refresh_token': _refreshToken});
      final token = response.data['access_token']?.toString();
      final refreshToken = response.data['refresh_token']?.toString();
      if (token == null ||
          token.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        return false;
      }
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_onboardingTokenKey, token);
      await preferences.setString(_onboardingRefreshTokenKey, refreshToken);
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
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_onboardingTokenKey);
    await preferences.remove(_onboardingRefreshTokenKey);
    if (mounted) {
      setState(() {
        _token = null;
        _refreshToken = null;
      });
    }
  }

  Future<void> _addLocation() async {
    setState(() => _loading = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('خدمة الموقع غير مفعلة.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('يلزم السماح بالوصول إلى الموقع.');
      }
      final position = await Geolocator.getCurrentPosition();
      await _dio.put('/api/v4/identity/merchant/onboarding/location',
          data: {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
          options: _identityOptions);
      await _loadOnboardingStatus();
      _showMessage('تم حفظ موقع المتجر.');
    } on DioException catch (error) {
      _showMessage(_errorText(error), error: true);
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Bad state: ', ''),
          error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _uploadIdentity() async {
    final XFile? file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    setState(() => _loading = true);
    try {
      await _dio.post('/api/v4/identity/merchant/onboarding/documents',
          data: FormData.fromMap({
            'document_type': 'identity',
            'document':
                await MultipartFile.fromFile(file.path, filename: file.name),
          }),
          options: _identityOptions);
      await _loadOnboardingStatus();
      _showMessage('تم رفع وثيقة الهوية للمراجعة.');
    } on DioException catch (error) {
      _showMessage(_errorText(error), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _errorText(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      return data['message']?.toString() ?? 'تعذر إتمام الطلب.';
    }
    return 'تعذر الاتصال بالخادم.';
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message), backgroundColor: error ? Colors.red : null));
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = _token != null;
    return Scaffold(
      appBar: AppBar(
          title: Text(onboarding ? 'طلب انضمام المورد' : 'إنشاء حساب مورد')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: onboarding
              ? _onboardingBody()
              : (_challengeId == null ? _registrationBody() : _otpBody()),
        ),
      ),
    );
  }

  List<Widget> _registrationBody() => [
        const Text(
            'ابدأ ببيانات متجرك ورقم هاتفك. لن يُفعّل الحساب قبل مراجعة المسؤول.',
            style: TextStyle(height: 1.5)),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
                controller: _storeController,
                decoration: const InputDecoration(labelText: 'اسم المتجر'),
                validator: (value) => (value == null || value.trim().length < 2)
                    ? 'أدخل اسم المتجر.'
                    : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                validator: (value) => (value == null || value.trim().length < 8)
                    ? 'أدخل رقم هاتف صحيح.'
                    : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني (اختياري)'),
                validator: (value) => value != null &&
                        value.trim().isNotEmpty &&
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value.trim())
                    ? 'أدخل بريدًا صحيحًا.'
                    : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                validator: (value) => (value == null || value.length < 8)
                    ? 'كلمة المرور 8 أحرف على الأقل.'
                    : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                validator: (value) => value != _passwordController.text
                    ? 'كلمتا المرور غير متطابقتين.'
                    : null),
            const SizedBox(height: 24),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _loading ? null : _startRegistration,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('إرسال رمز التحقق'))),
          ]),
        ),
      ];

  List<Widget> _otpBody() => [
        const Text(
            'أدخل الرمز الذي وصل إلى رقم هاتفك لإتمام إنشاء طلب الانضمام.'),
        const SizedBox(height: 20),
        TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(labelText: 'رمز التحقق')),
        const SizedBox(height: 20),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: _loading ? null : _verifyOtp,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('تأكيد الرمز'))),
        TextButton(
            onPressed:
                _loading ? null : () => setState(() => _challengeId = null),
            child: const Text('تعديل بيانات التسجيل')),
      ];

  List<Widget> _onboardingBody() {
    final approved = _approvalStatus == 'active';
    dynamic identity;
    for (final item in _documents) {
      if (item is Map && item['document_type'] == 'identity') {
        identity = item;
        break;
      }
    }
    return [
      Icon(approved ? Icons.verified_rounded : Icons.pending_actions_rounded,
          size: 64, color: approved ? Colors.green : Colors.orange),
      const SizedBox(height: 16),
      Text(approved ? 'تمت الموافقة على حسابك' : 'حسابك قيد المراجعة',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text(
          approved
              ? 'يمكنك الآن تسجيل الدخول بالهاتف أو البريد وكلمة المرور.'
              : 'أكمل الهوية وموقع المتجر ليتمكن المسؤول من مراجعة طلبك.',
          textAlign: TextAlign.center),
      if (_approvalNote != null && _approvalNote!.isNotEmpty) ...[
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8)),
          child: Text('ملاحظة المسؤول: $_approvalNote'),
        ),
      ],
      const SizedBox(height: 24),
      ListTile(
          leading: Icon(
              _locationComplete
                  ? Icons.check_circle
                  : Icons.location_on_outlined,
              color: _locationComplete ? Colors.green : null),
          title: const Text('موقع المتجر'),
          subtitle:
              Text(_locationComplete ? 'تم حفظ الموقع' : 'مطلوب قبل الموافقة'),
          trailing: approved
              ? null
              : TextButton(
                  onPressed: _loading ? null : _addLocation,
                  child: const Text('تحديد الموقع'))),
      ListTile(
          leading: Icon(
              identity != null && identity['review_status'] == 'approved'
                  ? Icons.check_circle
                  : Icons.badge_outlined,
              color: identity != null && identity['review_status'] == 'approved'
                  ? Colors.green
                  : null),
          title: const Text('وثيقة الهوية'),
          subtitle: Text(identity == null
              ? 'مطلوبة قبل الموافقة'
              : 'الحالة: ${identity['review_status']}'),
          trailing: approved
              ? null
              : TextButton(
                  onPressed: _loading ? null : _uploadIdentity,
                  child: const Text('رفع الوثيقة'))),
      const SizedBox(height: 24),
      if (!approved)
        OutlinedButton(
            onPressed: _loading ? null : _loadOnboardingStatus,
            child: const Text('تحديث حالة المراجعة')),
      if (approved)
        ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('العودة إلى تسجيل الدخول')),
    ];
  }
}
