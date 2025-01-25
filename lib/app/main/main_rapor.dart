import '../app.dart';
import '../constants/app/app_constant.dart';
import '../constants/app/http_url.dart';
import '../constants/enum/general_enum.dart';
import 'bootstrap/bootstrap.dart';

/// Development ortamı
///
/// COMMAND LINE örneği
/// flutter run --flavor development lib/app/main/main_rapor.dart
/// flutter build appbundle --release --flavor rapor lib/app/main/main_rapor.dart
void main() {
  environment = AppEnvironment.Development;
  HttpUrl.baseUrl = 'https://bi.bym.net.tr';

  bootstrap(
    'https://api.example.dev/log',
    const App(title: 'BYM Rapor'),
  );
}
