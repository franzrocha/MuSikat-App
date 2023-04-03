//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

<<<<<<< Updated upstream
import audio_session
=======
import audioplayers_darwin
>>>>>>> Stashed changes
import cloud_firestore
import firebase_auth
import firebase_core
import firebase_database
import firebase_storage
<<<<<<< Updated upstream
import just_audio
import path_provider_foundation

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioSessionPlugin.register(with: registry.registrar(forPlugin: "AudioSessionPlugin"))
=======
import modal_progress_hud_nsn
import path_provider_foundation

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioplayersDarwinPlugin.register(with: registry.registrar(forPlugin: "AudioplayersDarwinPlugin"))
>>>>>>> Stashed changes
  FLTFirebaseFirestorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseFirestorePlugin"))
  FLTFirebaseAuthPlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseAuthPlugin"))
  FLTFirebaseCorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseCorePlugin"))
  FLTFirebaseDatabasePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseDatabasePlugin"))
  FLTFirebaseStoragePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseStoragePlugin"))
<<<<<<< Updated upstream
  JustAudioPlugin.register(with: registry.registrar(forPlugin: "JustAudioPlugin"))
=======
  ModalProgressHudNsnPlugin.register(with: registry.registrar(forPlugin: "ModalProgressHudNsnPlugin"))
>>>>>>> Stashed changes
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
}
