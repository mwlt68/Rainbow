import 'package:get_it/get_it.dart';
import 'package:rainbow/core/services/chat_service.dart';
import 'package:rainbow/core/services/navigator_service.dart';
import 'package:rainbow/core/services/storage_service.dart';
import 'package:rainbow/core/services/user_service.dart';
import 'package:rainbow/viewmodels/chat_model.dart';
import 'package:rainbow/viewmodels/contact_model.dart';
import 'package:rainbow/viewmodels/user_model.dart';

GetIt getIt =  GetIt.instance;
setupLocator(){
  getIt.registerLazySingleton(() => ChatService());
  getIt.registerLazySingleton(() => UserService());
  getIt.registerLazySingleton(() => StorageService());
  getIt.registerLazySingleton(() => NavigatorService());

  getIt.registerFactory(() => ChatModel());
  getIt.registerFactory(() => UserModel());
  getIt.registerFactory(() => ContactModel());
}