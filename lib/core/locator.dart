import 'package:get_it/get_it.dart';
import 'package:rainbow/core/services/chat_service.dart';
import 'package:rainbow/core/services/storage_service.dart';
import 'package:rainbow/core/services/user_info_service.dart';
import 'package:rainbow/viewmodels/chat_model.dart';

GetIt getIt =  GetIt.instance;
setupLocator(){
  getIt.registerLazySingleton(() => ChatService());
  getIt.registerLazySingleton(() => UserInfoService());
  getIt.registerFactory(() => ChatModel());
  getIt.registerLazySingleton(() => StorageService());
}