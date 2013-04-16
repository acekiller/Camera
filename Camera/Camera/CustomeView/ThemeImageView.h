//
//  ThemeImageView.h
//  Camera
//
//  Created by zhang xiangying on 13-3-26.
//  Copyright (c) 2013年 ChenHongbin. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ThemeImageView;

/**
 *	@brief	每个主题缩略图的代理
 */
@protocol ThemeImageViewDelegate <NSObject>

@optional
/**
 *	@brief	点击
 *
 *	@param 	themeImageView 	被点击的主题
 */
- (void)themeImageViewWasTapped:(ThemeImageView *)themeImageView;

/**
 *	@brief	开始拖拉
 *
 *	@param 	themeImageView 	被拖拉的主题
 */
- (void)themeImageViewStartedTracking:(ThemeImageView *)themeImageView;

/**
 *	@brief	移动
 *
 *	@param 	themeImageView 	移动的主题
 */
- (void)themeImageViewMoved:(ThemeImageView *)themeImageView;

/**
 *	@brief	停止拖拉
 *
 *	@param 	themeImageView 	停止拖拉的主题
 */
- (void)themeImageViewStoppedTracking:(ThemeImageView *)themeImageView;
@end


@interface ThemeImageView : UIView

@property(nonatomic, assign) id<ThemeImageViewDelegate> delegate;         /*< 事件代理 >*/
@property(nonatomic, retain) NSString *themeName;                         /*< 主题名称 >*/
@property(nonatomic, retain) NSString *thumbImageName;                    /*< 主题缩略图名称 >*/

/**
 *	@brief	设置是否选中状态
 *
 *	@param 	selected 	选中状态
 */
- (void)selected:(BOOL)selected;
@end
