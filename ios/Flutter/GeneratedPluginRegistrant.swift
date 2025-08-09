//
//  Generated file. Do not edit.
//

import Flutter
import UIKit

import geolocator_apple
import google_maps_flutter_ios
import path_provider_foundation
import shared_preferences_foundation

@objc class GeneratedPluginRegistrant: NSObject {
  @objc public static func register(with registry: FlutterPluginRegistry) {
    GeolocatorPlugin.register(with: registry.registrar(forPlugin: "GeolocatorPlugin"))
    FLTGoogleMapsPlugin.register(with: registry.registrar(forPlugin: "FLTGoogleMapsPlugin"))
    PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
    SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  }
}