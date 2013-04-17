//
//  CameraRecorder.h
//  Camera
//
//  Created by chen hongbin on 13-4-8.
//  Copyright (c) 2013年 chen hongbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class CameraRecorder;

@protocol CameraRecorderDelegate <NSObject>
@required
- (void)recorderRecordingDidBegin:(CameraRecorder *)recorder;
- (void)recorder:(CameraRecorder *)recorder recordingDidFinishToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error;
@end

@interface CameraRecorder : NSObject

@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic,  copy) NSURL *outputFileURL;
@property (nonatomic, readonly) BOOL recordsVideo;
@property (nonatomic, readonly) BOOL recordsAudio;
@property (nonatomic, readonly, getter = isRecording) BOOL recording;
@property (nonatomic, weak) id<CameraRecorderDelegate> delegate;

- (id)initWithSession:(AVCaptureSession *)session outputFileURL:(NSURL *)outputFileURL;
- (void)startRecordingWithOrientation:(AVCaptureVideoOrientation)videoOrientation;
- (void)stopRecording;
@end
