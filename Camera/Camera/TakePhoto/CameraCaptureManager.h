//
//  CameraCaptureManager.h
//  Camera
//
//  Created by chen hongbin on 13-4-8.
//  Copyright (c) 2013年 chen hongbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class CameraRecorder;
@class CameraCaptureManager;

@protocol  CamperaCaptureManagerDelegate<NSObject>

@optional
- (void)captureManager:(CameraCaptureManager *)captureManger didFailWithError:(NSError *)error;

- (void)captureManagerRecordingBegan:(CameraCaptureManager *)captureManger;
- (void)captureManagerRecordingFinished:(CameraCaptureManager *)captureManger;

- (void)captureManagerStillImageCaptured:(CameraCaptureManager *)captureManger;

- (void)captureManagerDeviceConfigurationChanged:(CameraCaptureManager *)captureManager;
@end

@interface CameraCaptureManager : NSObject

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, assign) AVCaptureVideoOrientation orientation;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) CameraRecorder *recorder;
@property (nonatomic, weak) id deviceConnectedObserver;
@property (nonatomic, weak) id deviceDisconnectedObserver;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, weak) id <CamperaCaptureManagerDelegate> delegate;

- (BOOL)setupSession;
- (void)startRecording;
- (void)stopRecording;
- (void)captureStillImage;
- (BOOL)toggleCamera;
- (NSUInteger)cametaCount;
- (NSUInteger)micCount;
- (void)autoFocusAtpoint:(CGPoint)point;
- (void)continuousFocusAtPoint:(CGPoint)point;
@end
