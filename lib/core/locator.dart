import 'package:get_it/get_it.dart';
import 'package:rainbow/core/services/firestore_db.dart';
import 'package:rainbow/viewmodels/chat_model.dart';

GetIt getIt =  GetIt.instance;
setupLocator(){
  getIt.registerLazySingleton(() => FirestoreDb());
  getIt.registerFactory(() => ChatModel());
}