import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rainbow/core/models/user.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _didChange=false;
  TextEditingController _nameTEC;
  String _statusText =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris elementum felis lectus. Vestibulum porttitor nulla turpis, sed tempor diam erat.";
  @override
  void initState() {
    super.initState();
    _nameTEC = new TextEditingController();
    _nameTEC.text = "Mevlüt";
  }

  @override
  Widget build(BuildContext context) {
    Color _themeColor = Theme.of(context).primaryColor;

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: _themeColor,
        actions: [
          Visibility(
            visible: _didChange,
            child: Container(
              margin: EdgeInsets.all(10),
              child: FlatButton(
                color: Theme.of(context).accentColor,
                onPressed: (){

                },
                child: Text(
                  "Kaydet",
                  style: TextStyle(color:Colors.white),
                ),
              ),
            )
          )
        ],
      ),
      body: Container(
        color: Color.fromRGBO(238, 238, 238, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundImage:
                        NetworkImage("https://picsum.photos/200/300"),
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                        backgroundColor: _themeColor,
                      ))
                ],
                overflow: Overflow.visible,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: TextField(
                onChanged: (val){
                  setState(() {
                    _didChange=true;
                  });
                },
                controller: _nameTEC,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    hintText: 'İsminizi Giriniz'),
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Bu bir kullanıcı adı değildir.Bu isim sadece kişilerin görebilecektir.",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.7,
                  ),
                )),
            GestureDetector(
              onTap: () async {
                String result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SetStatus(_statusText)),
                );
                if(result != null && result.length > 0){
                  setState(() {
                    _didChange=true;
                    _statusText=result;
                  });
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                color: Colors.white,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: Text(
                          _statusText,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.7,
                            wordSpacing: 0.7,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    IconButton(icon: Icon(Icons.arrow_right))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SetStatus extends StatefulWidget {
  String statusText;
  SetStatus(this.statusText);

  @override
  _SetStatusState createState() => _SetStatusState();
}

class _SetStatusState extends State<SetStatus> {
  TextEditingController _statusTEC;
  @override
  void initState() {
    super.initState();
    _statusTEC = new TextEditingController();
    _statusTEC.text=this.widget.statusText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Hakkımda"),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          Container(
            margin: EdgeInsets.all(10),
            child: FlatButton(
              color: Theme.of(context).accentColor,
              child: Text(
                "Tamam",
                style: TextStyle(
                  color: Colors.white
                ),
              ),
              onPressed: () {
                Navigator.pop(context, _statusTEC.text);
              },
            ),
          ),
        ],
      ),
      body: Container(
        color:Color.fromRGBO(238, 238, 238, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: TextField(
                controller: _statusTEC,
                maxLines: 3,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(MyUser.StatusTextLength),
                ],
                maxLength: MyUser.StatusTextLength,
                decoration: InputDecoration(
                  border:InputBorder.none,
                  fillColor: Colors.white,
                  filled: true,

                ),
              ),
            ),
            _getStatusOption("Meşgul"),
            _getStatusOption("İşte"),
            _getStatusOption("Evde"),
            _getStatusOption("Kod Yazıyor..."),
          ],
        ),
      ),
    );
  }

  Widget _getStatusOption(String optionName) {
    return GestureDetector(
      onTap: () {
        _statusTEC.text = optionName;
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.only(left:10),
        color: Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                optionName,
                overflow: TextOverflow.clip,
                maxLines: 3,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.7,
                  wordSpacing: 0.7,
                  height: 1.3,
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}
