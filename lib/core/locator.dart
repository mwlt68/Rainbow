import 'package:get_it/get_it.dart';
import 'package:rainbow/core/services/firebase_services/conversation_service.dart';
import 'package:rainbow/core/services/firebase_services/message_service.dart';
import 'package:rainbow/core/services/other_services/navigator_service.dart';
import 'package:rainbow/core/services/firebase_services/storage_service.dart';
import 'package:rainbow/core/services/firebase_services/user_service.dart';
import 'package:rainbow/core/core_view_models/core_contact_view_model.dart';
import 'package:rainbow/core/core_view_models/core_conversation_view_model.dart';
import 'package:rainbow/core/core_view_models/core_message_view_model.dart';
import 'package:rainbow/core/core_view_models/core_user_view_model.dart';

GetIt getIt =  GetIt.instance;
setupLocator(){
  getIt.registerLazySingleton(() => ConversationService());
  getIt.registerLazySingleton(() => UserService());
  getIt.registerLazySingleton(() => StorageService());
  getIt.registerLazySingleton(() => NavigatorService());
  getIt.registerLazySingleton(() => MessageService());

  getIt.registerFactory(() => ConversationViewModel());
  getIt.registerFactory(() => MessageViewModel());
  getIt.registerFactory(() => UserViewModel());
  getIt.registerFactory(() => ContactViewModel());
}