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
}