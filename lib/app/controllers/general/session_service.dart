import 'package:get/get.dart';
import '../../model/response/auth/user_info_model.dart';

/*
Uygulamada ziyaretçinin ya da üyenin aktif tüm oturum bilgileri yer alacak:
- SessionId (Cihaza Özel)
- Token (Oturuma özel)
- Seçtiği adres
- Üye modeli
 */

class SessionService extends GetxController {
  final Rx<UserInfoModel> _currentUser = UserInfoModel().obs;
  final Rx<bool?> _loggedIn = Rx(null);
  String? _token;

  UserInfoModel get currentUser => _currentUser.value;

  set currentUser(UserInfoModel value) {
    _currentUser.firstRebuild = true;
    _currentUser.value = value;
  }

  String? getUserToken() {
    return _token;
  }

  Future<void> setUserToken(String value) async {
    _token = value;
  }

  /// Kullanıcının authentice olup olmadığını local de kontrol eder auth ise true döner
  bool isUserLogin() {
    if (_loggedIn.value == null) {
    }
    return _loggedIn.value!;
  }

  Future<void> setLoggedIn(bool value) async {
    _loggedIn.value = value;
  }

  /// Kullanıcı çıkış yaptığında çağırılır.
  Future<void> logOut() async {
    await Future.wait([
      setLoggedIn(false),
    ]);
    currentUser = UserInfoModel();
  }

  /// Kullanıcı giriş yapılıdığında çağırılır
  Future<void> logIn(GetUserInfoModel _currentUser) async {
    currentUser = _currentUser.data!;
    await Future.wait([
      setLoggedIn(true),
      setUserToken(_currentUser.token!),
    ]);
  }
}
