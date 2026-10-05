import Flutter
import UIKit
import UniformTypeIdentifiers

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "NPassClipboard") else { return }
    let channel = FlutterMethodChannel(name: "npass/clipboard", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      guard call.method == "copySensitive",
        let args = call.arguments as? [String: Any],
        let text = args["text"] as? String,
        let clearAfterMs = args["clearAfterMs"] as? Int
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      // Local only: kept out of Universal Clipboard. Expires on its own, even
      // if the app is suspended.
      UIPasteboard.general.setItems(
        [[UTType.utf8PlainText.identifier: text]],
        options: [
          .localOnly: true,
          .expirationDate: Date().addingTimeInterval(Double(clearAfterMs) / 1000),
        ])
      result(nil)
    }
  }
}
