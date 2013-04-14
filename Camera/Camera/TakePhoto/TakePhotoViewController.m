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
#import <AVFoundation/AVFoundation.h>

@interface TakePhotoViewController ()<CamperaCaptureManagerDelegate>

- (CGPoint)converToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;

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

- (void)dealloc{
    [_captureManager release];
    [_videoPreviewView release];
    [_captureVideoPreviewLayer release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if ([self captureManager] == nil) {
        CameraCaptureManager *manager = [[CameraCaptureManager alloc] init];
        [self setCaptureManager:manager];
        [manager release];
        
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
            [newCaptureVideoPreviewLayer release];
            
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
                         [flashView release];
                     }];
}

- (IBAction)handleActionOpenCameraRoll:(id)sender {
}

- (IBAction)handleActionTogglePhotoFrame:(id)sender {
}

#pragma mark - 
@end
