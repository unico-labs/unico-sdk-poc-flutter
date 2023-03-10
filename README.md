<p align='center'>
  <a href='https://unico.io'>
    <img width='350' src='https://unico.io/wp-content/uploads/2022/07/check.svg'></img>
  </a>
</p>

<h1 align='center'>SDK Flutter</h1>

<div align='center'>
  
  ### POC de implementação do SDK unico | check em Flutter
  
  ![SDK](https://img.shields.io/badge/SDK-v3.0.7-blueviolet?logo=)
  ![FLUTTER](https://img.shields.io/badge/Flutter-blue?logo=flutter)
</div>

## 💻 Compatibilidade

### Versões

![ANDROID](https://img.shields.io/badge/Android-grey?logo=android)
![IOS](https://img.shields.io/badge/iOS-grey?logo=apple)

- Android: Versão mínima do Android 5.0 (API de nível 21)
- iOS: Versão mínima do iOS 11

### Dispositivos compatíveis

- Android: Você pode conferior os aparelhos testados em nossos laboratórios <a href='https://developers.unico.io/docs/check/guias/android/overview#dispositivos-compat%C3%ADveis'>nesta</a> lista de dispositivos.

- iOS: Você pode conferir a lista com esses dispositivos nos <a href='https://support.apple.com/pt-br/HT209574'>canais de suporte</a> oficiais da Apple.

## ✨ Como começar

### Ambiente de desenvolvimento & Credenciais Unico

- Primeiramente, você deve ter certeza que seu ambiente de desenvolvimento possuir o Developer SDK do <a href='https://docs.flutter.dev/get-started/install'>Flutter</a> instalado.
- Para utilizar nossos SDKs, você deve importar as credenciais unico (Client API Key) em seu projeto. Utilize <a href='https://developers.unico.io/docs/check/guias/flutter/como-comecar#obtendo-suas-credenciais'>este</a> passo a passo para gerar as credenciais.

Depois de configurar a API Key e obter o bundle da SDK iOS ou Android com os dados JSON, basta informá-los como parâmetros ao instanciar a interface `UnicoCheck`. Os parâmetros deverão ser enviados como objetos, gerados a partir do método `UnicoConfig`.

Segue o exemplo abaixo:

```
final _configIos = UnicoConfig(
  getProjectNumber: "Your ProjectNumber Ios",
  getProjectId: "Your ProjectId Ios",
  getMobileSdkAppId: "Your MobileSdkAppId Ios",
  getBundleIdentifier: "Your BundleIdentifier Ios",
  getHostInfo: "Your HostInfo Ios",
  getHostKey: "Your HostKey Ios");

final _configAndroid = UnicoConfig(
  getProjectNumber: "Your ProjectNumber Android",
  getProjectId: "Your ProjectId Android",
  getMobileSdkAppId: "Your MobileSdkAppId Android",
  getBundleIdentifier: "Your BundleIdentifier Android",
  getHostInfo: "Your HostInfo Android",
  getHostKey: "Your HostKey Android");

@override
void initState() {
  super.initState();
  initUnicoCamera();
}

void initUnicoCamera() {
  _unicoCheck = new UnicoCheck(
      listener: this,
      unicoConfigIos: _configIos,
      unicoConfigAndroid: _configAndroid);
}
```
## 📦 Instalação

### Utilizando o CLI do Flutter

```
$ flutter pub add unico_check
```
### Permissões para utilizar a câmera

Para utilizar o método de abertura de câmera é necessário adicionar as permissões antes de compilar a aplicação.

Insira as tags abaixo em:
- `android > app > src > main > AndroidManifest.xml`

```
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```
- `ios > Runner > Info.plist`

```
<key>NSCameraUsageDescription</key>
<string>Camera usage description</string>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key><true/>
</dict>
```

### Inclusão da dependência

Importe nosso pacote em código Dart:

```
import 'package:unico_check/unico_check.dart';
```

## 📷 Captura de selfies

### 1️⃣ Inicializar nosso SDK

Crie uma instância do builder (gerado através da interface `UnicoCheckBuilder`) fornecendo como parâmetro o contexto em questão e a implementação da classe `UnicoListener`. Sobrescreva nossos métodos de callback com as lógicas de negócio de sua aplicação.

```
class _MyHomePageState extends State<MyHomePage> implements UnicoListener {

    late UnicoCheckBuilder _unicoCheck;

      @override
      void onErrorUnico(UnicoError error) {}

      @override
      void onUserClosedCameraManually() {}

      @override
      void onSystemChangedTypeCameraTimeoutFaceInference() {}

      @override
      void onSystemClosedCameraTimeoutSession() {}
}
```

`onErrorUnico(UnicoError error)`

Este método será invocado sempre quando qualquer erro de implementação ocorrer ao utilizar algum de nossos métodos recebendo um parâmetro do tipo <b>UnicoError</b> que contém detalhes do erro.

`onUserClosedCameraManually()`

Este método será invocado sempre quando o usuário fechar a câmera de forma manual, como por exemplo, ao clicar no botão "Voltar".

`onSystemClosedCameraTimeoutSession()`

Este método será invocado assim que o tempo máximo de sessão for atingido (Sem capturar nenhuma imagem).

O tempo máximo da sessão pode ser configurado em nosso <b>builder</b> através do método `setTimeoutSession`. Este método deve receber o tempo máximo da sessão em <b>segundos</b>.

`onSystemChangedTypeCameraTimeoutFaceInference()`

Este método será invocado assim que o tempo máximo para detecção da face de um usuário for atingido (sem ter nada detectado). Neste caso, o modo de câmera é alterado automaticamente para o modo manual (sem o smart frame).

<hr>

### <strong>❗ Todos os métodos acima devem ser criados da forma indicada em seu projeto (mesmo que sem nenhuma lógica). Caso contrário, o projeto não compilará com sucesso.</strong>

<hr>

### 2️⃣ Configurar modo da câmera
<p style='font-size: 15px'>
  <b>Modo inteligente (captura automática - Smart Camera)</b>
</p>

Por padrão, nosso SDK possui o enquadramento inteligente e a captura automática habilitados. Caso decida utilizar este modo de câmera, não será necessário alterar nenhuma configuração.

Caso as configurações da câmera tenham sido alteradas previamente em seu App, é possível restaurá-las através dos métodos `setAutoCapture` e `setSmartFrame`:

```
UnicoCheckCameraOpener _opener = new UnicoCheck (this)
    .setAutoCapture(autoCapture: true)
    .setSmartFrame(smartFrame: true)
    .build();
```
<hr>

### <strong>❗ Não é possível implementar o método <span style='font-size: 15px'> `setAutoCapture(autoCapture: true)` </span> com o método <span style='font-size: 15px'> `setSmartFrame(smartFrame: false)`. </span>Ou seja, não é possível manter a captura automática sem o Smart Frame, pois ele é quem realiza o enquadramento inteligente. </strong>

<hr>

<p style='font-size: 15px'>
  <b>Modo normal</b>
</p>

Por padrão, nosso SDK possui o enquadramento inteligente e a captura automática habilitados. Neste caso, para utilizar o modo manual ambas configurações relacionadas a Smart Camera devem ser desligadas através dos métodos `setAutoCapture` e `setSmartFrame`:

```
UnicoCheckCameraOpener _opener = new UnicoCheck (this)
    .setAutoCapture(autoCapture: false)
    .setSmartFrame(smartFrame: false)
    .build();
```

### 3️⃣ Customizar o frame de captura

<strong>Este passo é opcional, porém recomendado.</strong> Oferecemos a possibilidade de customização do frame de captura por meio do nosso SDK. Para customizar o frame, basta utilizar o método correspondente a propriedade a ser customizada, e posteriormente, aplicar o novo estilo através do método `setTheme()`. Para mais informações, consulte em nossa página de <a href='https://developers.unico.io/guias/flutter/referencias#customizações'>Referências</a> do SDK. 

### 4️⃣ Efetuar abertura da câmera

Para informar ao método de abertura de câmera "o que fazer" deve ser implantado os <i>listeners</i> que serão chamados em situações de sucesso ou erro. A implementação desses métodos deverá ser feita através de uma instância de classe `UnicoSelfie`.

<p>

  <b style='font-size: 15px'> Método `onSuccessSelfie` </b>

</p>

Ao efetuar uma captura de imagem com sucesso, este método será invocado e retornará um objeto do tipo `ResultCamera` que será utilizado posteriormente na chamada de nossas APIs REST.

```
@override
void onSuccessSelfie(ResultCamera result) { }
```

<p>

  <b style='font-size: 15px'> Método `onErrorSelfie` </b>

</p>

Ao ocorrer algum erro na captura de imagem, este método será invocado e retornará um objeto do tipo `UnicoError`.

```
@override
void onErrorSelfie(UnicoError error) { }
```

<p>

  <b style='font-size: 15px'> Abrir câmera </b>

</p>

Devemos abrir a câmera utilizando o método `openCameraSelfie` recebendo como parâmetro a implementação da classe `UnicoSelfie`. 

```
_opener.openCameraSelfie(listener: this)
```

Em caso de sucesso, o objeto `ResultCamera` retornará 2 atributos: <strong> base64</strong> e <strong>encrypted</strong>.

#### - `base64`: pode ser utilizado caso queira exibir um preview da imagem em seu app;
#### - `encrypted`: deverá ser enviado na chamada de nossas APIs REST do <b>unico check</b>. Para mais informações detalhadas, visite nosso <a href='https://www3.acesso.io/identity/services/v3/docs/'>API Reference</a>.

## 📄 Captura de documentos

### 1️⃣ Inicializar nosso SDK

Na inicialização do SDK para captura de documentos são utilizadas exatamente os mesmos métodos <span style='font-size: 13px'>`onErrorUnico(UnicoError error), onUserClosedCameraManually(), onSystemClosedCameraTimeoutSession()`</span> e <span style='font-size: 13px'>`onSystemChangedTypeCameraTimeoutFaceInference()`</span> na [captura de selfie](#1️⃣-inicializar-nosso-sdk). 

### 2️⃣ Efetuar abertura de câmera

Para implementar os <i>listeners</i> para evento de câmera, o processo é exatamente igual a realizada na [captura de selfie](#4️⃣-efetuar-abertura-da-câmera). Porém, os métodos de callback de sucesso e erro são chamados desta forma: 
```
@override
void onSuccessDocument(ResultCamera resultCamara) {}
```
```
@override
void onErrorDocument(UnicoError error) {}
```

Finalmente, devemos abrir a câmera com as configurações feitas até aqui. Chamamos o método `openCameraDocument()`, disponilizado pelo objeto `UnicoCheck`. Este método receberá os parâmetros abaixo:

<b style='font-size: 15px'>Tipos de documentos a serem capturados, sendo eles: </b>
- DocumentCameraTypes.CNH: 
- DocumentCameraTypes.CPF: 
- DocumentCameraTypes.OUTROS("descrição"): 
- DocumentCameraTypes.RG_FRENTE: 
- DocumentCameraTypes.RG_VERSO: 
- DocumentCameraTypes.RG_FRENTE_NOVO: 
- DocumentCameraTypes.RG_VERSO_NOVO: 

<b style='font-size: 15px'>Listeners configurados [acima](#2️⃣-efetuar-abertura-de-câmera)</b>

```
 _unicoCheck.build().openCameraDocument(
        documentType: DocumentType.CNH,
        listener: this);
```

Em caso de sucesso, o objeto ResultCamera retornará 2 atributos (`base64` e `encrypted`) igualmente a [captura de selfie](#base64-pode-ser-utilizado-caso-queira-exibir-um-preview-da-imagem-em-seu-app).

### 3️⃣ Customizar o frame de captura

<strong>Este passo é opcional, porém recomendado.</strong> Oferecemos a possibilidade de customização do frame de captura por meio do nosso SDK. Para customizar o frame, basta utilizar o método correspondente a propriedade a ser customizada, e posteriormente, aplicar o novo estilo através do método `setTheme()`. Para mais informações, consulte em nossa página de <a href='https://developers.unico.io/docs/check/guias/flutter/referencias#customiza%C3%A7%C3%B5es'>Referências</a> do SDK.

## 🤔 Dúvidas

Caso tenha alguma dúvida ou precise de ajuda com questões mais específicas, nossa <a href='https://developers.unico.io/docs/check/guias/flutter/overview'>documentação</a> está disponível.
