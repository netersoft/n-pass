import Flutter
import StoreKit
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

    // In-app review, called by ReviewService. StoreKit decides whether the
    // sheet shows and never says, so this always answers true.
    if let reviewRegistrar = engineBridge.pluginRegistry.registrar(forPlugin: "ReviewChannel") {
      FlutterMethodChannel(name: "com.neteru.n_pass/review", binaryMessenger: reviewRegistrar.messenger())
        .setMethodCallHandler { call, result in
          guard call.method == "requestReview" else {
            result(FlutterMethodNotImplemented)
            return
          }
          if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
          }
          result(true)
        }
    }

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
