class ApiRoutes {
  static const _auth = '/api/auth';
  static const _alerts = '/api/alerts';
  static const _notices = '/api/news';
  static const _users = '/api/users';
  static const _adverts = '/api/adverts';
  // Auth routes
  static const register = '$_auth/register';
  static const login = '$_auth/login';
  static const logout = '$_auth/logout';
  static const deviceToken = '$_auth/device-token';
  static const me = '$_auth/me';
  static const changePassword = '$_alerts/change-password';
  // Alert routes
  static const alerts = _alerts;
  static String alert(String id) => '$_alerts/$id';
  static String markAsRead(String id) => '${alert(id)}/read';
  static String archiveAlert(String id) => alert(id);
  static String unarchiveAlert(String id) => '${alert(id)}/unarchive';
  static String shareAlert(String id) => '${alert(id)}/share';

  static String? filterCategoryNotice(String category) => '$_notices/category/$category';
  // User routes
  static const users = _users;
  static String user(String id) => '$_users/$id';
  static String updateUserStatus(String id) => '${user(id)}/status';
  static String updateUser(String id) => user(id);
  static String deleteUser(String id) => '$_auth/users/$id';

  // Notice routes
  static const notices = _notices;
  static const adverts = _adverts;
  static const advertsFeature = '$_adverts/featured';
  static const advertsPublic = '$_adverts/public';
  static String advert(String id) => '$_adverts/$id';

} 