import 'dart:ui';

class DefaultData {
  static const String AppName="Rainbow";
  static const String VerifyTitle="Verify your phone number";
  static const String VerifyMessage= AppName + " will send an SMS message to verify your phone number.Enter your country code and phone number :";
  static const String InitialCountryCode="+90";
  static const String UserDefaultImagePath="https://odtukaltev.com.tr/wp-content/uploads/2018/04/person-placeholder-300x300.jpg";
  static const String PhoneNumber="Phone Number";
  //User Register Page
  static const String UserDefaultStatus="Hey there,I am using Rainbow";
  static const String UserRegister="User Register";
  static const String VisiableName="Visiable Name";
  static const String Status="Status";
  static const String TECInvalidText=UserRegister+" or "+VisiableName+" can not blank !";
  // Contact Page
  static const ElementNotFound ="An element matching your search was not found.";
  //Shared Preferences
  static const String SPUserIdKey="UserId";
  // Validater Hint Texts
  static const String ValPhoNumChar='Phone number must equal 10 characters !';
  // Firebase Collection Headers
  static const String ProfileImage="profileImage";
  // Message Page
  static const String MessageMedia="messageMedia";
  // Conversation Page 
  static const String AnImage="An Image";
  // User Detail
  static const String Name="Name";
  static const String Phone="Phone";
  // Group Detail
  static const String GroupCreateDate="Group Create Date";
}
class DefaultColors{
  static const Color DarkBlue=Color.fromRGBO(52, 57, 86,1);
  static const Color BlueAndGrey=Color.fromRGBO(127, 132, 160,1);
  static const Color Yellow=Color.fromRGBO(247, 196, 37,1);
  static const Color YellowLowOpacity=Color.fromRGBO(247, 196, 37,0.75);
}