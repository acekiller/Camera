//
//  TakeVideoViewController.h
//  Camera
//
//  Created by chen hongbin on 13-4-8.
//  Copyright (c) 2013年 chen hongbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraCaptureManager;
@class AVCaptureVideoPreviewLayer;

/**
 *	@brief	相机主界面
 */
@interface TakePhotoViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) CameraCaptureManager          *captureManager;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer    *captureVideoPreviewLayer;
@property (nonatomic, strong) IBOutlet UIView               *videoPreviewView;


@end
