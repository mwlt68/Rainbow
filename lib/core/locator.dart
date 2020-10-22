import 'package:get_it/get_it.dart';
import 'package:rainbow/core/services/chat_service.dart';
import 'package:rainbow/viewmodels/chat_model.dart';

GetIt getIt =  GetIt.instance;
setupLocator(){
  getIt.registerLazySingleton(() => ChatService());
  getIt.registerFactory(() => ChatModel());
}