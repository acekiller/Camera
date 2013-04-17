//
//  ThemeImageView.m
//  Camera
//
//  Created by ChenHongbin on 13-3-26.
//  Copyright (c) 2013年 zhang xiangying. All rights reserved.
//

#import "ThemeImageView.h"
#import <QuartzCore/QuartzCore.h>

#define Selected_Background_Image  @"icon_selected_theme.png"

@interface ThemeImageView ()

@property(nonatomic, assign) CGPoint       touchLocation;             /*< 点中的位置   >*/
@property(nonatomic, strong) UILabel      *themeNameLabel;            /*< 主题Label   >*/
@property(nonatomic, strong) UIImageView  *selectedBackgroundView;    /*< 选中的背景图 >*/
@property(nonatomic, strong) UIImageView  *thumbImageView;            /*< 主题的缩略图 >*/
@end

@implementation ThemeImageView


- (void)awakeFromNib{
    [super awakeFromNib];
    [self initializ];
}

- (void)initializ{
    [self setUserInteractionEnabled:YES];
    [self setExclusiveTouch:YES];
    
    // add theme thumb Image
    CGRect rect = self.bounds;
    rect.size.width  -= 7;
    rect.size.height -= 7;
    self.thumbImageView = [[UIImageView alloc] initWithFrame:rect];
    self.thumbImageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [self.thumbImageView setBackgroundColor:[UIColor clearColor]];
    [self.thumbImageView setImage:[UIImage imageNamed:self.thumbImageName]];
    [self.thumbImageView.layer setMasksToBounds:YES];
    [self.thumbImageView.layer setCornerRadius:6.0f];
    [self addSubview:self.thumbImageView];
    
    // add theme name label
    self.themeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    self.themeNameLabel.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2+43);
    self.themeNameLabel.backgroundColor = [UIColor clearColor];
    self.themeNameLabel.text = self.themeName;
    self.themeNameLabel.textAlignment = NSTextAlignmentCenter;
    self.themeNameLabel.textColor = [UIColor whiteColor];
    self.themeNameLabel.shadowOffset = CGSizeMake(1.0f, 1.0f);
    [self addSubview:self.themeNameLabel];
    
    // add selected backgound image view
    self.selectedBackgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [self.selectedBackgroundView setBackgroundColor:[UIColor clearColor]];
    [self.selectedBackgroundView setImage:[UIImage imageNamed:Selected_Background_Image]];
    [self.selectedBackgroundView setHidden:YES];
    [self addSubview:self.selectedBackgroundView];
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializ];
    }
    return self;
}

#pragma mark - 手势代理方法
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.touchLocation = [[touches anyObject] locationInView:self];
    if ([self.delegate respondsToSelector:@selector(themeImageViewStartedTracking:)]) {
        [self.delegate themeImageViewStartedTracking:self];
    }
    [self selected:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(themeImageViewWasTapped:)]) {
        [self.delegate themeImageViewWasTapped:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(themeImageViewStoppedTracking:)]) {
        [self.delegate themeImageViewWasTapped:self];
    }
    [self selected:NO];
}

#pragma mark - 属性设置
/**
 *	@brief	设置是否选中状态
 *
 *	@param 	selected 	选中状态
 */
- (void)selected:(BOOL)selected{
    if (selected) {
        [self.selectedBackgroundView setHidden:NO];
        [self setUserInteractionEnabled:NO];
    }else{
        [self.selectedBackgroundView setHidden:YES];
        [self setUserInteractionEnabled:YES];
    }
}

/**
 *	@brief	设置主题名字
 *
 *	@param 	themeName 	主题名字，同时更新主题名字
 */
- (void)setThemeName:(NSString *)themeName{
    if (_themeName != themeName) {
         _themeName = [themeName copy];
        self.themeNameLabel.text = themeName;
    }
}

/**
 *	@brief	设置主题缩略图的名字，同时更新主题缩略图
 *
 *	@param 	thumbImageName  主题缩略图的名字
 */
- (void)setThumbImageName:(NSString *)thumbImageName{
    if (_thumbImageName != thumbImageName) {
        _thumbImageName = [thumbImageName copy];
        [self.thumbImageView setImage:[UIImage imageNamed:thumbImageName]];
    }
}
@end
