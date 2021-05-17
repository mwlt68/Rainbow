import 'package:rainbow/constants/color_constants.dart';
import 'package:rainbow/constants/int_constants.dart';
import 'package:rainbow/constants/string_constants.dart';
import 'package:rainbow/constants/format_language_strings_constants.dart';
import 'package:rainbow/constants/font_family_string_constants.dart';
abstract class BaseState{

  StringConstants stringConsts =StringConstants.instance;
  ColorConstants colorConsts = ColorConstants.instance;
  FontFamilyStringConstants fontFamilyStrConsts = FontFamilyStringConstants.instance;
  FormatLanguageStringConstants formatLanguageStrConsts= FormatLanguageStringConstants.instance;
  IntConstants intConstants= IntConstants.instance;

}