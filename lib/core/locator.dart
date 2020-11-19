import 'package:get_it/get_it.dart';
import 'package:rainbow/core/services/conversation_service.dart';
import 'package:rainbow/core/services/message_service.dart';
import 'package:rainbow/core/services/navigator_service.dart';
import 'package:rainbow/core/services/storage_service.dart';
import 'package:rainbow/core/services/user_service.dart';
import 'package:rainbow/core/viewmodels/contact_model.dart';
import 'package:rainbow/core/viewmodels/convertation_model.dart';
import 'package:rainbow/core/viewmodels/message_model.dart';
import 'package:rainbow/core/viewmodels/user_model.dart';

GetIt getIt =  GetIt.instance;
setupLocator(){
  getIt.registerLazySingleton(() => ConversationService());
  getIt.registerLazySingleton(() => UserService());
  getIt.registerLazySingleton(() => StorageService());
  getIt.registerLazySingleton(() => NavigatorService());
  getIt.registerLazySingleton(() => MessageService());

  getIt.registerFactory(() => ConversationModel());
  getIt.registerFactory(() => MessageModel());
  getIt.registerFactory(() => UserModel());
  getIt.registerFactory(() => ContactModel());
}