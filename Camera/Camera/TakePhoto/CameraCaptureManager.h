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

@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, assign) AVCaptureVideoOrientation orientation;
@property (nonatomic, retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic, retain) AVCaptureDeviceInput *audioInput;
@property (nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) CameraRecorder *recorder;
@property (nonatomic, assign) id deviceConnectedObserver;
@property (nonatomic, assign) id deviceDisconnectedObserver;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, assign) id <CamperaCaptureManagerDelegate> delegate;

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
