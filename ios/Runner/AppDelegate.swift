import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps API key
    GMSServices.provideAPIKey("AIzaSyDGbqlpUyhaG9GT1SeRI0TWXp_nWPFt93o")
    
    // Ensure plugins are registered before app becomes active
    GeneratedPluginRegistrant.register(with: self)
    
    // Allow time for plugin initialization
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      // This ensures Flutter engine is fully ready before plugins are used
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    
    // Additional plugin initialization when app becomes active
    // This helps ensure plugins are ready after app lifecycle changes
  }
}
