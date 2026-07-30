import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';

class AiChatRepository {
  final DioClient dioClient;
  AiChatRepository({required this.dioClient});

  Future<Map<String, dynamic>> sendMessage({required String message, int? sessionId}) async {
    final response = await dioClient.post(AppConstants.aiChatSendUri, data: {
      'message': message,
      if (sessionId != null) 'session_id': sessionId,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<dynamic>> getMessages(int sessionId) async {
    final response = await dioClient.get('${AppConstants.aiChatSessionsUri}/$sessionId/messages');
    return List<dynamic>.from((response.data as Map)['messages'] ?? []);
  }
}
