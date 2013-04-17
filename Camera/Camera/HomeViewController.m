//
//  ViewController.m
//  Camera
//
//  Created by chen hongbin on 13-4-8.
//  Copyright (c) 2013年 chen hongbin. All rights reserved.
//

#import "HomeViewController.h"
#import "TakeVideoViewController.h"
#import "TakePhotoViewController.h"

@interface HomeViewController ()

/**
 *	@brief	拍照功能
 */
- (IBAction)handleActionTakePhoto:(id)sender;

/**
 *	@brief	录制视频功能
 */
- (IBAction)handleActionTakeVideo:(id)sender;
@end

@implementation HomeViewController

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Methods
- (IBAction)handleActionTakePhoto:(id)sender {
    TakePhotoViewController *takePhotoViewController = [[TakePhotoViewController alloc] initWithNibName:@"TakePhotoViewController" bundle:nil];
    [self.navigationController pushViewController:takePhotoViewController animated:YES];
     takePhotoViewController = nil;
}

- (IBAction)handleActionTakeVideo:(id)sender {
    TakeVideoViewController *takeVideoViewController = [[TakeVideoViewController alloc] initWithNibName:@"TakeVideoViewController" bundle:nil];
    [self.navigationController pushViewController:takeVideoViewController animated:YES];
    takeVideoViewController = nil;
}
@end
