
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(230, 225, 221, 1),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  int contract_number = 0;
  QRViewController? controller;
  String _wallet_address = "";
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String initial_url = "";
  List<Image> images = [];
  Image? selectedImage = null;

  initState() {
    super.initState();
    contract_number = 0;
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    WebView.platform = SurfaceAndroidWebView();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 원하는 색
    ));
    this.initial_url = "";
  }

  void showLastConfirmDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: selectedImage,
                ),
                SizedBox(height: 30),
                Container(
                  child: Text("NFT 발급이 완료되었습니다.", style: TextStyle(color: Colors.white, fontSize: 35)),
                ),
                SizedBox(height: 15),
                Container(
                  child: Text("지갑에서 확인해보세요.", style: TextStyle(color: Colors.white, fontSize: 35)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showKakaopay(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 500,
                  height: 800,
                  child: WebView(
                    initialUrl: this.initial_url,
                    javascriptMode: JavascriptMode.unrestricted,
                    onPageFinished: (String url) {
                      // 주엽 4: 172.30.1.10
                      // 주엽 2: 172.30.1.77
                      if (url.startsWith('http://172.30.1.10:8080/payment/approve')) {
                        print('navigated to approval page');
                        Timer(const Duration(milliseconds: 5000), () {
                          Navigator.pop(context);
                          mint(_wallet_address);
                          showLastConfirmDialog(context);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void showConfirm(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: selectedImage,
                ),
                SizedBox(height: 30),
                Container(
                  child: Text(_wallet_address,
                      style: TextStyle(color: Colors.white, fontSize: 35)),
                ),
                SizedBox(height: 15),
                Container(
                  child: Text("확인되었습니다.", style: TextStyle(color: Colors.white, fontSize: 35)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> mint(String address) async {
    var jsondata = { "address": address, "contract_number": contract_number};
    var body = json.encode(jsondata);
    // 10.0.2.2
    final uri = "http://172.30.1.46:8080/mint";
    // final uri = "https://hedaservice.azurewebsites.net/mint";
    http.Response response = await http.post(
      Uri.parse(uri),
      headers: {"Content-Type": "application/json"},
      body: body
    );
    print(response);
    _wallet_address = "";
    return address;
  }

  Future<String> callKakaoAPI() async {
    final uri = "http://10.0.2.2:3000/kakaopay_ready";
    http.Response res = await http.post(
      Uri.parse(uri),
      headers: {"Content-Type": "application/json"},
      body: null
    );
    return res.body;
  }

  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    await controller.scannedDataStream.first.then((scanData) =>
    {
      _wallet_address = scanData.code,
      controller.stopCamera(),
      Navigator.pop(context),
      showConfirm(context),
      Timer(const Duration(milliseconds: 3000), () async {
        //var res = await callKakaoAPI();
        // setState(() {
        //   this.initial_url = res;
        // });
        await mint(_wallet_address);
        Navigator.pop(context);
        showLastConfirmDialog(context);
        //showKakaopay(context);
      }),
    });
  }

  void showScan(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 800,
                  height: 500,
                  //child: Image.asset("images/asset1.png", height: 600),
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                      cameraFacing: CameraFacing.front,
                      overlay: QrScannerOverlayShape(
                        borderRadius: 10,
                        borderColor: Colors.yellow,
                        borderLength: 30,
                        borderWidth: 10,
                        cutOutSize: 400,
                      ),
                    ),

                    // child: RotatedBox(
                    // quarterTurns: 3,

                  // )
                ),
                //SizedBox(height: 30),
                //Container(
                //  child: Text(_wallet_address.toString(),
                //      style: TextStyle(color: Colors.white, fontSize: 35)),
                //),
                SizedBox(height: 30),
                Container(
                  child: Text("NFT를 받으실 클레이튼 지갑 주소 QR코드를 보여주세요.", style: TextStyle(color: Colors.white, fontSize: 35)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showConfirmDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: selectedImage,
                  // child: Image.asset("images/asset1.png", height: 600),
                ),
                SizedBox(height: 30),
                TextButton(
                  child: Image.asset("images/receive_nft_button.png"),
                  onPressed: () {
                    Navigator.pop(context);
                    showScan(context);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void permission() async {
    Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.camera]);
    print('per1 : $permissions');
  }

  List<Widget> getImageList() {
    final children = <Widget>[];
    for (var i = 0; i < images.length; i++) {
      children.add(
        GestureDetector(
          onTap: () {
            setState(() => {
              selectedImage = images[i],
              contract_number = i + 1
            });
            showConfirmDialog(context);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: images[i],
          ),
        )
      );
      if (i != images.length - 1)
        children.add(SizedBox(width: 80));
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {

    permission();
    images.clear();
    images.add(Image.asset("images/kawaji_NFT.png", height: 500));
    images.add(Image.asset("images/kawaji_NFT2.png", height: 500));
    images.add(Image.asset("images/kawaji_NFT3.png", height: 500));
    images.add(Image.asset("images/kawaji_NFT4.png", height: 500));
    // images.add(Image.asset("images/restinagarden.jpg", height: 500));
    // images.add(Image.asset("images/rinen.jpg", height: 500));
    // images.add(Image.asset("images/bommajung.jpg", height: 500));

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.



    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromRGBO(230, 225, 221, 1),
          bottom: PreferredSize(
            child: Container(
              color: const Color.fromRGBO(167, 42, 27, 0.65),
              height: 4.0,
            ),
            preferredSize: Size.fromHeight(3.0),
          ),
          toolbarHeight: 142.5,
          flexibleSpace: Container(
            child: Stack(
                children: <Widget>[
                  Positioned(
                    // left: 242.5, top: 40
                      left: 350, top: 20, child:
                  Image.asset('images/kawaji_logo.png', height: 100)
                  ),
                  Positioned(
                      right: 350, top: 40, child:
                  Image.asset('images/heda.png', height: 60)
                  )
                ]
            ),
          ),
        ),
        body: Container(
            color: const Color.fromRGBO(230, 225, 221, 0.6),
            padding: EdgeInsets.symmetric(vertical: 63, horizontal: 53.5),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: getImageList(),
            )

        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            decoration: BoxDecoration(
                color: const Color.fromRGBO(230, 225, 221, 1),
                border: Border(top: BorderSide( color: const Color.fromRGBO(167, 42, 27, 0.65), width: 3.0))
            ),
            height: 142.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("원하시는 NFT를 클릭하세요.",
                  style: TextStyle(
                    fontFamily: 'HangeulNuri',
                    fontSize: 26,
                    color: const Color.fromRGBO(17, 56, 99, 1)
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
    );
  }
}