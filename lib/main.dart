import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unico_check/unico_check.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'unico check',
      theme: ThemeData(
        primaryColor: Colors.grey[100],
        hintColor: Colors.blue.shade600,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(color: Colors.black87),
          titleMedium: TextStyle(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      home: const MyHomePage(title: 'unico | check'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    implements UnicoListener, UnicoSelfie, UnicoDocument {
  late UnicoCheckBuilder _unicoCheck;
  late UnicoCheckCameraOpener _opener;

  final List<String> _logs = [];
  String _centralStatusMessage = "Pronto para iniciar a biometria.";

  final _theme = UnicoTheme(
      colorSilhouetteSuccess: "#4ca832",
      colorSilhouetteError: "#fcdb03",
      colorBackground: "#3295a8");

  final _configIos = UnicoConfig(
      getBundleIdentifier: "YOUR_BUNDLE_IDENTIFIER_IOS",
      getHostKey: "YOUR_SDK_KEY_IOS");

  final _configAndroid = UnicoConfig(
      getBundleIdentifier: "YOUR_BUNDLE_IDENTIFIER_ANDROID",
      getHostKey: "YOUR_SDK_KEY_ANDROID");

  @override
  void initState() {
    super.initState();
    _addLog("App inicializado.");
    initUnicoCamera();
    configUnicoCamera();
  }

  void _addLog(String message) {
    log(message);
    setState(() {
      _logs.add("${DateTime.now().toIso8601String().substring(11, 19)}: $message");
      if (_logs.length > 100) {
        _logs.removeAt(0);
      }
    });
  }

  void _updateCentralStatus(String message) {
    setState(() {
      _centralStatusMessage = message;
    });
    _addLog("Status Atualizado: $message");
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
      _logs.add("Logs limpos.");
    });
    log("Logs da tela limpos.");
  }

  void initUnicoCamera() {
    _addLog('Inicializando UnicoCheck.');
    _unicoCheck = UnicoCheck(
        listener: this,
        unicoConfigIos: _configIos,
        unicoConfigAndroid: _configAndroid);
  }

  void configUnicoCamera() {
    _addLog('Configurando UnicoCheck builder.');
    _unicoCheck
        .setTheme(unicoTheme: _theme)
        .setTimeoutSession(timeoutSession: 55)
        .setEnvironment(unicoEnvironment: UnicoEnvironment.UAT);
  }

  @override
  void onErrorDocument(UnicoError error) {
    _updateCentralStatus('Erro no documento: ${error.description}');
    _addLog('onErrorDocument: Erro no documento -> ${error.code} - ${error.description}');
  }

  @override
  void onErrorSelfie(UnicoError error) {
    _updateCentralStatus('Erro na selfie: ${error.description}');
    _addLog('onErrorSelfie: Erro na selfie -> ${error.code} - ${error.description}');
  }

  @override
  void onErrorUnico(UnicoError error) {
    _updateCentralStatus('Erro geral da SDK: ${error.description}');
    _addLog('onErrorUnico: Erro geral da SDK -> ${error.code} - ${error.description}');
  }

  @override
  void onSuccessDocument(ResultCamera resultCamera) {
    _updateCentralStatus('Documento capturado com sucesso!');
    _addLog('onSuccessDocument: Documento capturado com sucesso!');
      _addLog('onSuccessDocument: Encrypted JWT ->  [0m${resultCamera.encrypted!.substring(0, resultCamera.encrypted!.length > 50 ? 50 : resultCamera.encrypted!.length)}...');
  }

  @override
  void onSuccessSelfie(ResultCamera result) {
    _updateCentralStatus('Selfie capturada com sucesso!');
    _addLog('onSuccessSelfie: Selfie capturada com sucesso!');
    _addLog('onSuccessSelfie: Encrypted JWT ->  [0m${result.encrypted!.substring(0, result.encrypted!.length > 50 ? 50 : result.encrypted!.length)}...');
  }

  @override
  void onSystemChangedTypeCameraTimeoutFaceInference() {
    _updateCentralStatus('Timeout de inferência de face.');
    _addLog('onSystemChangedTypeCameraTimeoutFaceInference: Timeout de inferência de face.');
  }

  @override
  void onSystemClosedCameraTimeoutSession() {
    _updateCentralStatus('Sessão encerrada por timeout.');
    _addLog('onSystemClosedCameraTimeoutSession: Sessão encerrada por timeout.');
  }

  @override
  void onUserClosedCameraManually() {
    _updateCentralStatus('Usuário fechou a câmera manualmente.');
    _addLog('onUserClosedCameraManually: Usuário fechou a câmera manualmente.');
  }

  void setCameraSmart() {
    _addLog('setCameraSmart: Configurando câmera inteligente.');
    _opener = _unicoCheck
        .setAutoCapture(autoCapture: true)
        .setSmartFrame(smartFrame: true)
        .build();
  }

  void setCameraSmartWithButton() {
    _addLog('setCameraSmartWithButton: Configurando câmera smart com botão.');
    _opener = _unicoCheck
        .setAutoCapture(autoCapture: false)
        .setSmartFrame(smartFrame: true)
        .build();
  }

  void openCameraSelfieSmart() {
    _updateCentralStatus('Abrindo câmera de selfie inteligente...');
    _addLog('openCameraSelfieSmart: Abrindo câmera de selfie inteligente.');
    setCameraSmart();
    _opener.openCameraSelfie(listener: this);
  }

  void openCameraSelfieSmartWithButton() {
    _updateCentralStatus('Abrindo câmera de selfie smart com botão...');
    _addLog('openCameraSelfieSmartWithButton: Abrindo câmera de selfie smart com botão.');
    setCameraSmartWithButton();
    _opener.openCameraSelfie(listener: this);
  }

  void openCameraDocumentCNHFront() {
    _updateCentralStatus('Abrindo câmera CNH Frente...');
    _addLog('openCameraDocumentCNHFront: Abrindo câmera CNH Frente.');
    _unicoCheck.build().openCameraDocument(
        documentType: DocumentType.CNH_FRENTE, listener: this);
  }

  void openCameraDocumentCNHVerso() {
    _updateCentralStatus('Abrindo câmera CNH Verso...');
    _addLog('openCameraDocumentCNHVerso: Abrindo câmera CNH Verso.');
    _unicoCheck.build().openCameraDocument(
        documentType: DocumentType.CNH_VERSO, listener: this);
  }

  void openCameraDocumentRGFront() {
    _updateCentralStatus('Abrindo câmera RG Frente...');
    _addLog('openCameraDocumentRGFront: Abrindo câmera RG Frente.');
    _unicoCheck.build().openCameraDocument(
        documentType: DocumentType.RG_FRENTE, listener: this);
  }

  void openCameraDocumentRGVerso() {
    _updateCentralStatus('Abrindo câmera RG Verso...');
    _addLog('openCameraDocumentRGVerso: Abrindo câmera RG Verso.');
    _unicoCheck.build().openCameraDocument(
        documentType: DocumentType.RG_VERSO, listener: this);
  }

  void openCameraDocumentCPF() {
    _updateCentralStatus('Abrindo câmera CPF...');
    _addLog('openCameraDocumentCPF: Abrindo câmera CPF.');
    _unicoCheck
        .build()
        .openCameraDocument(documentType: DocumentType.CPF, listener: this);
  }

  @override
  Widget build(BuildContext context) {
    const logContainerHeight = 200.0; 

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
       
          const SizedBox(height: 30),
          Center(
            child: Image.asset(
              'assets/images/unicologo.png', 
              width: 150, 
              height: 70, 
              fit: BoxFit.contain, 
            ),
          ),
          const SizedBox(height: 20),

          // --- Log Centralizado Superior ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Status:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _centralStatusMessage,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).hintColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
      
          Flexible(
            fit: FlexFit.tight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
              
                  Text(
                    'Câmera para Selfie:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  _buildIOSButton(context, '(Auto Capture)', openCameraSelfieSmart),
                  const SizedBox(height: 10),
                  _buildIOSButton(context, '(Manual Capture)', openCameraSelfieSmartWithButton),
                  
                  const SizedBox(height: 20),

                  
                  Text(
                    'Câmera para Documentos:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      _buildIOSDocumentButton(context, 'CNH Frente', openCameraDocumentCNHFront),
                      _buildIOSDocumentButton(context, 'CNH Verso', openCameraDocumentCNHVerso),
                      _buildIOSDocumentButton(context, 'RG Frente', openCameraDocumentRGFront),
                      _buildIOSDocumentButton(context, 'RG Verso', openCameraDocumentRGVerso),
                      _buildIOSDocumentButton(context, 'CPF', openCameraDocumentCPF),
                    ],
                  ),
                ],
              ),
            ),
          ),

         
          Container(
            height: logContainerHeight,
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Logs do Aplicativo:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _clearLogs,
                      child: Text('Limpar', style: TextStyle(color: Theme.of(context).hintColor)),
                    ),
                  ],
                ),
                const Divider(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          _logs[index],
                          style: const TextStyle(fontSize: 12, color: Colors.black54, fontFamily: 'monospace'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildIOSButton(BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).primaryTextTheme.labelLarge?.color,
        backgroundColor: Theme.of(context).hintColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.white)),
    );
  }

  
  Widget _buildIOSDocumentButton(BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black87,
        backgroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        minimumSize: const Size(140, 0),
        elevation: 0,
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}