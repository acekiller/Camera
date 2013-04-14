//
//  CameraCaptureManager.m
//  Camera
//
//  Created by chen hongbin on 13-4-8.
//  Copyright (c) 2013年 chen hongbin. All rights reserved.
//

#import "CameraCaptureManager.h"
#import "CameraUtilities.h"
#import "CameraRecorder.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

@interface CameraCaptureManager ()<CameraRecorderDelegate>
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *)frontFacingCamera;
- (AVCaptureDevice *)backFacingCamera;
- (AVCaptureDevice *)audioDevice;

- (NSURL *)tempFileURL;
- (void)removeFile:(NSURL *)outputFileURL;
- (void)copyFileToDocuments:(NSURL *)fileUEL;

- (void)deviceOrienfationDidChange;
@end


@implementation CameraCaptureManager

- (void)dealloc{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:[self deviceConnectedObserver]];
    [notificationCenter removeObserver:[self deviceDisconnectedObserver]];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [[self session] stopRunning];
    [_session release];
    [_videoInput release];
    [_audioInput release];
    [_stillImageOutput release];
    [_recorder release];
    
    [super dealloc];
}

- (id)init{
    self = [super init];
    if (self) {
        __block id weakSelf = self;
        
        void (^deviceConnectionedBlock)(NSNotification *) = ^(NSNotification *notification){
            AVCaptureDevice *device = [notification object];
            BOOL sessionHasDeviceWithMatchingMediaType = NO;
            NSString *deviceMediaType = nil;
            if ([device hasMediaType:AVMediaTypeAudio]) {
                deviceMediaType = AVMediaTypeAudio;
            }else if([device hasMediaType:AVMediaTypeVideo]){
                deviceMediaType = AVMediaTypeVideo;
            }
            
            if (deviceMediaType != nil) {
                for (AVCaptureDeviceInput *input in [_session inputs]) {
                    if ([[input device] hasMediaType:deviceMediaType]) {
                        sessionHasDeviceWithMatchingMediaType = YES;
                        break;
                    }
                }
                
                if (!sessionHasDeviceWithMatchingMediaType) {
                    NSError *error;
                    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                    if ([_session canAddInput:input]) {
                        [_session addInput:input];
                    }
                }
            }
            
            if ([_delegate respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
                [_delegate captureManagerDeviceConfigurationChanged:self];
            }
        };
        
        void (^deviceDisconnectedBlock)(NSNotification *) = ^(NSNotification *notification){
            AVCaptureDevice *device = [notification object];
            if ([device hasMediaType:AVMediaTypeAudio]) {
                [_session removeInput:[weakSelf audioInput]];
                [weakSelf setAudioInput:nil];
            }else if ([device hasMediaType:AVMediaTypeVideo]){
                [_session removeInput:[weakSelf videoInput]];
                [weakSelf setVideoInput:nil];
            }
            
            if ([_delegate respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
                [_delegate captureManagerDeviceConfigurationChanged:self];
            }
        };
        
        
        // The list of avaliable devices may change, though. Current devices may become unavailable (if they're used by another application)
        // and new devices may become available, (if they're relinquished by another application).
        // you should register to receive AVCaptureDeviceWasConnectionNotification and
        // AVCaptureDeviceWasDisconnectionedNotification notifications to be alerted when the list of avaliable devices changes
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [self setDeviceConnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification
                                                                         object:nil
                                                                          queue:nil
                                                                    usingBlock:deviceConnectionedBlock]];
        [self setDeviceDisconnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification
                                                                            object:nil
                                                                             queue:nil
                                                                        usingBlock:deviceDisconnectedBlock]];
        
        // You must call this method before attempting to get orientation data from the receiver.
        // This method enables the device’s accelerometer hardware and begins the delivery of acceleration events to the receiver.
        // The receiver subsequently uses these events to post UIDeviceOrientationDidChangeNotification notifications
        // when the device orientation changes and to update the orientation property.
        // You may nest calls to this method safely, but you should always match each call with a corresponding call to the endGeneratingDeviceOrientationNotifications method.
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [notificationCenter addObserver:self
                               selector:@selector(deviceOrienfationDidChange)
                                   name:UIDeviceOrientationDidChangeNotification
                                 object:nil];
         _orientation = AVCaptureVideoOrientationPortrait;
    }
    
    return self;
}

- (BOOL)setupSession{
    BOOL success = NO;
    
    // set flash and torch mode to auto
    if ([[self backFacingCamera] hasFlash]) {
        if ([[self backFacingCamera] lockForConfiguration:nil]) {
            if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [[self backFacingCamera] setFlashMode:AVCaptureFlashModeAuto];
            }
            [[self backFacingCamera] unlockForConfiguration];
        }
    }
    
    if ([[self backFacingCamera] hasTorch]) {
        if ([[self backFacingCamera] lockForConfiguration:nil]) {
            if ([[self backFacingCamera] isTorchModeSupported:AVCaptureTorchModeAuto]) {
                [[self backFacingCamera] setTorchMode:AVCaptureTorchModeAuto];
            }
            [[self backFacingCamera] unlockForConfiguration];
        }
    }
    
    // Init the device inputs
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
    AVCaptureDeviceInput *newAudioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
    
    // Setup the still image file output
    AVCaptureStillImageOutput *newStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    // You can find out what pixel and codec types are suppoted using availableImageDataCVPixelFormatTypes
    // and availableImageDataCodecTypes respectively. Set the outputSettings dictionary to specify the
    // image format you want.
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [newStillImageOutput setOutputSettings:outputSettings];
    [outputSettings release];
    
    // Create session (use default AVCaptureSessionPresetHigh)
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    if ([captureSession canAddInput:newVideoInput]) {
        [captureSession addInput:newVideoInput];
    }
    
    if ([captureSession canAddInput:newAudioInput]) {
        [captureSession addInput:newAudioInput];
    }
    
    if ([captureSession canAddOutput:newStillImageOutput]) {
        [captureSession addOutput:newStillImageOutput];
    }
    
    [self setSession:captureSession];
    [self setVideoInput:newVideoInput];
    [self setAudioInput:newAudioInput];
    [self setStillImageOutput:newStillImageOutput];
    
    [newStillImageOutput release];
    [newVideoInput release];
    [newAudioInput release];
    [captureSession release];
    
    
    // Set up the movie file output
    NSURL *outputFileURL = [self tempFileURL];
    CameraRecorder *newRecorder = [[CameraRecorder alloc] initWithSession:_session outputFileURL:outputFileURL];
    [newRecorder setDelegate:self];
    
    // send an error to the delegate if video recording is unavailable
    if ([newRecorder recordsVideo] && [newRecorder recordsAudio]) {
        NSString *localizedDescription = @"Video recording unavailable";
        NSString *localizedFailureReason = @"Movies recorded on this device will only contain audio. They will be accessible through iTunes file sharing.";
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription,NSLocalizedDescriptionKey,
                                   localizedFailureReason,NSLocalizedFailureReasonErrorKey,nil];
        NSError *noVideoError = [NSError errorWithDomain:@"Camera" code:0 userInfo:errorDict];
        if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
            [[self delegate] captureManager:self didFailWithError:noVideoError];
        }
    }
    
    [self setRecorder:newRecorder];
    [newRecorder release];
    
    return success= YES;
}

- (void)startRecording{
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        // 通过调用beginBackgroundTaskWithExpirationHandler:, 我们基本上告诉了系统，我们需要更多的时间来完成某件事情，我们承诺在完成后告诉它，
        // 如果系统断定我们运行了太长时间并决定停止运行，可以调用我们作为参数提供的程序块。
        // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not
        // received until Camera returens to the foreground unless you request background execution time. This aslo ensures that
        // there will be time to write the file to the assets library when Camera is background. To conclude this background execution.
        // -endBackgroundTask is called in -recoder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saves.
        [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}]];
    }
    
    [self removeFile:[[self recorder] outputFileURL]];
    [[self recorder] startRecordingWithOrientation:_orientation];
}

- (void)stopRecording{
    [[self recorder] stopRecording];
}

- (void)captureStillImage{
    AVCaptureConnection *stillImageConnection = [CameraUtilities connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    if ([stillImageConnection isVideoOrientationSupported]) {
        [stillImageConnection setVideoOrientation:_orientation];
    }
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:(AVCaptureConnection *)stillImageConnection
                                                         completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                             
                                                             ALAssetsLibraryWriteImageCompletionBlock  completionBlock = ^(NSURL *assetURL, NSError *error){
                                                                 if (error) {
                                                                     if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                                                                         [[self delegate] captureManager:self didFailWithError:error];
                                                                     }
                                                                 }
                                                             };
                                                             
                                                             if (imageDataSampleBuffer != nil) {
                                                                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                 ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                                                                 UIImage *image = [[UIImage alloc] initWithData:imageData];
//                                                                 [library writeImageToSavedPhotosAlbum:image.CGImage orientation:_orientation completionBlock:completionBlock];
                                                                 [image release];
                                                             }else{
                                                                 completionBlock(nil, error);
                                                             }
                                                             
                                                             if ([[self delegate] respondsToSelector:@selector(captureManagerStillImageCaptured:)]) {
                                                                 [self.delegate captureManagerStillImageCaptured:self];
                                                             }
    }];
}

#pragma mark - Capture Setting
- (BOOL)toggleCamera{
    BOOL success = NO;
    if ([self cametaCount] > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[_videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
        }else if (position == AVCaptureDevicePositionFront){
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
        }else{
            goto bail;
        }
        
        if (newVideoInput != nil) {
            [[self session] beginConfiguration];
            [[self session] removeInput:[self videoInput]];
            if ([[self session] canAddInput:newVideoInput]) {
                [[self session] addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            }else{
                [[self session] addInput:[self videoInput]];
            }
            [[self session] commitConfiguration];
            success = YES;
            [newVideoInput release];
        }
        else if (error){
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }
    }

    bail:
    return success;
}

#pragma maek - Set Camera Device Properties
- (void)autoFocusAtpoint:(CGPoint)point{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        }else {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }
    }
}

- (void)continuousFocusAtPoint:(CGPoint)point{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [device unlockForConfiguration];
        }else{
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }
    }
    
}

#pragma mark Device Counts
- (NSUInteger)cametaCount{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (NSUInteger)micCount{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count];
}

// Keep track of current device orientation so it can be applied to movie recordinds and still image captures
- (void)deviceOrienfationDidChange{
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (deviceOrientation == UIDeviceOrientationPortrait) {
        _orientation = UIDeviceOrientationPortrait;
    }else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown){
        _orientation = UIDeviceOrientationPortraitUpsideDown;
        
    // AVCapture and UIDevice have opposite meanings for landscape lefr and right
    // (AVCapture orientation is the same as UIInterfaceOrientation)
    }else if (deviceOrientation == UIDeviceOrientationLandscapeLeft){
        _orientation = UIDeviceOrientationLandscapeRight;
    }else if (deviceOrientation == UIDeviceOrientationLandscapeRight){
        _orientation = UIDeviceOrientationLandscapeLeft;
    }
    
    // Ignore Device orientatios for which there is no corresponding still image orientation (e.g.UIDeviceOrientationFaceUp)
}

#pragma mark - Save File URL
- (NSURL *)tempFileURL{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(),@"output.mov"]];
}

- (void)removeFile:(NSURL *)outputFileURL{
    NSString *filePath = [outputFileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        if (![fileManager removeItemAtPath:filePath error:&error]) {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError::)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }
    }
}

- (void)copyFileToDocuments:(NSURL *)fileUEL{
    // 生成文件存储路径
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"/output_%@",[dateFormatter stringFromDate:[NSDate date]]];
    [dateFormatter release];
    
    // 存放文件
    NSError *error;
    if (![[NSFileManager defaultManager] copyItemAtURL:fileUEL toURL:[NSURL fileURLWithPath:destinationPath] error:&error]) {
        if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
            [[self delegate] captureManager:self didFailWithError:error];
        }
    }
}

#pragma mark - Camera Device
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)frontFacingCamera{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backFacingCamera{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *)audioDevice{    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
//    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
//    if ([devices count] > 0) {
//        return [devices objectAtIndex:0];
//    }
//    return nil;
}

- (void)recorder:(CameraRecorder *)recorder recordingDidFinishToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error{
    if ([[self recorder] recordsAudio] && [[self recorder] recordsVideo]) {
        
        [self copyFileToDocuments:outputFileURL];
        if ([[UIDevice currentDevice] isMultitaskingSupported]) {
            [[UIApplication sharedApplication] endBackgroundTask:[self backgroundRecordingID]];
        }
        
        if ([[self delegate] respondsToSelector:@selector(captureManagerRecordingFinished:)]) {
            [self.delegate captureManagerRecordingFinished:self];
        }
    }else {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
                                    completionBlock:^(NSURL *assetURL, NSError *error) {
                                        if (error) {
                                            if ([self.delegate respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                                                [self.delegate captureManager:self didFailWithError:error];
                                            }
                                        }
                                        
                                        if ([[UIDevice currentDevice] isMultitaskingSupported]) {
                                            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundRecordingID];
                                        }
                                        
                                        if ([[self delegate] respondsToSelector:@selector(captureManagerRecordingFinished:)]) {
											[[self delegate] captureManagerRecordingFinished:self];
										}
                                    }];
        [library release];
    }
}

- (void)recorderRecordingDidBegin:(CameraRecorder *)recorder{
    if ([[self delegate] respondsToSelector:@selector(captureManagerRecordingBegan:)]) {
        [self.delegate captureManagerRecordingBegan:self];
    }
}
@end
