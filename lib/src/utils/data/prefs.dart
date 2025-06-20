import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// shared preference storage
class Prefs {
  JsonCodec codec = const JsonCodec();
  SharedPreferences? _sharedPreferences;

  static const String _IS_USER_LOADED = "is_user_loaded";
  static const String _IS_HOME_1_DATA_LOADED = "is_home_1_data_loaded";
  static const String _IS_HOME_2_DATA_LOADED = "is_home_2_data_loaded";
  static const String _USER_DECISON = "USER_DECISION";
  static const String _AUTH_TOKEN = "auth_token";
  static const String _CUSTOMER_AUTH_TOKEN = "customer_auth_token";
  static const String _CUSTOMER_USER_NAME = "user_name";
  static const String _CAFE_USER_NAME = "user_name";
  static const String _CAFE_USER_MAIL = "cafe_user_mail";
  static const String _CUSTOMER_MAIL = "customer_mail";
  static const String _CUSTOMER_USER_MAIL = "customer_user_mail";
  static const String _CAFE_USER_PHONE = "_CAFE_USER_IMAGE";
  static const String _CAFE_USER_IMAGE = "cafe_user_image";
  static const String _USER_MAIL_VERIFIED = "_user_mail_verified";
  static const String _IS_GOOGLE = "is_google";


  static const String _USER_MAIL = "USER_MAIL";
  static const String _USER_ID = "user_id";
  static const String _CAFE_ID = "cafe_id";
  static const String _LAYOUT_ID = "layout_id";
  static const String _COMPARE_CATEGORY_ID = "compare_category_id";
  static const String _CUSTOMER_NOTE = "customer_note";
  static const String _SORT_ID = "sort_id";
  static const String _FILTER_CATEGORY_ID = "filter_category_id";
  static const String _FCM_TOKEN = "fcm_token";
  static const String _USER_DATA = "user_data";
  static const String _USER_DATA_SIGNUP = "user_data_signup";
  static const String _REFERRAL_DATA = "referral_data";
  static const String _HELP_CENTER_DATA = "help_center_data";
  static const String _IS_LOGGED_IN = "is_logged_in";
  static const String _IS_CUSTOMER_LOGGED_IN = "is_customer_logged_in";
  static const String _REMEMBER_DECISION = "remember_decision";
  static const String _IS_EMAIL_VERIFIED = "is_email_verified";
  static const String _IS_EMAIL_VERIFIED_STATUS = "is_email_verified";
  static const String _VERIFIED_POINTS = "verified_points";
  static const String _IS_EMAIL_NOT_VERIFIED_STATUS = "is_email_verified";
  static const String _IS_EMAIL_NOT_VERIFIED_CALLED = "is_email_verified";
  static const String _IS_MOB_NUM_VERIFIED = "is_mob_num_verified";
  static const String _IS_REFERRAL_LOADED = "is_referral_loaded";
  static const String _IS_HELP_CENTER_LOADED = "is_help_center_loaded";
  static const String _BRAND_TIER_DATA = "brand_tier_data";
  static const String _PARTNER_TIER_DATA = "partner_tier_data";
  static const String _LETSCOLLECT_TIER_DATA = "letsCollect_tier_data";
  static const String _SET_GET_INT = "flag";
  static const String _SET_LANG = "Lang";
  static const String _IS_PROFILE_UPDATED = "is_PROFILE_UPDATED";
  static const String _LATITUDE_ = "lat";
  static const String _LONGITUDE_ = "long";
  static const String _CLEAR_USER_IMAGE = "clear_image";
  static const String _IS_FIRST_LAUNCH = "is_first_launch";
  static const String _PENDING_NOTIFICATION_NAVIGATION = 'pending_notification_navigation';
  static const String _DEVICE_ID = 'device_id';
  static const String _IS_GUEST = "is_GUEST";
  static const String _CAFE_USER_ID = "cafe_user_id";









  Prefs();

  set sharedPreferences(SharedPreferences value) {
    _sharedPreferences = value;
  }



  void setIsGuestUser(bool status) {
    _sharedPreferences!.setBool(_IS_GUEST, status);
  }

  ///Save User remember Decision
  bool? isGuestUser() => _sharedPreferences!.getBool(_IS_GUEST) != null &&
      _sharedPreferences!.getBool(_IS_GUEST) == true
      ? true
      : false;


  ///saving DeviceID
  void setDeviceID({String? deviceID}) {
    _sharedPreferences!.setString(_DEVICE_ID, deviceID!);
  }

  ///get method  for DeviceID
  String? getDeviceID() => _sharedPreferences?.getString(_DEVICE_ID);

  ///saving cafe user image
  void setImageData({String? cafeUserImage}) {
    _sharedPreferences!.setString(_CAFE_USER_IMAGE, cafeUserImage!);
  }

  ///get method  for cafe user image
  String? getImageData() => _sharedPreferences?.getString(_CAFE_USER_IMAGE);

  Future<void> clearImageData() async {
    await _sharedPreferences!.remove('_CAFE_USER_IMAGE');
  }

  ///saving cafe user name
  void setCafeUserName({String? cafeUserName}) {
    _sharedPreferences!.setString(_CAFE_USER_NAME, cafeUserName!);
  }

  ///get method  for cafe user name
  String? getCafeUserName() => _sharedPreferences?.getString(_CAFE_USER_NAME);


  ///saving user name
  void setCustomerUserName({String? customerUserName}) {
    _sharedPreferences!.setString(_CUSTOMER_USER_NAME, customerUserName!);
  }

  ///get method  for user name
  String? getCustomerUserName() => _sharedPreferences?.getString(_CUSTOMER_USER_NAME);



  ///saving  the auth token as a String
  void setAuthToken({String? token}) {
    _sharedPreferences!.setString(_AUTH_TOKEN, "Bearer ${token!}");
  }

  ///get method  for auth token
  String? getAuthToken() => _sharedPreferences?.getString(_AUTH_TOKEN);

  ///saving  the auth token as a String
  void setUserId({String? userId}) {
    _sharedPreferences!.setString(_USER_ID, userId!);
  }

  ///get method  for userID
  String? getUserId() => _sharedPreferences!.getString(_USER_ID);

  ///saving customer  the auth token as a String
  void setCustomerAuthToken({String? token}) {
    _sharedPreferences!.setString(_CUSTOMER_AUTH_TOKEN, "Bearer ${token!}");
  }

  ///get method  for auth token
  String? getCustomerAuthToken() => _sharedPreferences?.getString(_CUSTOMER_AUTH_TOKEN);

  ///saving customer mail
  void setCustomerMail({String? mail}) {
    _sharedPreferences!.setString(_CUSTOMER_MAIL, mail!);
  }

  ///get method  customer mail
  String? getCustomerMail() => _sharedPreferences?.getString(_CUSTOMER_MAIL);

  ///saving user decision
  void setUserDecisionName({String? userDecision}) {
    _sharedPreferences!.setString(_USER_DECISON, userDecision!);
  }

  ///get method  for cafe user name
  String? getUserDecisionName() => _sharedPreferences?.getString(_USER_DECISON);

  /// Method to track navigation source
  Future<void> setNavigationSource(String source) async {
    await _sharedPreferences!.setString('navigation_source', source);
  }

  // Method to get navigation source
  String? getNavigationSource() {
    return _sharedPreferences!.getString('navigation_source');
  }

  // Method to clear navigation source when no longer needed
  Future<void> clearNavigationSource() async {
    await _sharedPreferences!.remove('navigation_source');
  }

  ///saving customer user email
  void setCustomerUserMail({String? customerUserMail}) {
    _sharedPreferences!.setString(_CUSTOMER_USER_MAIL, customerUserMail!);
  }

  ///get method  for customer user mail
  String? getCustomerUserMail() => _sharedPreferences?.getString(_CUSTOMER_USER_MAIL);

  ///saving cafe user email
  void setCafeUserMail({String? cafeUserMail}) {
    _sharedPreferences!.setString(_CAFE_USER_MAIL, cafeUserMail!);
  }

  ///get method  for cafe user mail
  String? getCafeUserMail() => _sharedPreferences?.getString(_CAFE_USER_MAIL);

  ///saving cafe user phone
  void setCafeUserPhone({String? cafeUserPhone}) {
    _sharedPreferences!.setString(_CAFE_USER_PHONE, cafeUserPhone!);
  }

  ///get method  for cafe user phone
  String? getCafeUserPhone() => _sharedPreferences?.getString(_CAFE_USER_PHONE);

  ///saving cafe user base64 image
  void setCafeUserImage({String? cafeUserImage}) {
    _sharedPreferences!.setString(_CAFE_USER_IMAGE, cafeUserImage!);
  }

  ///get method  for cafe user image
  String? getCafeUserImage() => _sharedPreferences?.getString(_CAFE_USER_IMAGE);

  ///Get method for cafeID
  void setCafeId({String? cafeId}) {
    _sharedPreferences!.setString(_CAFE_ID, cafeId!);
  }

  ///get method  for cafeID
  String? getCafeId() => _sharedPreferences!.getString(_CAFE_ID);

  ///Method for cafe userID
  void setCafeUserId({String? cafeUserId}) {
    _sharedPreferences!.setString(_CAFE_USER_ID, cafeUserId!);
  }

  ///get method  for cafeID
  String? getCafeUserId() => _sharedPreferences!.getString(_CAFE_USER_ID);

  ///Get method for latitude
  void setLatitude({String? lat}) {
    _sharedPreferences!.setString(_LATITUDE_, lat!);
  }

  ///get method  for latitude
  String? getLatitude() => _sharedPreferences!.getString(_LATITUDE_);



  ///Get method for longitude
  void setLongitude({String? long}) {
    _sharedPreferences!.setString(_LONGITUDE_, long!);
  }

  ///get method  for longitude
  String? getLongitude() => _sharedPreferences!.getString(_LONGITUDE_);


  ///saving  the auth token as a String
  void setFcmToken({String? token}) async {
    await _sharedPreferences!.setString(_FCM_TOKEN, token!);
  }

  ///get method  for auth token
  String? getFcmToken() => _sharedPreferences!.getString(_FCM_TOKEN);


  /// Set First Launch
  void setIsFirstLaunch(bool status) {
    _sharedPreferences?.setBool(_IS_FIRST_LAUNCH, status);
  }

  /// Get First Launch
  bool isFirstLaunch() {
    return _sharedPreferences?.getBool(_IS_FIRST_LAUNCH) ?? true;
  }

  void setPendingNotificationNavigation(bool status) {
    _sharedPreferences?.setBool(_PENDING_NOTIFICATION_NAVIGATION, status);
  }

  /// Get Pending Notification Navigation
  bool? getPendingNotificationNavigation() {
    return _sharedPreferences?.getBool(_PENDING_NOTIFICATION_NAVIGATION);
  }

  ///after login set isLoggedIn true
  ///before logout set isLoggedIn false
  void setIsLoggedIn(bool status) {
    _sharedPreferences!.setBool(_IS_LOGGED_IN, status);
  }

  ///Save User remember Decision
  bool? isLoggedIn() => _sharedPreferences!.getBool(_IS_LOGGED_IN) != null &&
      _sharedPreferences!.getBool(_IS_LOGGED_IN) == true
      ? true
      : false;

  void setRememberDecision(bool status) {
    _sharedPreferences!.setBool(_REMEMBER_DECISION, status);
  }

  ///Get User Remember decision
  bool? getRememberDecision() => _sharedPreferences!.getBool(_REMEMBER_DECISION) != null &&
      _sharedPreferences!.getBool(_REMEMBER_DECISION) == true
      ? true
      : false;

  ///after login set isLoggedIn true
  ///before logout set isLoggedIn false
  void setIsCustomerLoggedIn(bool status) {
    _sharedPreferences!.setBool(_IS_CUSTOMER_LOGGED_IN, status);
  }

  bool? isCustomerLoggedIn() => _sharedPreferences!.getBool(_IS_CUSTOMER_LOGGED_IN) != null &&
      _sharedPreferences!.getBool(_IS_CUSTOMER_LOGGED_IN) == true
      ? true
      : false;

  ///Set  email is verified.
  void setEmailVerified(bool status) {
    _sharedPreferences!.setBool(_USER_MAIL_VERIFIED, status);
  }

  bool? isEmailVerified() => _sharedPreferences!.getBool(_USER_MAIL_VERIFIED) != null &&
      _sharedPreferences!.getBool(_USER_MAIL_VERIFIED) == true
      ? true
      : false;

  ///Set is Google.
  void setIsGoogle(bool status) {
    _sharedPreferences!.setBool(_IS_GOOGLE, status);
  }

  bool? isGoogle() => _sharedPreferences!.getBool(_IS_GOOGLE) != null &&
      _sharedPreferences!.getBool(_IS_GOOGLE) == true
      ? true
      : false;



  /// for clearing the data in preference
  void clearPrefs() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
  //
  // void setIsUserLoaded(bool status) {
  //   _sharedPreferences!.setBool(_IS_USER_LOADED, status);
  // }
  //
  // /// checking data in home layout 1 is available or not
  // bool isUserLoaded() =>
  //     _sharedPreferences!.getBool(_IS_USER_LOADED) != null &&
  //         _sharedPreferences!.getBool(_IS_USER_LOADED) == true
  //         ? true
  //         : false;
  //
  // void setIsHome1DataLoaded(bool status) {
  //   _sharedPreferences!.setBool(_IS_HOME_1_DATA_LOADED, status);
  // }
  //
  // /// checking data in home layout 1 is available or not
  // bool isHome1DataLoaded() =>
  //     _sharedPreferences!.getBool(_IS_HOME_1_DATA_LOADED) != null &&
  //         _sharedPreferences!.getBool(_IS_HOME_1_DATA_LOADED) == true
  //         ? true
  //         : false;
  //
  // void setIsHome2DataLoaded(bool status) {
  //   _sharedPreferences!.setBool(_IS_HOME_2_DATA_LOADED, status);
  // }
  //
  // /// checking data in home layout 2 is available or not
  // bool isHome2DataLoaded() =>
  //     _sharedPreferences!.getBool(_IS_HOME_2_DATA_LOADED) != null &&
  //         _sharedPreferences!.getBool(_IS_HOME_2_DATA_LOADED) == true
  //         ? true
  //         : false;

  ///  save user data
  // void saveUserData(LoginRequestResponse result) {
  //   String jsonString = jsonEncode(result);
  //   _sharedPreferences!.setString(_USER_DATA, jsonString);
  // }
  //
  // ///get user data
  // LoginRequestResponse? getUserData() {
  //   Map<String, dynamic>? resultMap =
  //   jsonDecode(_sharedPreferences!.getString(_USER_DATA)!);
  //   var result = LoginRequestResponse.fromJson(resultMap!);
  //   return result;
  }

  ///  save user data signUp
  // void saveUserDataSignup(SignUpRequestResponse result) {
  //   String jsonString = jsonEncode(result);
  //   _sharedPreferences!.setString(_USER_DATA_SIGNUP, jsonString);
  // }
  //
  // ///get user data
  // SignUpRequestResponse? getUserDataSignup() {
  //   Map<String, dynamic>? resultMap =
  //   jsonDecode(_sharedPreferences!.getString(_USER_DATA_SIGNUP)!);
  //   var result = SignUpRequestResponse.fromJson(resultMap!);
  //   return result;
  // }
  //
  //
  // ///  brand tier data
  // void saveBrandTierData(RewardTierRequestResponse result) {
  //   String jsonString = jsonEncode(result);
  //   _sharedPreferences!.setString(_BRAND_TIER_DATA, jsonString);
  // }
  //
  // /// get brand tier data
  // RewardTierRequestResponse? getBrandTierData() {
  //   Map<String, dynamic>? resultMap =
  //   jsonDecode(_sharedPreferences!.getString(_BRAND_TIER_DATA)!);
  //   var result = RewardTierRequestResponse.fromJson(resultMap!);
  //   return result;
  // }
  //
  //
  // ///  partner tier data
  // void savePartnerTierData(RewardTierRequestResponse result) {
  //   String jsonString = jsonEncode(result);
  //   _sharedPreferences!.setString(_PARTNER_TIER_DATA, jsonString);
  // }
  //
  // ///  get partner tier data
  //
  //
  //
  //
  //
  //
  // ///Setting that is email verified
  // void setIsEmailVerified(bool status) {
  //   _sharedPreferences!.setBool(_IS_EMAIL_VERIFIED, status);
  // }
  //
  // ///checking that is email verified in or not
  // bool? isEmailVerified() => _sharedPreferences!.getBool(_IS_EMAIL_VERIFIED) != null &&
  //     _sharedPreferences!.getBool(_IS_EMAIL_VERIFIED) == true
  //     ? true
  //     : false;
  //
  // ///Setting email verified status
  // void setIsEmailVerifiedStatus(bool status) {
  //   _sharedPreferences!.setBool(_IS_EMAIL_VERIFIED_STATUS, status);
  // }
  //
  // ///checking status
  // bool? isEmailVerifiedStatus() => _sharedPreferences!.getBool(_IS_EMAIL_VERIFIED_STATUS) != null &&
  //     _sharedPreferences!.getBool(_IS_EMAIL_VERIFIED_STATUS) == true
  //     ? true
  //     : false;
  //
  //
  // ///saving email verified points as a String
  // setEmailVerifiedPoints({String? verifiedPoints}) {
  //   _sharedPreferences!.setString(_VERIFIED_POINTS, verifiedPoints!);
  // }
  //
  // ///get method  for email verified points
  // String? getEmailVerifiedPoints() => _sharedPreferences!.getString(_VERIFIED_POINTS);
  //
  //
  //
  // ///Setting email not verified status
  // void setIsEmailNotVerifiedStatus(bool status) {
  //   _sharedPreferences!.setBool(_IS_EMAIL_NOT_VERIFIED_STATUS, status);
  // }
  //
  // ///checking not status
  // bool? isEmailNotVerifiedStatus() => _sharedPreferences!.getBool(_IS_EMAIL_NOT_VERIFIED_STATUS) != null &&
  //     _sharedPreferences!.getBool(_IS_EMAIL_NOT_VERIFIED_STATUS) == true
  //     ? true
  //     : false;
  //
  // ///Setting email not verified status
  // void setIsEmailNotVerifiedCalled(bool status) {
  //   _sharedPreferences!.setBool(_IS_EMAIL_NOT_VERIFIED_CALLED, status);
  // }
  //
  // ///checking not status
  // bool? isEmailNotVerifiedCalled() => _sharedPreferences!.getBool(_IS_EMAIL_NOT_VERIFIED_CALLED) != null &&
  //     _sharedPreferences!.getBool(_IS_EMAIL_NOT_VERIFIED_CALLED) == true
  //     ? true
  //     : false;
  //
  //
  //
  //
  // ///saving  the email verification flag
  // void setFlagInt({String? flag}) {
  //   _sharedPreferences!.setString(_SET_GET_INT, flag!);
  // }
  //
  // ///get method  for auth token
  // String? getFlagInt() => _sharedPreferences!.getString(_SET_GET_INT);
  //
  //
  //
  // ///saving  the lang
  // void setLanguage({String? locale}) {
  //   _sharedPreferences!.setString(_SET_LANG, locale!);
  // }
  //
  // ///get method  for language
  // String? getLanguage() => _sharedPreferences?.getString(_SET_LANG);
  //
  // ///Profile Updation
  // void setIsProfileUpdated(bool status) {
  //   _sharedPreferences!.setBool(_IS_PROFILE_UPDATED, status);
  // }
  //
  // ///checking that is profile updated
  // bool? isProfileUpdated() => _sharedPreferences!.getBool(_IS_PROFILE_UPDATED) != null &&
  //     _sharedPreferences!.getBool(_IS_PROFILE_UPDATED) == true
  //     ? true
  //     : false;
  //
  //
  // ///saving user mail
  // void setUserMail({String? userMail}) {
  //   _sharedPreferences!.setString(_USER_MAIL, userMail!);
  // }
  //
  // ///get method  for user mail
  // String? getUserMail() => _sharedPreferences?.getString(_USER_MAIL);



