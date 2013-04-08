//
//  CameraUtilities.h
//  Camera
//
//  Created by chen hongbin on 13-4-8.
//  Copyright (c) 2013年 chen hongbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVCaptureConnection;

@interface CameraUtilities : NSObject

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType
                                 fromConnections:(NSArray *)connections;
@end
