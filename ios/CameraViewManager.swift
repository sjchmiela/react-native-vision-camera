//
//  CameraViewManager.swift
//  Cuvent
//
//  Created by Marc Rousavy on 09.11.20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import AVFoundation
import Foundation

@objc(CameraViewManager)
final class CameraViewManager: RCTViewManager {
  // pragma MARK: Setup
  override final func view() -> UIView! {
    return CameraView()
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }

  override var methodQueue: DispatchQueue! {
    return DispatchQueue.main
  }

  private func getCameraView(withTag tag: NSNumber) -> CameraView {
    // swiftlint:disable force_cast
    return bridge.uiManager.view(forReactTag: tag) as! CameraView
  }

  // pragma MARK: Exported Functions
  @objc
  final func startRecording(_ node: NSNumber, options: NSDictionary, onRecordCallback: @escaping RCTResponseSenderBlock) {
    let component = getCameraView(withTag: node)
    component.startRecording(options: options, callback: onRecordCallback)
  }

  @objc
  final func stopRecording(_ node: NSNumber, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    let component = getCameraView(withTag: node)
    component.stopRecording(promise: Promise(resolver: resolve, rejecter: reject))
  }

  @objc
  final func takePhoto(_ node: NSNumber, options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    let component = getCameraView(withTag: node)
    component.takePhoto(options: options, promise: Promise(resolver: resolve, rejecter: reject))
  }

  @objc
  final func focus(_ node: NSNumber, point: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    let promise = Promise(resolver: resolve, rejecter: reject)
    guard let x = point["x"] as? NSNumber, let y = point["y"] as? NSNumber else {
      return promise.reject(error: .parameter(.invalid(unionName: "point", receivedValue: point.description)))
    }
    let component = getCameraView(withTag: node)
    component.focus(point: CGPoint(x: x.doubleValue, y: y.doubleValue), promise: promise)
  }

  @objc
  final func getAvailableVideoCodecs(_ node: NSNumber, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    withPromise(resolve: resolve, reject: reject) {
      let component = getCameraView(withTag: node)
      guard let movieOutput = component.movieOutput else {
        throw CameraError.session(SessionError.cameraNotReady)
      }
      return movieOutput.availableVideoCodecTypes.map { $0.descriptor }
    }
  }

  @objc
  final func getAvailablePhotoCodecs(_ node: NSNumber, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    withPromise(resolve: resolve, reject: reject) {
      let component = getCameraView(withTag: node)
      guard let photoOutput = component.photoOutput else {
        throw CameraError.session(SessionError.cameraNotReady)
      }
      return photoOutput.availablePhotoCodecTypes.map { $0.descriptor }
    }
  }

  private final func getAllDeviceTypes() -> [AVCaptureDevice.DeviceType] {
    var deviceTypes: [AVCaptureDevice.DeviceType] = []
    if #available(iOS 13.0, *) {
      deviceTypes.append(.builtInTripleCamera)
      deviceTypes.append(.builtInDualWideCamera)
      deviceTypes.append(.builtInUltraWideCamera)
    }
    if #available(iOS 11.1, *) {
      deviceTypes.append(.builtInTrueDepthCamera)
    }
    deviceTypes.append(.builtInDualCamera)
    deviceTypes.append(.builtInWideAngleCamera)
    deviceTypes.append(.builtInTelephotoCamera)
    return deviceTypes
  }

  // pragma MARK: View Manager funcs
  @objc
  final func getAvailableCameraDevices(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    withPromise(resolve: resolve, reject: reject) {
      let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: getAllDeviceTypes(), mediaType: .video, position: .unspecified)
      return discoverySession.devices.map {
        return [
          "id": $0.uniqueID,
          "devices": $0.physicalDevices.map { $0.deviceType.descriptor },
          "position": $0.position.descriptor,
          "name": $0.localizedName,
          "hasFlash": $0.hasFlash,
          "hasTorch": $0.hasTorch,
          "minZoom": $0.minAvailableVideoZoomFactor,
          "maxZoom": $0.maxAvailableVideoZoomFactor,
          "neutralZoom": $0.neutralZoomPercent,
          "isMultiCam": $0.isMultiCam,
          "supportsDepthCapture": false, // TODO: supportsDepthCapture
          "supportsRawCapture": false, // TODO: supportsRawCapture
          "supportsLowLightBoost": $0.isLowLightBoostSupported,
          "formats": $0.formats.map { (format) -> [String: Any] in
            format.toDictionary()
          },
        ]
      }
    }
  }

  @objc
  final func getCameraPermissionStatus(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    withPromise(resolve: resolve, reject: reject) {
      let status = AVCaptureDevice.authorizationStatus(for: .video)
      return status.descriptor
    }
  }

  @objc
  final func getMicrophonePermissionStatus(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    withPromise(resolve: resolve, reject: reject) {
      let status = AVCaptureDevice.authorizationStatus(for: .audio)
      return status.descriptor
    }
  }

  @objc
  final func requestCameraPermission(_ resolve: @escaping RCTPromiseResolveBlock, reject _: @escaping RCTPromiseRejectBlock) {
    AVCaptureDevice.requestAccess(for: .video) { granted in
      let result: AVAuthorizationStatus = granted ? .authorized : .denied
      resolve(result.descriptor)
    }
  }

  @objc
  final func requestMicrophonePermission(_ resolve: @escaping RCTPromiseResolveBlock, reject _: @escaping RCTPromiseRejectBlock) {
    AVCaptureDevice.requestAccess(for: .audio) { granted in
      let result: AVAuthorizationStatus = granted ? .authorized : .denied
      resolve(result.descriptor)
    }
  }
}
