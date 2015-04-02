//
//  RichTextView.h
//  ChatCoreTextEngine
//
//  Created by 张海迪 on 15/3/23.
//  Copyright (c) 2015年 haidi. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define EmotionItemPattern          @"\\[/[\u4E00-\u9FFF]+\\]"
#define EmotionItemPattern          @"</(\\w+)>"

#define PlaceHolder                 @" "
#define EmotionFileType             @"gif"
#define AttributedImageNameKey      @"ImageName"

#define EmotionImageWidth           15.0
#define FontHeight                  15.0
#define ImageLeftPadding            2.0
#define ImageTopPadding             3.0



@interface RichTextView : UIView

// 原始的字符串
@property (nonatomic, strong) NSString *emotionString;

// 处理过后的用户绘图的富文本字符串
@property (nonatomic, readonly) NSAttributedString *attrEmotionString;

// 按顺序保存的 emotionString 中包含的表情名字
@property (nonatomic, readonly) NSArray *emotionNames;

@property (nonatomic, readonly) NSArray *emotionRanges;



- (instancetype)initWithFrame:(CGRect)frame;

/// 将 emotionString 中的特殊字符串替换为空格
// @discussion 不要直接调用此方法
- (void)cookEmotionString;




@end
