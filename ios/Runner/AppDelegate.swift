import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Configure audio session
    let audioSession = AVAudioSession.sharedInstance()
    do {
        try audioSession.setCategory(.playback, options: .mixWithOthers)
        try audioSession.setActive(true)
    } catch {
        print("Failed to set audio session category.")
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
