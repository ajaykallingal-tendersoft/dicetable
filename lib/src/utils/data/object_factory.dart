import 'package:soloseaters/src/purchase/repository/purchase_repository.dart';
import 'package:soloseaters/src/resources/api_providers/iap/iap_data_provider.dart';
import 'package:soloseaters/src/utils/client/api_client.dart';
import 'package:soloseaters/src/utils/data/prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ObjectFactory {
  static final _objectFactory = ObjectFactory._internal();

  ObjectFactory._internal();

  factory ObjectFactory() => _objectFactory;

  ///Initialisation of Objects
  final Prefs _prefs = Prefs();
  final ApiClient _apiClient = ApiClient();
  final PaymentRepository _purchaseRepository = PaymentRepository(iapDataProvider: IapDataProvider());


  ///
  /// Getters of Objects
  ///
  ApiClient get apiClient => _apiClient;

  Prefs get prefs => _prefs;

  PaymentRepository get purchaseRepository => _purchaseRepository;


  ///
  /// Setters of Objects
  ///
  void setPrefs(SharedPreferences sharedPreferences) {
    _prefs.sharedPreferences = sharedPreferences;
  }
}