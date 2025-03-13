<p align="center">
  <a href="https://unico.io">
    <img width="350" src="https://unico.io/wp-content/uploads/2024/05/idcloud-horizontal-color.svg">
  </a>
</p>

<h1 align="center">SDK Flutter</h1>

<div align="center">
  
### POC de implementação do SDK Unico | Check em Flutter
  
![SDK](https://img.shields.io/badge/SDK-v3.0.10-blueviolet?logo=)  
![FLUTTER](https://img.shields.io/badge/Flutter-blue?logo=flutter)
</div>

---

## 💻 Compatibilidade

### 📌 Versões

![ANDROID](https://img.shields.io/badge/Android-grey?logo=android)  
![IOS](https://img.shields.io/badge/iOS-grey?logo=apple)

- **Android:** Versão mínima do Android 5.0 (API de nível 21)
- **iOS:** Versão mínima do iOS 11

### 📱 Dispositivos Compatíveis

- **Android:** Confira os aparelhos testados em nossos laboratórios nesta [lista de dispositivos](https://developers.unico.io/docs/check/guias/android/overview#dispositivos-compat%C3%ADveis).
- **iOS:** Veja a lista de dispositivos compatíveis nos [canais de suporte oficiais da Apple](https://support.apple.com/pt-br/HT209574).

---

## ✨ Como Começar

### 🚀 Ambiente de Desenvolvimento & Credenciais Unico

- **Flutter SDK:** Certifique-se de ter o [Developer SDK do Flutter](https://docs.flutter.dev/get-started/install) instalado.
- **Credenciais Unico:** Para utilizar nossos SDKs, importe as credenciais Unico (Client API Key) em seu projeto. Siga [este passo a passo](https://developers.unico.io/docs/check/guias/flutter/como-comecar#obtendo-suas-credenciais) para gerar as credenciais.

Após configurar a API Key e obter o bundle da SDK (iOS ou Android) com os dados em JSON, informe-os como parâmetros ao instanciar a interface `UnicoCheck`. Esses parâmetros devem ser enviados como objetos, gerados a partir do método `UnicoConfig`.  
Veja o exemplo:

```dart
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

---

## 📦 Instalação

### 🛠️ Utilizando o CLI do Flutter

```bash
$ flutter pub add unico_check
```

### 🔒 Permissões para Utilizar a Câmera

Antes de compilar a aplicação, adicione as seguintes permissões:

- **Android:** No arquivo `android > app > src > main > AndroidManifest.xml`:

  ```xml
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.INTERNET" />
  ```

- **iOS:** No arquivo `ios > Runner > Info.plist`:

  ```xml
  <key>NSCameraUsageDescription</key>
  <string>Camera usage description</string>
  <key>NSAppTransportSecurity</key>
  <dict>
      <key>NSAllowsArbitraryLoads</key><true/>
  </dict>
  ```

### 📥 Inclusão da Dependência

Importe o pacote em seu código Dart:

```dart
import 'package:unico_check/unico_check.dart';
```

---

## 📷 Captura de Selfies

### 1️⃣ Inicializar o SDK

Crie uma instância do builder (gerado através da interface `UnicoCheckBuilder`), fornecendo o contexto e a implementação da classe `UnicoListener`. Sobrescreva os métodos de callback com a lógica de negócio da sua aplicação:

```dart
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

> **Detalhes dos Callbacks:**
>
> - **`onErrorUnico(UnicoError error)`:** Invocado sempre que ocorrer um erro de implementação, retornando um objeto do tipo **UnicoError** com detalhes do erro.
> - **`onUserClosedCameraManually()`:** Chamado quando o usuário fecha a câmera manualmente (por exemplo, ao clicar no botão "Voltar").
> - **`onSystemClosedCameraTimeoutSession()`:** Invocado quando o tempo máximo de sessão é atingido (sem capturar nenhuma imagem). Esse tempo pode ser configurado via `setTimeoutSession` (em segundos).
> - **`onSystemChangedTypeCameraTimeoutFaceInference()`:** Chamado quando o tempo máximo para detecção da face é atingido (nenhuma face detectada), alterando automaticamente para o modo manual (sem o smart frame).
>
> **❗ Importante:** Todos os métodos acima devem ser implementados conforme indicado. Caso contrário, o projeto não compilará com sucesso.

---

### 2️⃣ Configurar Modo da Câmera

#### 🔄 Modo Inteligente (Captura Automática - Smart Camera)

Por padrão, o SDK possui enquadramento inteligente e captura automática habilitados. Se optar por esse modo, nenhuma configuração adicional é necessária.  
Caso as configurações da câmera tenham sido alteradas, restaure-as utilizando os métodos `setAutoCapture` e `setSmartFrame`:

```dart
UnicoCheckCameraOpener _opener = new UnicoCheck (this)
    .setAutoCapture(autoCapture: true)
    .setSmartFrame(smartFrame: true)
    .build();
```

> **❗ Atenção:** Não é possível usar `setAutoCapture(autoCapture: true)` com `setSmartFrame(smartFrame: false)`. A captura automática depende do Smart Frame, que é responsável pelo enquadramento inteligente.

#### 🔄 Modo Normal

Para utilizar o modo manual, desative as configurações do Smart Camera:

```dart
UnicoCheckCameraOpener _opener = new UnicoCheck (this)
    .setAutoCapture(autoCapture: false)
    .setSmartFrame(smartFrame: false)
    .build();
```

---

### 3️⃣ Customizar o Frame de Captura

**Opcional, mas recomendado.**  
Você pode customizar o frame de captura utilizando o método correspondente à propriedade desejada e, em seguida, aplicar o novo estilo através do método `setTheme()`.  
Para mais informações, consulte as [Referências do SDK](https://developers.unico.io/docs/check/guias/flutter/referencias#customiza%C3%A7%C3%B5es).

---

### 4️⃣ Efetuar a Abertura da Câmera

Implemente os _listeners_ para tratar os eventos de sucesso ou erro ao abrir a câmera. Essa implementação é feita através da classe `UnicoSelfie`.

- **Método `onSuccessSelfie`:**  
  Ao capturar uma imagem com sucesso, esse método será invocado e retornará um objeto do tipo `ResultCamera`, utilizado posteriormente nas chamadas das APIs REST.

  ```dart
  @override
  void onSuccessSelfie(ResultCamera result) { }
  ```

- **Método `onErrorSelfie`:**  
  Em caso de erro na captura da imagem, este método será chamado e retornará um objeto do tipo `UnicoError`.

  ```dart
  @override
  void onErrorSelfie(UnicoError error) { }
  ```

**Abrindo a Câmera:**

Utilize o método `openCameraSelfie`, passando como parâmetro a implementação da classe `UnicoSelfie`:

```dart
_opener.openCameraSelfie(listener: this)
```

> **Observação:** Em caso de sucesso, o objeto `ResultCamera` retornará os atributos **base64** e **encrypted**:
> - **base64:** Pode ser utilizado para exibir um preview da imagem no app.
> - **encrypted:** Deve ser enviado na chamada das APIs REST do Unico Check. Para mais informações, consulte a [API Reference](https://www3.acesso.io/identity/services/v3/docs/).

---

## 📄 Captura de Documentos

### 1️⃣ Inicializar o SDK

Na inicialização do SDK para captura de documentos, são utilizados os mesmos métodos de callback da captura de selfie:  
`onErrorUnico(UnicoError error)`, `onUserClosedCameraManually()`, `onSystemClosedCameraTimeoutSession()` e `onSystemChangedTypeCameraTimeoutFaceInference()`.

---

### 2️⃣ Efetuar a Abertura da Câmera

Para implementar os _listeners_ para eventos de câmera na captura de documentos, o processo é igual ao da captura de selfie. Porém, os métodos de callback de sucesso e erro são:

```dart
@override
void onSuccessDocument(ResultCamera resultCamara) {}
```

```dart
@override
void onErrorDocument(UnicoError error) {}
```

Por fim, abra a câmera com as configurações definidas utilizando o método `openCameraDocument()`, que receberá os seguintes parâmetros:

- **Tipos de Documentos a Capturar:**
  - `DocumentCameraTypes.CNH`
  - `DocumentCameraTypes.CPF`
  - `DocumentCameraTypes.OUTROS("descrição")`
  - `DocumentCameraTypes.RG_FRENTE`
  - `DocumentCameraTypes.RG_VERSO`
  - `DocumentCameraTypes.RG_FRENTE_NOVO`
  - `DocumentCameraTypes.RG_VERSO_NOVO`

- **Listeners:** Conforme configurados anteriormente.

Exemplo:

```dart
_unicoCheck.build().openCameraDocument(
        documentType: DocumentType.CNH,
        listener: this);
```

> **Observação:** Em caso de sucesso, o objeto `ResultCamera` retornará os atributos **base64** e **encrypted**, assim como na captura de selfie.

---

### 3️⃣ Customizar o Frame de Captura

**Opcional, mas recomendado.**  
Você pode customizar o frame de captura utilizando o método correspondente à propriedade desejada e, em seguida, aplicar o novo estilo através do método `setTheme()`.  
Para mais detalhes, consulte as [Referências do SDK](https://developers.unico.io/docs/check/guias/flutter/referencias#customiza%C3%A7%C3%B5es).

---

## 🤔 Dúvidas

Caso tenha alguma dúvida ou precise de ajuda com questões específicas, nossa [documentação](https://developers.unico.io/docs/check/guias/flutter/overview) está à disposição.
