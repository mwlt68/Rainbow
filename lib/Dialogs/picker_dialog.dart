import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';



class PickerPage extends StatefulWidget {
  @override
  _PickerPageState createState() => _PickerPageState();
}

class _PickerPageState extends State<PickerPage> {
    File _file;

  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}