import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StaticFunctions{

  static String getTimeStampV1 (Timestamp timestamp){
    DateFormat formatter = DateFormat('dd-MM-yyyy');
    if( _isSameDate(timestamp.toDate())){
      formatter=DateFormat.Hm() ;
    }
    return formatter.format(timestamp.toDate());
  }
  static bool _isSameDate(DateTime other) {
    var today =Timestamp.now().toDate();
    return today.year == other.year && today.month == other.month
           && today.day == other.day;
  }
  static String getTimeStampV2 (Timestamp timestamp){
    DateFormat formatter =DateFormat.Hm();
    return formatter.format(timestamp.toDate());
  }  
  static String getTimeStampV3 (Timestamp timestamp){
    DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(timestamp.toDate());
  }
  static String getDateTimeV1(DateTime dateTime){
    DateFormat formatter = DateFormat.yMMMd();
    return formatter.format(dateTime);
  }
  static String getDateFormatForCompare(Timestamp timestamp){
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(timestamp.toDate());
  }

}
