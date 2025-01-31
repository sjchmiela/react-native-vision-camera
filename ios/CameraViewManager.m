//
//  CameraViewManager.m
//  Cuvent
//
//  Created by Marc Rousavy on 09.11.20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "CameraBridge.h"
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_REMAP_MODULE(CameraView, CameraViewManager, RCTViewManager)

// Module Functions
RCT_EXTERN_METHOD(getCameraPermissionStatus:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(getMicrophonePermissionStatus:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(requestCameraPermission:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(requestMicrophonePermission:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(getAvailableCameraDevices:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);

// Camera View Properties
RCT_EXPORT_VIEW_PROPERTY(isActive, BOOL);
RCT_EXPORT_VIEW_PROPERTY(cameraId, NSString);
RCT_EXPORT_VIEW_PROPERTY(enableDepthData, BOOL);
RCT_EXPORT_VIEW_PROPERTY(enableHighResolutionCapture, NSNumber); // nullable bool
RCT_EXPORT_VIEW_PROPERTY(enablePortraitEffectsMatteDelivery, BOOL);
// device format
RCT_EXPORT_VIEW_PROPERTY(format, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(fps, NSNumber);
RCT_EXPORT_VIEW_PROPERTY(hdr, NSNumber); // nullable bool
RCT_EXPORT_VIEW_PROPERTY(lowLightBoost, NSNumber); // nullable bool
RCT_EXPORT_VIEW_PROPERTY(colorSpace, NSString);
// other props
RCT_EXPORT_VIEW_PROPERTY(preset, NSString);
RCT_EXPORT_VIEW_PROPERTY(scannableCodes, NSArray<NSString>);
RCT_EXPORT_VIEW_PROPERTY(torch, NSString);
RCT_EXPORT_VIEW_PROPERTY(zoom, NSNumber);
RCT_EXPORT_VIEW_PROPERTY(enableZoomGesture, BOOL);
// Camera View Properties
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onInitialized, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onCodeScanned, RCTBubblingEventBlock);

// Camera View Functions
RCT_EXTERN_METHOD(startRecording:(nonnull NSNumber *)node options:(NSDictionary *)options onRecordCallback:(RCTResponseSenderBlock)onRecordCallback);
RCT_EXTERN_METHOD(stopRecording:(nonnull NSNumber *)node resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(takePhoto:(nonnull NSNumber *)node options:(NSDictionary *)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(focus:(nonnull NSNumber *)node point:(NSDictionary *)point resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(getAvailableVideoCodecs:(nonnull NSNumber *)node resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(getAvailablePhotoCodecs:(nonnull NSNumber *)node resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);

@end
