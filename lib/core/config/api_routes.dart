class ApiRoutes {
  static const _auth = '/api/auth';
  static const _alerts = '/api/alerts';
  static const _notices = '/api/news';
  static const _users = '/api/users';
  // Auth routes
  static const register = '$_auth/register';
  static const login = '$_auth/login';
  static const logout = '$_auth/logout';
  static const deviceToken = '$_auth/device-token';
  static const me = '$_auth/me';

  // Alert routes
  static const alerts = _alerts;
  static String alert(String id) => '$_alerts/$id';
  static String markAsRead(String id) => '${alert(id)}/read';
  static String archiveAlert(String id) => alert(id);
  static String unarchiveAlert(String id) => '${alert(id)}/unarchive';
  static String shareAlert(String id) => '${alert(id)}/share';

  // User routes
  static const users = _users;
  static String user(String id) => '$_users/$id';
  static String updateUserStatus(String id) => '${user(id)}/status';
  static String updateUser(String id) => user(id);
  static String deleteUser(String id) => '$_auth/users/$id';

  // Notice routes

  static const notices = _notices;

} 