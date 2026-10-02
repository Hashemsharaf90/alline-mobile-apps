import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/data/api/api_checker.dart';
import 'package:sixvalley_delivery_boy/features/auth/domain/models/response_model.dart';
import 'package:sixvalley_delivery_boy/features/chat/controllers/chat_controller.dart';
import 'package:sixvalley_delivery_boy/features/chat/domain/models/chat_model.dart';
import 'package:sixvalley_delivery_boy/features/chat/domain/repositories/chat_repository_interface.dart';
import 'package:sixvalley_delivery_boy/features/chat/domain/services/chat_service_interface.dart';

class ChatService implements ChatServiceInterface{
  ChatRepositoryInterface chatRepoInterface;
  ChatService({required this.chatRepoInterface});

  @override
  Future getConversationList(offset, userTypeIndex) async{
    return chatRepoInterface.getConversationList(offset, userTypeIndex);
  }

  @override
  Future getChatList(offset, userId) async{
    String userType = 'admin';
    if(userId == 0){
      userType = 'admin';
    }else{
      userType = Get.find<ChatController>().userTypeIndex == 0 ? 'seller' : Get.find<ChatController>().userTypeIndex == 1? "customer" : "admin";
    }
    return chatRepoInterface.getChatList(offset, userType, userId);
  }

  @override
  Future searchChatList(userTypeIndex, searchChat) async{
    Response response = await chatRepoInterface.searchChatList(userTypeIndex, searchChat);
    ChatModel conversationModel = ChatModel(totalSize: 1, limit: '1', offset: '1', chat: []);
    if(response.statusCode == 200) {
      conversationModel = ChatModel(totalSize: 1, limit: '1', offset: '1', chat: []);
      response.body.forEach((chat) {
        conversationModel.chat!.add(Chat.fromJson(chat));
      });
    }else {
      ApiChecker.checkApi(response);
      return null;
    }
    return conversationModel;
  }

  @override
  Future sendMessage(message, userId, files, platformFile) async{
    String userType = 'admin';
    if(userId == 0){
      userType = 'admin';
    }else{
      userType = Get.find<ChatController>().userTypeIndex == 0 ? 'seller' : Get.find<ChatController>().userTypeIndex == 1? "customer" : "admin";
    }
    Response response = await chatRepoInterface.sendMessage(message, userId, userType, files, platformFile);
    if (response.statusCode == 200) {
      return ResponseModel(true, '');
    }else{
      return ResponseModel(false, '');
    }
  }

  @override
  Future searchConversationList(String name) async {
    return chatRepoInterface.searchConversationList(name);
  }
}