#import <WebRTC/RTCCameraVideoCapturer.h>

@class NBMSettingsModel;

// Controls the camera. Handles starting the capture, switching cameras etc.
@interface NBMCaptureController : NSObject

- (instancetype)initWithCapturer:(RTCCameraVideoCapturer *)capturer
                        settings:(NBMSettingsModel *)settings;
- (void)startCapture;
- (void)stopCapture;
- (void)switchCamera;

@end

