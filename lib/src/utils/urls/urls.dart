class UrlsDiceApp {
  ///base urls
  static const String baseUrlDev = 'https://app.mydicetable.com';
  static const String baseUrlLiveStaging = 'http://lcr-alb-782390135.me-south-1.elb.amazonaws.com';
  static const String baseUrlLiveProduction = 'https://www.letscollectco.com';

  ///Cafe Owner
  ///Auth
  static const String register = '/api/register';
  static const String login = '/api/login';
  static const String forgotPassword = '/api/forgot';
  static const String passwordReset = '/api/reset';
  static const String googleLogin = '/api/google/auth';
  static const String googleSignUp = '/api/google/signup';
  static const String otpVerify = '/api/otp/verify';
  static const String venueType = '/api/venue-types';


  ///Subscription
  static const String subscriptionStart = '/api/subscription/start';
  static const String subscriptionInitial = '/api/subscription/new-subscription';
  static const String subscriptionOverView = '/api/subscription/overview';

  ///Home

  static const String venueOwnerHome = '/api/cafe/dice-tables';
  static const String updateDiceTable = '/api/cafe/dice-tables/update';





  //Customer
  static const String getFavourite = '/api/favourites';




}




