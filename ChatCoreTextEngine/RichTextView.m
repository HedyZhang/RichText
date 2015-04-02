//
//  RichTextView.m
//  ChatCoreTextEngine
//
//  Created by 张海迪 on 15/3/23.
//  Copyright (c) 2015年 haidi. All rights reserved.
//

#import "RichTextView.h"
#import <CoreText/CoreText.h>

/**
 *  正则匹配
 *
 */

#pragma mark --------------------------CTRegularExpressionManager---------------------------------
@interface CTRegularExpressionManager : NSObject

+ (NSArray *)itemIndexesWithPattern:(NSString *)pattern inString:(NSString *)findingString;

@end


@implementation CTRegularExpressionManager

/**
 *  返回符合 pattern 的所有位置
 *
 *  @param pattern       查找关键词
 *  @param findingString 查找的目标
 *
 *  @return 返回符合pattern的所有位置数组
 */
+ (NSArray *)itemIndexesWithPattern:(NSString *)pattern inString:(NSString *)findingString
{
    NSAssert(pattern != nil, @"%s: pattern 不可以为 nil", __PRETTY_FUNCTION__);
    NSAssert(findingString != nil, @"%s: findingString 不可以为 nil", __PRETTY_FUNCTION__);
    
    NSError *error = nil;
    NSRegularExpression *regExp = [[NSRegularExpression alloc] initWithPattern:
                                   pattern options:NSRegularExpressionCaseInsensitive
                                                                         error:&error];
    
    // 查找匹配的字符串
    NSArray *result = [regExp matchesInString:findingString options:
                       NSMatchingReportCompletion range:
                       NSMakeRange(0, [findingString length])];
    
    if (error) {
        NSLog(@"ERROR: %@", result);
        return nil;
    }
    
    NSUInteger count = [result count];
    // 没有查找到结果，返回空数组
    if (0 == count) {
        return [NSArray array];
    }
    
    // 将返回数组中的 NSTextCheckingResult 的实例的 range 取出生成新的 range 数组
    NSMutableArray *ranges = [[NSMutableArray alloc] initWithCapacity:count];
    for(NSInteger i = 0; i < count; i++)
    {
        @autoreleasepool {
            NSRange aRange = [[result objectAtIndex:i] range];
            [ranges addObject:[NSValue valueWithRange:aRange]];
        }
    }
    return ranges;
}
@end

#pragma mark -------------------------- NSString Category---------------------------------

/**
 *  字符串匹配
 *
 */

@interface NSString (Extension)

/*** 返回符合 pattern 的所有 items */
- (NSMutableArray *)itemsForPattern:(NSString *)pattern;

/*** 返回符合 pattern 的 捕获分组为 index 的所有 items */
- (NSMutableArray *)itemsForPattern:(NSString *)pattern captureGroupIndex:(NSUInteger)index;

/*** 返回符合 pattern 的第一个 item */
- (NSString *)itemForPatter:(NSString *)pattern;

/*** 返回符合 pattern 的 捕获分组为 index 的第一个 item */
- (NSString *)itemForPattern:(NSString *)pattern captureGroupIndex:(NSUInteger)index;

/*** 按 format 格式化字符串生成 NSDate 类型的对象，返回 timeString 时间与 1970年1月1日的时间间隔
 * @discussion 格式化后的 NSDate 类型对象为 +0000 时区时间
 */
- (NSTimeInterval)timeIntervalFromString:(NSString *)timeString withDateFormat:(NSString *)format;

/*** 按 format 格式化字符串生成 NSDate 类型的对象，返回当前时间距给定 timeString 之间的时间间隔
 * @discussion 格式化后的 NSDate 类型对象为本地时间
 */
- (NSTimeInterval)localTimeIntervalFromString:(NSString *)timeString withDateFormat:(NSString *)format;

- (BOOL)contains:(NSString *)piece;

// 删除字符串开头与结尾的空白符与换行
- (NSString *)trim;

@end

@implementation NSString (Extension)

#pragma mark - Regular expression
- (NSMutableArray *)itemsForPattern:(NSString *)pattern
{
    return [self itemsForPattern:pattern captureGroupIndex:0];
}

- (NSMutableArray *)itemsForPattern:(NSString *)pattern captureGroupIndex:(NSUInteger)index
{
    if ( !pattern )
        return nil;
    
    NSError *error = nil;
    NSRegularExpression *regx = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                     options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
    {
        NSLog(@"Error for create regular expression:\nString: %@\nPattern %@\nError: %@\n",self, pattern, error);
    }
    else
    {
        NSMutableArray *results = [[NSMutableArray alloc] init];
        NSRange searchRange = NSMakeRange(0, [self length]);
        [regx enumerateMatchesInString:self options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            
            NSRange groupRange =  [result rangeAtIndex:index];
            NSString *match = [self substringWithRange:groupRange];
            [results addObject:match];
        }];
        return results;
    }
    
    return nil;
}

- (NSString *)itemForPatter:(NSString *)pattern
{
    return [self itemForPattern:pattern captureGroupIndex:0];
}

- (NSString *)itemForPattern:(NSString *)pattern captureGroupIndex:(NSUInteger)index
{
    if ( !pattern )
        return nil;
    
    NSError *error = nil;
    NSRegularExpression *regx = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                     options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
    {
        NSLog(@"Error for create regular expression:\nString: %@\nPattern %@\nError: %@\n",self, pattern, error);
    }
    else
    {
        NSRange searchRange = NSMakeRange(0, [self length]);
        NSTextCheckingResult *result = [regx firstMatchInString:self options:0 range:searchRange];
        NSRange groupRange = [result rangeAtIndex:index];
        NSString *match = [self substringWithRange:groupRange];
        return match;
    }
    
    return nil;
}

#pragma mark - Time Interval
- (NSTimeInterval)timeIntervalFromString:(NSString *)timeString withDateFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [[formatter dateFromString:timeString] timeIntervalSince1970];
}

- (NSTimeInterval)localTimeIntervalFromString:(NSString *)timeString withDateFormat:(NSString *)format
{
    NSTimeInterval timeInterval = [self timeIntervalFromString:timeString withDateFormat:format];
    NSUInteger secondsOffset = [[NSTimeZone localTimeZone] secondsFromGMT];
    return (timeInterval + secondsOffset);
}

#pragma mark - Contains
- (BOOL)contains:(NSString *)piece
{
    return ( [self rangeOfString:piece].location != NSNotFound );
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (NSString *)replaceCharactersAtIndexes:(NSArray *)indexes withString:(NSString *)aString
{
    NSAssert(indexes != nil, @"%s: indexes 不可以为nil", __PRETTY_FUNCTION__);
    NSAssert(aString != nil, @"%s: aString 不可以为nil", __PRETTY_FUNCTION__);
    
    NSUInteger offset = 0;
    NSMutableString *raw = [self mutableCopy];
    
    NSInteger prevLength = 0;
    for(NSInteger i = 0; i < [indexes count]; i++)
    {
        @autoreleasepool {
            NSRange range = [[indexes objectAtIndex:i] rangeValue];
            prevLength = range.length;
            
            range.location -= offset;
            [raw replaceCharactersInRange:range withString:aString];
            offset = offset + prevLength - [aString length];
        }
    }
    
    return raw;
}

@end


#pragma mark -------------------------- NSArray Category-------------------------------------

/**
 *  获取特殊字符偏移
 *
 */

@interface NSArray (Extension)

- (NSArray *)offsetRangesInArrayBy:(NSUInteger)offset;

@end

@implementation NSArray (Extension)

- (NSArray *)offsetRangesInArrayBy:(NSUInteger)offset
{
    NSUInteger aOffset = 0;
    NSUInteger prevLength = 0;
    
    
    NSMutableArray *ranges = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for(NSInteger i = 0; i < [self count]; i++)
    {
        @autoreleasepool {
            NSRange range = [[self objectAtIndex:i] rangeValue];
            prevLength    = range.length;
            
            range.location -= aOffset;
            range.length    = offset;
            [ranges addObject:[NSValue valueWithRange:range]];
            
            aOffset = aOffset + prevLength - offset;
        }
    }
    
    return ranges;
}
@end


#pragma mark -------------------------- RichTextView ---------------------------------

@implementation RichTextView
{
    dispatch_queue_t queue;
    dispatch_group_t group;
    CTTypesetterRef typesetter;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
       
    }
    return self;
}
- (void)dealloc
{
    CFRelease(typesetter);
//    dispatch_release(group);    // iOS 6.0 以下需要手动释放
}
- (void)setEmotionString:(NSString *)emotionString
{
    if (_emotionString != emotionString)
    {
        _emotionString = emotionString;
         [self setup];
    }
}
- (void)setup
{
    group = dispatch_group_create();
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    [self prepare];
}

- (void)prepare
{
    self.backgroundColor = [UIColor whiteColor];
    
    [UIImage imageNamed:@"1.gif"];
    [UIImage imageNamed:@"2.gif"];
    [UIImage imageNamed:@"3.gif"];
    [UIImage imageNamed:@"4.gif"];
    
    [self cookEmotionString];
}

#pragma mark - Cook the emotion string

- (void)cookEmotionString
{
    CFTimeInterval startTime = CACurrentMediaTime();
    // 使用正则表达式查找特殊字符的位置
    NSArray *itemIndexes = [CTRegularExpressionManager itemIndexesWithPattern:
                            EmotionItemPattern inString:_emotionString];
    
    
    __weak id target = self;
    __block NSArray *names;
    __block NSString *newString;
    __block NSArray *newRanges;
    
    
    dispatch_group_async(group, queue, ^{
        // 查找表情对应的字符串 并加载相应的表情图片到内存中
        names = [_emotionString itemsForPattern:EmotionItemPattern captureGroupIndex:1];
    });
    dispatch_group_async(group, queue, ^{
        // 将 emotionString 中的特殊字符串替换为空格
        newString = [_emotionString replaceCharactersAtIndexes:itemIndexes
                                                    withString:PlaceHolder];
    });
    dispatch_group_async(group, queue, ^{
        // 新的表情的占位符的 range 数组
        newRanges = [itemIndexes offsetRangesInArrayBy:[PlaceHolder length]];
    });
    
    dispatch_group_notify(group, queue, ^{
        _emotionNames = names;
        _emotionRanges = newRanges;
        _attrEmotionString = [target createAttributedEmotionStringWithRanges:newRanges
                                                                   forString:newString];
        // 创建typesetter 太耗费时间，所以在 typesetter 创建的时间提前到绘图前
        typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)
                                                            (_attrEmotionString));
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [target setNeedsDisplay];
        });
    });
    CFTimeInterval endTime = CACurrentMediaTime();
    NSLog(@"cookEmotionString: %f", endTime - startTime);
}
#pragma mark - Utility for emotions relative operations
// 根据调整后的字符串，生成绘图时使用的 attribute string
- (NSAttributedString *)createAttributedEmotionStringWithRanges:(NSArray *)ranges
                                                      forString:(NSString*)aString
{
    NSAssert(_emotionString != nil, @"emotionString 不可以为Nil");
    NSAssert(aString != nil,        @"aString 不可以为Nil");
    
    
    NSMutableAttributedString *attrString =
    [[NSMutableAttributedString alloc] initWithString:aString];
    
    for(NSInteger i = 0; i < [ranges count]; i++)
    {
        NSRange range = [[ranges objectAtIndex:i] rangeValue];
        NSString *emotionName = [self.emotionNames objectAtIndex:i];
        [attrString addAttribute:AttributedImageNameKey value:emotionName range:range];
        [attrString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge_transfer id)newEmotionRunDelegate() range:range];
    }
    return attrString;
}

// 通过表情名获得表情的图片
- (UIImage *)getEmotionForKey:(NSString *)key
{
    // 使用系统缓存
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif", key]];
}

CTRunDelegateRef newEmotionRunDelegate()
{
    static NSString *emotionRunName = @"com.cocoabit.CBEmotionView.emotionRunName";
    
    CTRunDelegateCallbacks imageCallbacks;
    imageCallbacks.version = kCTRunDelegateVersion1;
    imageCallbacks.dealloc = RunDelegateDeallocCallback;
    imageCallbacks.getAscent = RunDelegateGetAscentCallback;
    imageCallbacks.getDescent = RunDelegateGetDescentCallback;
    imageCallbacks.getWidth = RunDelegateGetWidthCallback;
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks,
                                                       (__bridge void *)(emotionRunName));
    
    return runDelegate;
}

#pragma mark - Run delegate
void RunDelegateDeallocCallback( void* refCon )
{
    // Do nothing here
}

CGFloat RunDelegateGetAscentCallback( void *refCon )
{
    return FontHeight;
}

CGFloat RunDelegateGetDescentCallback(void *refCon)
{
    return 0.0;
}

CGFloat RunDelegateGetWidthCallback(void *refCon)
{
    // EmotionImageWidth + 2 * ImageLeftPadding
    return  19.0;
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    // 没有内容时取消本次绘制
    if (!typesetter)   return;
    
    CGFloat w = CGRectGetWidth(self.frame);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 保存 context 信息
    CGContextSaveGState(context);
    
    // 翻转坐标系
    Flip_Context(context, FontHeight);
    
    CGFloat y = 0;
    CFIndex start = 0;
    NSInteger length = [_attrEmotionString length];
    while (start < length)
    {
        CFIndex count = CTTypesetterSuggestClusterBreak(typesetter, start, w);
        CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count));
        CGContextSetTextPosition(context, 0, y);
        
        // 画字
        CTLineDraw(line, context);
        
        // 画表情
        DrawEmojiForLine(context, line, self, CGPointMake(0, y));
        
        start += count;
        y -= 13.0 + 4.0;
        
        CFRelease(line);
    }
    
    // 恢复 context 信息
    CGContextRestoreGState(context);
}


// 翻转坐标系
static inline
void Flip_Context(CGContextRef context, CGFloat offset) // offset为字体的高度
{
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -offset);
}

// 生成每个表情的 frame 坐标
static inline
CGPoint EmojiOriginForLine(CTLineRef line, CGPoint lineOrigin, CTRunRef run)
{
    CGFloat x = lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL) + ImageLeftPadding;
    CGFloat y = lineOrigin.y - ImageTopPadding;
    return CGPointMake(x, y);
}


// 绘制每行中的表情
void DrawEmojiForLine(CGContextRef context, CTLineRef line, id owner, CGPoint lineOrigin)
{
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    
    // 统计有多少个run
    NSUInteger count = CFArrayGetCount(runs);
    
    // 遍历查找表情run
    for(NSInteger i = 0; i < count; i++)
    {
        CTRunRef aRun = CFArrayGetValueAtIndex(runs, i);
        CFDictionaryRef attributes = CTRunGetAttributes(aRun);
        NSString *emojiName = (NSString *)CFDictionaryGetValue(attributes, AttributedImageNameKey);
        if (emojiName)
        {
            // 画表情
            CGRect imageRect = CGRectZero;
            imageRect.origin = EmojiOriginForLine(line, lineOrigin, aRun);
            imageRect.size = CGSizeMake(EmotionImageWidth, EmotionImageWidth);
            CGImageRef img = [[owner getEmotionForKey:emojiName] CGImage];
            CGContextDrawImage(context, imageRect, img);
        }
    }
}

//返回高度
- (float)getAttributedStringHeightWithString:(NSAttributedString *)string  WidthValue:(int) width
{
    float total_height = 0;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);    //string 为要计算高度的NSAttributedString
    CGRect drawingRect = CGRectMake(0, 0, width, 1000);  //这里的高要设置足够大
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    
    NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
    
    CGPoint origins[[linesArray count]];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    int line_y = (int) origins[[linesArray count] -1].y;  //最后一行line的原点y坐标
    
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    
    CTLineRef line = (__bridge CTLineRef) [linesArray objectAtIndex:[linesArray count]-1];
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    
    total_height = 1000 - line_y + (int) descent +1;    //+1为了纠正descent转换成int小数点后舍去的值
    
    CFRelease(textFrame);
    
    return total_height;
    
}

@end