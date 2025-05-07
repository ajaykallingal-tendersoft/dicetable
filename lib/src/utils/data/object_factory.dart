import 'package:dicetable/src/utils/client/api_client.dart';
import 'package:dicetable/src/utils/data/prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ObjectFactory {
  static final _objectFactory = ObjectFactory._internal();

  ObjectFactory._internal();

  factory ObjectFactory() => _objectFactory;

  ///Initialisation of Objects
  final Prefs _prefs = Prefs();
  final ApiClient _apiClient = ApiClient();


  ///
  /// Getters of Objects
  ///
  ApiClient get apiClient => _apiClient;

  Prefs get prefs => _prefs;


  ///
  /// Setters of Objects
  ///
  void setPrefs(SharedPreferences sharedPreferences) {
    _prefs.sharedPreferences = sharedPreferences;
  }
}