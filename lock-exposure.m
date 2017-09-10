// lock-exposure.m
// Created by Aaron C Gaudette on 15.08.16

#import <Foundation/NSAutoreleasePool.h>
#import <AVFoundation/AVFoundation.h>

int ClearExposure(AVCaptureDevice *device, bool lock) {
  @autoreleasepool {
    AVCaptureSession *session = [[AVCaptureSession alloc] init];

    AVCaptureInput *input = [
      AVCaptureDeviceInput deviceInputWithDevice: device error: nil
    ];

    if (!input) {
      NSLog(@"Error: No input");
      return 1;
    }

    [session beginConfiguration];
    [session addInput: input];
    [session commitConfiguration];

    if ([device lockForConfiguration: nil]) {
      AVCaptureExposureMode mode = lock ?
        AVCaptureExposureModeLocked
        : AVCaptureExposureModeContinuousAutoExposure;

      if ([device isExposureModeSupported: mode]) {
        [device setExposureMode: mode];
      } else {
        NSLog(@"Error: Exposure mode unsupported");
        return 1;
      }

      [device unlockForConfiguration];
    } else {
      NSLog(@"Error: Locking unsuccessful");
      return 1;
    }
  }

  NSLog(
    @"Camera \'%@\' %s", device.localizedName, lock ? "locked" : "unlocked"
  );

  return 0;
}

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    NSArray *devices = [
      AVCaptureDevice devicesWithMediaType: AVMediaTypeVideo
    ];

    NSLog(@"Connected cameras:");
    if (devices.count == 0) NSLog(@"\t(Empty)");
    else for (AVCaptureDevice *d in devices) NSLog(@"\t%@", d.localizedName);

    if (argc < 2) {
      NSLog(@"Usage: lock-exposure t/f [index]");
      NSLog(@"\te.g. lock-exposure f 1");
      return 0;
    }

    int index = argc > 2 ? atoi(argv[2]) : 0;

    if (index >= devices.count) {
      NSLog(@"Error: Invalid camera index");
      return 1;
    }

    AVCaptureDevice *device = devices[index];
    return ClearExposure(device, !strcmp(argv[1], "t") ? true : false);
  }

  return 1;
}
