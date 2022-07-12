import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unico_check/unico_check.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'unico check',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF8d7ad2),
        ),
      ),
      home: MyHomePage(title: 'unico | check'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    implements UnicoListener, UnicoSelfie, UnicoDocument {
  late UnicoCheckBuilder _unicoCheck;
  late UnicoCheckCameraOpener _opener;

  final _theme = UnicoTheme(
      colorSilhouetteSuccess: "#4ca832",
      colorSilhouetteError: "#fcdb03",
      colorBackground: "#3295a8");

  final _configIos = UnicoConfig(
      getProjectNumber: "81503569192742919497605725",
      getProjectId: "flutter_poc3",
      getMobileSdkAppId: "2:29066:ios",
      getBundleIdentifier: "com.example.pocFlutter3",
      getHostInfo:
          "B+2O5141Qrvr9FcK3Z4a1iQeyPQEYHCvJ6IkN4JNpNzYisHkI9wo21bQ1juBi6Rx",
      getHostKey:
          "+1WJG40kwasvlpqtFi391NuOY+lba72Sc/qvkO2+JZm3tO4n6FsYcj/yFKAGSwue");

  final _configAndroid = UnicoConfig(
      getProjectNumber: "58022533341712409503",
      getProjectId: "unico-sdk-poc-flutter",
      getMobileSdkAppId: "1:34278:android",
      getBundleIdentifier: "com.example.unico_sdk_poc_flutter",
      getHostInfo:
          "B+2O5141Qrvr9FcK3Z4a1iQeyPQEYHCvJ6IkN4JNpNzYisHkI9wo21bQ1juBi6Rx",
      getHostKey:
          "1GqADFTKMoYpWAvGRCUjg+udoECocjOxmXu+BuRhtrieOdqDNHew4j2TJeyWsWSj");

  @override
  void initState() {
    super.initState();
    initUnicoCamera();
    configUnicoCamera();
  }

  void initUnicoCamera() {
    _unicoCheck = UnicoCheck(
        listener: this,
        unicoConfigIos: _configIos,
        unicoConfigAndroid: _configAndroid);
  }

  void configUnicoCamera() {
    _unicoCheck
        .setTheme(unicoTheme: _theme)
        .setTimeoutSession(timeoutSession: 55);
  }

  @override
  void onErrorDocument(UnicoError error) {
    showToast("Erro ao abrir a camera: ${error.description}");
  }

  @override
  void onErrorSelfie(UnicoError error) {
    showToast("Erro ao abrir a camera: ${error.description}");
  }

  @override
  void onErrorUnico(UnicoError error) {
    showToast("Erro ao abrir a camera: ${error.description}");
  }

  @override
  void onSuccessDocument(ResultCamera resultCamera) {
    showToast("Sucesso na captura ");
  }

  @override
  void onSuccessSelfie(ResultCamera result) {
    showToast("Sucesso na captura, aqui temos o base64 e encrypted ");
    log(result.encrypted.toString());
  }

  @override
  void onSystemChangedTypeCameraTimeoutFaceInference() {
    showToast("Sistema trocou o tipo da camera !");
  }

  @override
  void onSystemClosedCameraTimeoutSession() {
    showToast("Sistema fechou a camera !");
  }

  @override
  void onUserClosedCameraManually() {
    showToast("Usuario fechou camera manualmente !");
  }

  void setCameraSmart() {
    _opener = _unicoCheck
        .setAutoCapture(autoCapture: true)
        .setSmartFrame(smartFrame: true)
        .build();
  }

  void setCameraNormal() {
    _opener = _unicoCheck
        .setAutoCapture(autoCapture: false)
        .setSmartFrame(smartFrame: false)
        .build();
  }

  void setCameraSmartWithButton() {
    _opener = _unicoCheck
        .setAutoCapture(autoCapture: false)
        .setSmartFrame(smartFrame: true)
        .build();
  }

  void openCamera() {
    setCameraSmart();
    _opener.openCameraSelfie(listener: this);
  }

  void openCameraNormal() {
    setCameraNormal();
    _opener.openCameraSelfie(listener: this);
  }

  void openCameraSmartWithButton() {
    setCameraSmartWithButton();
    _opener.openCameraSelfie(listener: this);
  }

  void openCameraDocumentCNH() {
    _unicoCheck
        .build()
        .openCameraDocument(documentType: DocumentType.CNH, listener: this);
  }

  void openCameraDocumentCNHFront() {
    _unicoCheck.build().openCameraDocument(
        documentType: DocumentType.CNH_FRENTE, listener: this);
  }

  void openCameraDocumentCNHVerso() {
    _unicoCheck.build().openCameraDocument(
        documentType: DocumentType.CNH_VERSO, listener: this);
  }

  void openCameraDocumentRGFront() {
    _unicoCheck.build().openCameraDocument(
        documentType: DocumentType.RG_FRENTE, listener: this);
  }

  void openCameraDocumentRGVerso() {
    _unicoCheck.build().openCameraDocument(
        documentType: DocumentType.RG_VERSO, listener: this);
  }

  void openCameraDocumentCPF() {
    _unicoCheck
        .build()
        .openCameraDocument(documentType: DocumentType.CPF, listener: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: const Center(
                child: Text(
                  'Bem-vindo a poc do unico | check !',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(25),
              child: const Text(
                'Teste agora nossa tecnologia:',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              child: const Text(
                'Camera para selfie:',
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: TextButton(
                onPressed: openCameraNormal,
                child: const Text('Camera normal'),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: TextButton(
                onPressed: openCamera,
                child: const Text('Camera inteligente'),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: TextButton(
                onPressed: openCameraSmartWithButton,
                child: const Text('Camera smart button'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              child: const Text(
                'Camera para documentos:',
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: TextButton(
                  onPressed: openCameraDocumentCNH,
                  child: const Text('Documentos CNH')),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: TextButton(
                onPressed: openCameraDocumentCNHFront,
                child: const Text('Documentos CNH Frente'),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: TextButton(
                onPressed: openCameraDocumentCNHVerso,
                child: const Text('Documentos CNH Verso'),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: TextButton(
                onPressed: openCameraDocumentRGVerso,
                child: const Text('Documentos RG Frente'),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: TextButton(
                onPressed: openCameraDocumentRGVerso,
                child: const Text('Documentos RG verso'),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: TextButton(
                onPressed: openCameraDocumentCPF,
                child: const Text('Documentos CPF'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.amber,
      fontSize: 14,
    );
  }
}
