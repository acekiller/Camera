//
//  CameraUtilities.m
//  Camera
//
//  Created by chen hongbin on 13-4-8.
//  Copyright (c) 2013年 chen hongbin. All rights reserved.
//

#import "CameraUtilities.h"
#import <AVFoundation/AVFoundation.h>

@implementation CameraUtilities

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType
                                 fromConnections:(NSArray *)connections{
    for (AVCaptureConnection *connection in connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:mediaType]) {
                return connection;
            }
        }
    }
    return nil;
}
@end
