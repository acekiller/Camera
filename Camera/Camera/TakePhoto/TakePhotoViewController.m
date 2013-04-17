//
//  TakeVideoViewController.m
//  Camera
//
//  Created by chen hongbin on 13-4-8.
//  Copyright (c) 2013年 chen hongbin. All rights reserved.
//

#import "TakePhotoViewController.h"
#import "CameraCaptureManager.h"
#import "CameraRecorder.h"
#import "ThemeScrollView.h"
#import <AVFoundation/AVFoundation.h>

@interface TakePhotoViewController ()<CamperaCaptureManagerDelegate,ThemeScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *viewFrameContainer;
@property (strong, nonatomic) IBOutlet ThemeScrollView *frameScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewFrame;

//- (CGPoint)converToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;

/**
 *	@brief	翻转摄像头
 */
- (IBAction)handleActionToggleCamera:(id)sender;

/**
 *	@brief	拍照
 */
- (IBAction)handleActionTakePhoto:(id)sender;

/**
 *	@brief	打开相册
 */
- (IBAction)handleActionOpenCameraRoll:(id)sender;

/**
 *	@brief	现实或隐藏照片边框
 */
- (IBAction)handleActionTogglePhotoFrame:(id)sender;
@end

@implementation TakePhotoViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload {
    [self setViewFrameContainer:nil];
    [self setFrameScrollView:nil];
    [self setImageViewFrame:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // 加载边框
    [self.frameScrollView setDelegate:self];
    [self.frameScrollView setCurrentSelectedItem:0];
    [self.frameScrollView scrollToItemAtIndex:0];
    
    if ([self captureManager] == nil) {
        CameraCaptureManager *manager = [[CameraCaptureManager alloc] init];
        [self setCaptureManager:manager];
        
        [[self captureManager] setDelegate:self];
        
        if ([[self captureManager] setupSession]) {
            // Create video preview layer and add it to the UI
            AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
            UIView *view = [self videoPreviewView];
            CALayer *viewLayer = [view layer];
            [viewLayer setMasksToBounds:YES];
            
            CGRect bounds = [view bounds];
            [newCaptureVideoPreviewLayer setFrame:bounds];
            
            if ([newCaptureVideoPreviewLayer isOrientationSupported]) {
                [newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
            }
            [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            [viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
            [self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[[self captureManager] session] startRunning];
            });
        }
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
// Convert from view coordinates to camera coordinates, where {0,0} represents the top left of the picture area, and {1,1} represents
// the bottom right in landscape mode with the home button on the right.
//- (CGPoint)converToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates{
//    CGPoint pointOfInterest = CGPointMake(0.5f, 0.5f);
//    CGSize  frameSize = [self.videoPreviewView frame].size;
//    
//    if ([_captureVideoPreviewLayer isMirrored]) {
//        viewCoordinates.x = frameSize.width - viewCoordinates.x;
//    }
//    
//    if ([[_captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize]) {
//        // Scale, switch x and y, and reverse x
//        pointOfInterest = CGPointMake(viewCoordinates.y/frameSize.height, 1.0 - (viewCoordinates.x/frameSize.width));
//    }else{
//        CGRect cleanAperture;
//        for (AVCaptureInputPort *port in [[[self captureManager] videoInput] ports]) {
//            if ([port mediaType] == AVMediaTypeVideo) {
//                
//                // get the clean aperture
//                // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
//                // that represents image data valid for display.
//                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
//                CGSize apertureSize = cleanAperture.size;
//                CGPoint point = viewCoordinates;
//                
//                CGFloat aperureRatio = apertureSize.height / apertureSize.width;
//                CGFloat viewRatio    = frameSize.width / frameSize.height;
//                CGFloat xc = 0.5f;
//                CGFloat yc = 0.5f;
//                
//                if ([[_captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect]) {
//                    if (viewRatio > aperureRatio) {
//                        CGFloat y2 = frameSize.height;
//                        CGFloat x2 = frameSize.height * aperureRatio;
//                        CGFloat x1 = frameSize.width;
//                        CGFloat blackBar = (x1 - x2)/2;
//                        
//                        // If point is inside letterboxed area, do coordinate conversion;
//                        // otherwise, don't change the default value returned (.5, .5)
//                        if (point.x >= blackBar && point.x <= blackBar + x2) {
//                            // Scale (accouting for the letterboxing on the left and right of the video preview)
//                            // switch x and y, and reverse x
//                            xc = point.y / y2;
//                            yc = 1.0f - (point.x - blackBar)/x2;
//                        }
//                    }else{
//                        CGFloat y2 = frameSize.width/aperureRatio;
//                        CGFloat y1 = frameSize.height;
//                        CGFloat x2 = frameSize.width;
//                        CGFloat blackBar = (y1 - y2)/2;
//                        
//                        // If point is inside letterboxed area, do coordinate conversion
//                        // otherwise, don't change the default value returned (.5, .5)
//                        if (point.y >= blackBar && point.y <= blackBar + y2) {
//                            // Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
//                            xc = (point.y - blackBar)/y2;
//                            yc = 1.0f - (point.x/x2);                                                                                                                                         
//                        }
//                    }
//                    
//                }else if ([[_captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]){
//                    
//                }
//                
//                // if point is inside letterboxed area, do coordinate conversi
//            }
//            
//        }
//    }
//}

#pragma mark - IBAction Methods
- (IBAction)handleActionToggleCamera:(id)sender {
    // Toggle between cameras when there is more than one
    [[self captureManager] toggleCamera];
    
    // Do an initial fouchs
    [[self captureManager] continuousFocusAtPoint:CGPointMake(0.5, 0.5)];
}

- (IBAction)handleActionTakePhoto:(id)sender {
    
    [[self captureManager] captureStillImage];
    // Flash the screen white and fade it out to give UI feeback that a still image was token
    UIView *flashView = [[UIView alloc] initWithFrame:self.videoPreviewView.frame];
    [flashView setBackgroundColor:[UIColor whiteColor]];
    [[self.view window] addSubview:flashView];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [flashView setAlpha:0.0f];
                     } completion:^(BOOL finished) {
                         [flashView removeFromSuperview];
                     }];
}

- (IBAction)handleActionOpenCameraRoll:(id)sender {
}

- (IBAction)handleActionTogglePhotoFrame:(id)sender {
}

#pragma mark - ScrollView Delegate
- (void)themeScrollView:(ThemeScrollView *)themeScrollView didSelectMaterila:(ThemeMaterial *)material{
    [self.imageViewFrame setImage:[UIImage imageNamed:material.bigImageName]];
}

#pragma mark - CameCaptureManager Delegate
- (void)captureManager:(CameraCaptureManager *)captureManger didFailWithError:(NSError *)error{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}

- (void)captureManagerRecordingBegan:(CameraCaptureManager *)captureManger{
    
}

- (void)captureManagerRecordingFinished:(CameraCaptureManager *)captureManger{
    
}

- (void)captureManagerStillImageCaptured:(CameraCaptureManager *)captureManger{
    
}

- (void)captureManagerDeviceConfigurationChanged:(CameraCaptureManager *)captureManager{
}
@end
