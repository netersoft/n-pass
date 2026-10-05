import 'dart:io';

class UnsecureHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
}

void unsecureHttp() => HttpOverrides.global = UnsecureHttpOverrides();
