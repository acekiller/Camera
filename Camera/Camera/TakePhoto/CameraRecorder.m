//
//  CameraRecorder.m
//  Camera
//
//  Created by chen hongbin on 13-4-8.
//  Copyright (c) 2013年 chen hongbin. All rights reserved.
//

#import "CameraRecorder.h"
#import "CameraUtilities.h"
#import <AVFoundation/AVFoundation.h>

@interface CameraRecorder ()<AVCaptureFileOutputRecordingDelegate>

@end

@implementation CameraRecorder

- (id)initWithSession:(AVCaptureSession *)session outputFileURL:(NSURL *)outputFileURL{
    self = [super init];
    if (self != nil) {
        AVCaptureMovieFileOutput *aMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([session canAddOutput:aMovieFileOutput]) {
            [session addOutput:aMovieFileOutput];
        }
        [self setMovieFileOutput:aMovieFileOutput];
        aMovieFileOutput = nil;
        
        [self setSession:session];
        [self setOutputFileURL:outputFileURL];
    }
    return self;
}

- (void)dealloc{
    [[self session] removeOutput:[self movieFileOutput]];
}

- (BOOL)recordsVideo{
    AVCaptureConnection *videoConnection = [CameraUtilities connectionWithMediaType:AVMediaTypeVideo
                                                                    fromConnections:[[self movieFileOutput] connections]];
    return [videoConnection isActive];
}

- (BOOL)recordsAudio{
    AVCaptureConnection *audioConnection = [CameraUtilities connectionWithMediaType:AVMediaTypeAudio
                                                                    fromConnections:[[self movieFileOutput] connections]];
    return [audioConnection isActive];
}

- (BOOL)isRecording{
    return [[self movieFileOutput] isRecording];
}

- (void)stopRecording{
    [[self movieFileOutput] stopRecording];
}

- (void)startRecordingWithOrientation:(AVCaptureVideoOrientation)videoOrientation{
    AVCaptureConnection *videoConnection = [CameraUtilities connectionWithMediaType:AVMediaTypeVideo
                                                                    fromConnections:[[self movieFileOutput] connections]];
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:videoOrientation];
    }
    
    [[self movieFileOutput] startRecordingToOutputFileURL:[self outputFileURL]
                                        recordingDelegate:self];
}

#pragma mark - AVCaptureFileOutputRecording Delegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    if ([[self delegate] respondsToSelector:@selector(recorder:recordingDidFinishToOutputFileURL:error:)]) {
        [[self delegate] recorder:self recordingDidFinishToOutputFileURL:outputFileURL error:error];
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    if ([[self delegate] respondsToSelector:@selector(recorderRecordingDidBegin:)]) {
        [[self delegate] recorderRecordingDidBegin:self];
    }
}


@end
