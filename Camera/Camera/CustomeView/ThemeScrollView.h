//
//  ThemeScrollView.h
//  Camera
//
//  Created by zhang xiangying on 13-3-26.
//  Copyright (c) 2013年 ChenHongbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemeImageView.h"
#import "ThemeMaterial.h"

@class ThemeScrollView;

@protocol ThemeScrollViewDelegate<NSObject>

@optional
/**
 *	@brief	选择相应的主题
 *
 *	@param 	index 	主题位置
 */
- (void)selectedItem:(NSInteger)index;

/**
 *	@brief	当点中某个节点素材的时候，自动调用此函数
 */
- (void)themeScrollView:(ThemeScrollView *)themeScrollView didSelectMaterila:(ThemeMaterial *)material;
@end


@interface ThemeScrollView : UIView <ThemeImageViewDelegate>

@property(nonatomic, weak) id<ThemeScrollViewDelegate> delegate;      /*< 事件代理 >*/
@property(nonatomic, strong) UIImage         *backgroundImage;               /*< 背景图 >*/
@property(nonatomic, strong) NSMutableArray  *themeImages;                   /*< 所有的主题 >*/
@property(nonatomic, strong) UIButton        *btnlastThemeCell;              /*< 最后一个视图按钮，--以后扩张为“更多”按钮 >*/

- (CGPoint)getContentOffsetAtIndex:(NSInteger)index;
- (void)setContentStartAtIndex:(NSInteger)index;
- (void)setContentEndAtIndex:(NSInteger)index;

/**
 *	@brief	设置当前的项为高亮
 */
- (void)setCurrentSelectedItem:(NSInteger)index;

/**
 *	@brief	运动scrollview到显示指定索引的位置
 *
 *	@param 	index 	指定位置
 */
- (void)scrollToItemAtIndex:(NSInteger)index;
@end
