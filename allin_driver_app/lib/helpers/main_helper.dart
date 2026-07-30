import 'package:active_flutter_delivery_app/app_config.dart';
import 'package:active_flutter_delivery_app/helpers/shared_value_helper.dart';

Map<String, String> get commonHeader => {
      "Content-Type": "application/json",
      "App-Language": app_language.$!,
      "Accept": "application/json",
      "System-Key": AppConfig.system_key
    };
