class UrlsDiceApp {
  ///base urls
  static const String baseUrlDev = 'https://app.soloseaters.com';
  static const String baseUrlLocal = 'http://192.168.0.131:8001';
  static const String baseUrlLiveStaging = '';
  static const String baseUrlLiveProduction = '';

  ///Cafe Owner
  ///Auth
  static const String register = '/api/register';
  static const String login = '/api/login';
  static const String forgotPassword = '/api/forgot-password';
  static const String passwordReset = '/api/reset-password';
  static const String googleLogin = '/api/google/auth';
  static const String googleSignUp = '/api/google/signup';
  static const String otpVerify = '/api/otp/verify';
  static const String resendOtp = '/api/otp/resend';
  static const String venueType = '/api/venue-types';
  static const String countryList = '/api/country-list';
  static const String appleSignIn = '/api/apple/auth';
  static const String cafeProfileDelete = '/api/cafe/profile/delete';
  static const String appleSignUp = '/api/apple/signup';
  static const String profileImageUpload = '/api/upload-cafe-photo';
  static const String profileMultipleImageUpload = '/api/upload-cafe-gallery';

  ///Subscription
  static const String subscriptionStart = '/api/subscription/start';
  static const String subscriptionInitial =
      '/api/subscription/new-subscription';
  static const String subscriptionOverView = '/api/subscription/overview';

  ///Home

  static const String venueOwnerHome = '/api/cafe/dice-tables';
  static const String updateDiceTable = '/api/cafe/dice-tables/update';
  static const String getProfile = '/api/cafe/profile/';
  static const String getEditProfile = '/api/cafe/edit/';
  static const String profileUpdate = '/api/cafe/update/';

  ///Customer
  static const String getFavourite = '/api/favourites';
  static const String booking = '/api/booking';
  static const String cafeList = '/api/cafe-list';
  static const String addFavourite = '/api/favourites/add';
  static const String removeFavourite = '/api/favourites/remove';
  static const String history = '/api/customer/activity-history';
  static const String getCustomerProfile = '/api/customer/profile';
  static const String updateCustomerProfile = '/api/customer/profile/update';
  static const String cafeSearch = '/api/search-cafe';
  static const String getFilters = '/api/filter-options';
  static const String withdrawBooking = '/api/withdraw-booking';
  static const String deleteCustomerAccount = '/api/customer/profile/delete';
  static const String guestUserSignIn = '/api/guest/signin';
  static const String getPaidCustomerProfileById = '/api/customer/paid-profile/';
  static const String updatePaidCustomerProfile = '/api/customer/paid-profile/update/';
  

  ///Notification
  static const String getCafeNotification = '/api/cafe/notifications';
  static const String getCustomerNotification = '/api/customer/notifications';
  static const String markNotificationAsRead = '/api/notification/read';
  static const String updateNotificationStatus =
      '/api/notification/update-status';
}
