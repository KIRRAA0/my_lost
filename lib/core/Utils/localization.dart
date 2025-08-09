import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationState {
  final Locale locale;

  LocalizationState(this.locale);
}

class LocalizationCubit extends Cubit<LocalizationState> {
  static const Locale fallbackLocale = Locale('en', 'US');
  static const String languageCodeKey = 'language_code';

  static final Map<String, Locale> locales = {
    'en': const Locale('en', 'US'),
    'ar': const Locale('ar', 'EG'),
  };

  LocalizationCubit() : super(LocalizationState(fallbackLocale));

  // Translation data
  final Map<String, Map<String, String>> _translationKeys = {
    'en_US': {
      'Edit Profile': 'Edit Profile',
      'Address': 'Address',
      'Phone Number': 'Phone Number',
      'Change Password': 'Change Password',
      'Change Language': 'Change Language',
      'Security': 'Security',
      'Privacy Policy': 'Privacy Policy',
      'Help Center': 'Help Center',
      'Hi': 'Hi',
      'Feel Free using our services': 'Feel Free using our services',
      'My Order': 'My Order',
      'Wallet': 'Wallet',
      'Create Order': 'Create Order',
      'Track Order': 'Track Order',
      'My Account': 'My Account',
      'Reports': 'Reports',
      'greeting': 'Hi, @username👋',
      'Completed Orders': 'Completed Orders',
      'Cash Orders': 'Cash Orders',
      'Orders Visa': 'Orders Visa',
      'Wallet Orders': 'Wallet Orders',
      'Pending Withdraw': 'Pending Withdraw',
      'Cancelled Orders': 'Cancelled Orders',
      'My Orders': 'My Orders',
      'ongoing': 'ongoing',
      'completed': 'completed',
      'Ongoing': 'Ongoing',
      'Completed': 'Completed',
      'All': 'All',
      'Pick Time': 'Pick Time',
      'Parcel Weight': 'Parcel Weight',
      'parcels type': 'parcels type',
      'Your Location': 'Your Location',
      'Contact Number': 'Contact Number',
      'Another Number': 'Another Number',
      'Description': 'Description',
      'Receiver Name': 'Receiver Name',
      'Next': 'Next',
      'Date': 'Date',
      'To': 'To',
      'From': 'From',
      'weight': 'weight',
      'Please enter your phone number to continue':
      'Please enter your phone number to continue',
      'Please fill the field': 'Please fill the field',
      'Location': 'Location',
      'Delivery Location': 'Delivery Location',
      'Delivery Contact Number': 'Delivery Contact Number',
      'Another Delivery Number': 'Another Delivery Number',
      'Enter phone number.': 'Enter phone number.',

      // Added texts for ForgotPassword screen
      'Reset Password': 'Reset Password',
      'Please enter your email address to reset password':
      'Please enter your email address to reset password',
      'Email Address': 'Email Address',
      'Please enter your email address': 'Please enter your email address',
      'Send Email': 'Send Email',
      'Email sent successfully': 'Email sent successfully',
      'Sorry, User Not Found': 'Sorry, User Not Found',

      // Added texts for OtpScreen
      'Please enter the OTP sent to your email':
      'Please enter the OTP sent to your email',
      'OTP Verified Successfully': 'OTP Verified Successfully',
      'Oops...': 'Oops...',
      'Invalid OTP': 'Invalid OTP',
      // Added texts for ChangePasswordScreen
      'Please enter your new password': 'Please enter your new password',
      'Password': 'Password',
      'Please confirm your new password': 'Please confirm your new password',
      'Confirm Password': 'Confirm Password',
      'Password changed successfully': 'Password changed successfully',
      'Password don\'t match': 'Password don\'t match',
      'Change password': 'Change password',
      // Added texts for BioDataPage
      "What's Your Name?": "What's Your Name?",
      "Fill Your FULL NAME correctly": "Fill Your FULL NAME correctly",
      "Full Name": "Full Name",
      "Please enter username": "Please enter username",

      "Create Account": "Create Account",
      "Submit": "Submit",
      "Account created successfully": "Account created successfully",
      "Sorry, something went wrong": "Sorry, something went wrong",

      "Create Password": "Create Password",
      "Set a secure password for your account":
      "Set a secure password for your account",

      "Store Information": "Store Information",
      "Save your important information securely.":
      "Save your important information securely.",
      "National ID Number": "National ID Number",
      "National ID": "National ID",
      "Tax Number": "Tax Number",
      "Product Type": "Product Type",
      "National ID Card (front)": "National ID Card (front)",
      "National ID Card (back)": "National ID Card (back)",
      "Tax Number Photo": "Tax Number Photo",
      "Commercial Register Photo": "Commercial Register Photo",
      "Please enter National ID": "Please enter National ID",
      "Please enter Tax Number": "Please enter Tax Number",
      "Please enter Product Type": "Please enter Product Type",

      "What's Your Email?": "What's Your Email?",
      "Fill Your EMAIL correctly": "Fill Your EMAIL correctly",
      "Email": "Email",
      "Please enter email": "Please enter email",

      'landing_welcome': 'Welcome to Techno adala',
      'landing_login_prompt': 'Login to get started with our services',
      'landing_continue_google': 'Continue with Google',
      'landing_continue_facebook': 'Continue with Facebook',
      'landing_continue_apple': 'Continue with Apple',
      'landing_or_login': 'or login with',
      'landing_login_now': 'Login now',
      'landing_register_prompt': "Don't have an account? Register now",

      'login_title': 'Login',
      'login_prompt': 'Please login to use our services',
      'login_password': 'Password',
      'login_password_hint': 'Please enter password',
      'login_forgot_password': 'Forgot Your Password?',
      'login_button': 'Login',
      'login_no_account_prompt': "Don't have an account? ",
      'login_register_now': 'Register now',
      'login_success': 'Logged in',
      'login_error_title': 'Oops...',
      'login_error_message': 'Sorry, something went wrong',
    },
    'ar_EG': {
      'Edit Profile': 'تعديل الملف الشخصي',
      'Address': 'العنوان',
      'Phone Number': 'رقم الهاتف',
      'Change Password': 'تغيير كلمة المرور',
      'Change Language': 'تغيير اللغة',
      'Security': 'الأمان',
      'Privacy Policy': 'سياسة الخصوصية',
      'Help Center': 'مركز المساعدة',
      'Hi': 'مرحباً',
      'Feel Free using our services': 'لا تتردد في استخدام خدماتنا',
      'My Order': 'طلباتي',
      'Wallet': 'المحفظة',
      'Create Order': 'إنشاء طلب',
      'Track Order': 'تتبع الطلب',
      'My Account': 'حسابي',
      'Reports': 'التقارير',
      'greeting': 'مرحباً، @username👋',
      'Completed Orders': 'الطلبات المكتملة',
      'Cash Orders': 'طلبات نقدية',
      'Orders Visa': 'طلبات فيزا',
      'Wallet Orders': 'طلبات المحفظة',
      'Pending Withdraw': 'السحب المعلق',
      'Cancelled Orders': 'الطلبات الملغاة',
      'My Orders': 'طلباتي',
      'ongoing': 'قيد التنفيذ',
      'completed': 'تم التنفيذ',
      'Ongoing': 'قيد التنفيذ',
      'Completed': 'تم التنفيذ',
      'All': 'الكل',
      'Pick Time': 'وقت الاستلام',
      'Parcel Weight': 'وزن الطرد',
      'parcels type': 'نوع الطرد',
      'Your Location': 'موقعك',
      'Contact Number': 'رقم الاتصال',
      'Another Number': 'رقم آخر',
      'Description': 'الوصف',
      'Receiver Name': 'اسم المستلم',
      'Next': 'التالي',
      'Date': 'التاريخ',
      'To': 'إلى',
      'From': 'من',
      'weight': 'الوزن',
      'Please fill the field': 'يرجى تعبئة الحقل',
      'Location': 'الموقع',
      'Please enter your phone number to continue':
      'الرجاء إدخال رقم هاتفك للمتابعة',
      'Delivery Location': 'موقع التسليم',
      'Delivery Contact Number': 'رقم الاتصال للتسليم',
      'Another Delivery Number': 'رقم تسليم آخر',
      'Enter phone number.': 'أدخل رقم الهاتف.',

      // Added texts for ForgotPassword screen
      'Reset Password': 'إعادة تعيين كلمة المرور',
      'Please enter your email address to reset password':
      'يرجى إدخال عنوان بريدك الإلكتروني لإعادة تعيين كلمة المرور',
      'Email Address': 'عنوان البريد الإلكتروني',
      'Please enter your email address':
      'يرجى إدخال عنوان بريدك الإلكتروني',
      'Send Email': 'إرسال البريد الإلكتروني',
      'Email sent successfully': 'تم إرسال البريد الإلكتروني بنجاح',
      'Sorry, User Not Found': 'عذرًا، المستخدم غير موجود',

      // Added texts for OtpScreen
      'Please enter the OTP sent to your email':
      'يرجى إدخال رمز التحقق الذي أُرسل إلى بريدك الإلكتروني',
      'OTP Verified Successfully': 'تم التحقق من الرمز بنجاح',
      'Oops...': 'عذرًا...',
      'Invalid OTP': 'رمز التحقق غير صحيح',
      // Added texts for ChangePasswordScreen
      'Please enter your new password': 'يرجى إدخال كلمة مرور جديدة',
      'Password': 'كلمة المرور',
      'Please confirm your new password': 'يرجى تأكيد كلمة المرور الجديدة',
      'Confirm Password': 'تأكيد كلمة المرور',
      'Password changed successfully': 'تم تغيير كلمة المرور بنجاح',
      'Password don\'t match': 'كلمات المرور غير متطابقة',
      'Change password': 'تغيير كلمة المرور',
      // Added texts for BioDataPage
      "What's Your Name?": "ما هو اسمك؟",
      "Fill Your FULL NAME correctly": "املأ اسمك الكامل بشكل صحيح",
      "Full Name": "الاسم الكامل",
      "Please enter username": "يرجى إدخال اسم المستخدم",
      "Create Account": "إنشاء حساب",
      "Submit": "إرسال",
      "Account created successfully": "تم إنشاء الحساب بنجاح",
      "Sorry, something went wrong": "عذرًا، حدث خطأ ما",

      "Create Password": "إنشاء كلمة المرور",
      "Set a secure password for your account": "حدد كلمة مرور آمنة لحسابك",

      "Store Information": "معلومات المتجر",
      "Save your important information securely.": "احفظ معلوماتك الهامة بأمان.",
      "National ID Number": "رقم الهوية الوطنية",
      "National ID": "الهوية الوطنية",
      "Tax Number": "الرقم الضريبي",
      "Product Type": "نوع المنتج",
      "National ID Card (front)": "بطاقة الهوية الوطنية (أمامي)",
      "National ID Card (back)": "بطاقة الهوية الوطنية (خلفي)",
      "Tax Number Photo": "صورة الرقم الضريبي",
      "Commercial Register Photo": "صورة السجل التجاري",

      "Please enter National ID": "يرجى إدخال رقم الهوية الوطنية",
      "Please enter Tax Number": "يرجى إدخال الرقم الضريبي",
      "Please enter Product Type": "يرجى إدخال نوع المنتج",

      "What's Your Email?": "ما هو بريدك الإلكتروني؟",
      "Fill Your EMAIL correctly": "املأ بريدك الإلكتروني بشكل صحيح",
      "Email": "البريد الإلكتروني",
      "Please enter email": "يرجى إدخال البريد الإلكتروني",

      'landing_welcome': 'مرحبًا! مرحبًا بك في سمارت رابيت',
      'landing_login_prompt': 'قم بتسجيل الدخول للبدء في استخدام خدماتنا',
      'landing_continue_google': 'الاستمرار مع جوجل',
      'landing_continue_facebook': 'الاستمرار مع فيسبوك',
      'landing_continue_apple': 'الاستمرار مع أبل',
      'landing_or_login': 'أو تسجيل الدخول باستخدام',
      'landing_login_now': 'تسجيل الدخول الآن',
      'landing_register_prompt': 'ليس لديك حساب؟ سجل الآن',

      'login_title': 'تسجيل الدخول',
      'login_prompt': 'يرجى تسجيل الدخول لاستخدام خدماتنا',
      'login_password': 'كلمة المرور',
      'login_password_hint': 'يرجى إدخال كلمة المرور',
      'login_forgot_password': 'هل نسيت كلمة المرور؟',
      'login_button': 'تسجيل الدخول',
      'login_no_account_prompt': 'ليس لديك حساب؟ ',
      'login_register_now': 'سجل الآن',
      'login_success': 'تم تسجيل الدخول',
      'login_error_title': 'عذرًا...',
      'login_error_message': 'عذرًا، حدث خطأ ما',
    }
  };

  // Method to load saved language
  Future<void> loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString(languageCodeKey);

    if (langCode != null && locales.containsKey(langCode)) {
      emit(LocalizationState(locales[langCode]!));
    } else {
      emit(LocalizationState(fallbackLocale));
    }
  }

  // Method to change locale
  Future<void> changeLocale(String langCode) async {
    final locale = locales[langCode];
    if (locale != null) {
      // Save the selected language in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(languageCodeKey, langCode);

      emit(LocalizationState(locale));
    }
  }

  // Getter for current locale
  Locale get currentLocale => state.locale;

  // Method to get translated text
  String tr(String key) {
    final localeKey = '${state.locale.languageCode}_${state.locale.countryCode}';
    return _translationKeys[localeKey]?[key] ?? key;
  }
}