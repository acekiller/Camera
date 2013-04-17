//
//  ThemeMaterial.h
//  Camera
//
//  Created by zhang xiangying on 13-3-26.
//  Copyright (c) 2013年 ChenHongbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeMaterial : NSObject

@property(nonatomic, assign) NSInteger  themeID;            /*< 主题名称 >*/
@property(nonatomic, strong) NSString  *themeName;          /*< 主题名称 >*/
@property(nonatomic, strong) NSString  *thumbImageName;     /*< 主题小图名称 >*/
@property(nonatomic, strong) NSString  *bigImageName;       /*< 主题大图名称 >*/

/**
 *	@brief	根据主题的资源初始化主题
 *
 *	@param 	dict 	每个主题的详细资料
 *
 *	@return	返回主题对象
 */
- (id)initWithDictionary:(NSDictionary *)dict;
@end
