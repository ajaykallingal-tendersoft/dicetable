class AuthSessionManager {
  AuthSessionManager._();

  static bool _shouldForceLogout = false;

  static void markRefreshFailure() {
    _shouldForceLogout = true;
  }

  static bool consumeRefreshFailureFlag() {
    if (_shouldForceLogout) {
      _shouldForceLogout = false;
      return true;
    }
    return false;
  }
}


