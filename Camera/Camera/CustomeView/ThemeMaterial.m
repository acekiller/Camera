//
//  ThemeMaterial.m
//  Camera
//
//  Created by zhang xiangying on 13-3-26.
//  Copyright (c) 2013年 ChenHongbin. All rights reserved.
//

#import "ThemeMaterial.h"

@implementation ThemeMaterial

/**
 *	@brief	根据主题的资源初始化主题
 *
 *	@param 	dict 	每个主题的详细资料
 *
 *	@return	返回主题对象
 */
- (id)initWithDictionary:(NSDictionary *)dict{
    if (self = [super init]) {
        self.themeID        = [[dict objectForKey:@"ID"] integerValue];
        self.themeName      = [dict objectForKey:@"name"];
        self.thumbImageName = [dict objectForKey:@"thumb"];
        self.bigImageName   = [dict objectForKey:@"frame"];
    }
    return self;
}

@end
