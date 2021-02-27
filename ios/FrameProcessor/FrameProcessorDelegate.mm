//
//  FrameProcessorDelegate.mm
//  VisionCamera
//
//  Created by Marc Rousavy on 27.02.21.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "FrameProcessorDelegate.h"
#import <Foundation/Foundation.h>
#import <jsi/jsi.h>
#import "Logger.h"

#import "MakeJSIRuntime.h"
#import "../../cpp/RuntimeDecorator.h"

using namespace facebook;

@implementation FrameProcessorDelegate {
  std::unique_ptr<jsi::Function> worklet;
  std::unique_ptr<jsi::Runtime> runtime;
}

@synthesize dispatchQueue;

- (instancetype) init {
  self = [super init];
  if (self) {
    // TODO: relativePriority 0 or -1?
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INTERACTIVE, -1);
    dispatchQueue = dispatch_queue_create("com.mrousavy.camera-frame-processor", qos);
    // TODO: Do I need to create the JSI runtime in the `dispatchQueue`'s Thread?
    runtime = std::unique_ptr<jsi::Runtime>(vision::makeJSIRuntime());
    vision::RuntimeDecorator::decorateRuntime(*runtime);
  }
  return self;
}

- (void) setFrameProcessorFunction:(void*)function {
  // TODO: Make sure this unique_ptr stuff works, because it seems like a very bad idea to move the jsi::Function and keep a strong reference
  worklet = std::unique_ptr<jsi::Function>(static_cast<jsi::Function*>(function));
  // TODO: Workletize the [worklet] using the Reanimated API
}

- (void) captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
  if (!runtime) {
    // TODO: Handle case where runtime is not created yet
    vision::Logger::log("FrameProcessorDelegate: Camera frame arrived, but JSI Runtime has not been created yet!");
    return;
  }
  // TODO: Call [worklet] with the output buffer
  auto args = jsi::Array::createWithElements(*runtime, { jsi::Value::undefined() });
  worklet->call(*runtime, args, 1);
  //worklet->call(*runtime, jsi::Value::undefined(), 1);
}

@end
