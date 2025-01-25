import '../app.dart';
import '../constants/app/app_constant.dart';
import '../constants/app/http_url.dart';
import '../constants/enum/general_enum.dart';
import 'bootstrap/bootstrap.dart';

/// product ortamı
///
/// COMMAND LINE örneği
/// flutter run --flavor product lib/app/main/main_fatura.dart
/// flutter build apk --release --flavor product lib/app/main/main_fatura.dart
/// flutter build appbundle --release --flavor fatura lib/app/main/main_fatura.dart
void main() {
  environment = AppEnvironment.Production;
  HttpUrl.baseUrl = 'https://bymfatura.com';

  bootstrap(
    'https://api.example.com/log',
    const App(title: 'BYM Fatura'),
  );
}
