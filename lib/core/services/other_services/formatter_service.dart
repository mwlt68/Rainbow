import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FormatterService{

  //getTimeStampV1
  String getDateTimeCompareToday_ddMMyyyy  (Timestamp timestamp){
    DateFormat formatter = DateFormat('dd-MM-yyyy');
    if( _isSameDate(timestamp.toDate())){
      formatter=DateFormat.Hm() ;
    }
    return formatter.format(timestamp.toDate());
  }
  //getTimeStampV2
  String getDateTime_Hm (Timestamp timestamp){
    DateFormat formatter =DateFormat.Hm();
    return formatter.format(timestamp.toDate());
  }
  //getTimeStampV3 
  String getDateTime_ddMMyyyy  (Timestamp timestamp){
    DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(timestamp.toDate());
  }

  //getDateTimeV1
  String getDateTime_yMMMd(DateTime dateTime){
    DateFormat formatter = DateFormat.yMMMd();
    return formatter.format(dateTime);
  }
  
  String getDateFormatForCompare(Timestamp timestamp){
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(timestamp.toDate());
  }


  bool _isSameDate(DateTime other) {
    var today =Timestamp.now().toDate();
    return today.year == other.year && today.month == other.month
           && today.day == other.day;
  }
}