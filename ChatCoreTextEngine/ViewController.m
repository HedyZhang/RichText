//
//  ViewController.m
//  ChatCoreTextEngine
//
//  Created by 张海迪 on 15/3/23.
//  Copyright (c) 2015年 haidi. All rights reserved.
//

#import "ViewController.h"
#import "RichTextView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RichTextView *textView = [[RichTextView alloc] initWithFrame:CGRectMake(10, 50, 300, 200)];
    textView.emotionString = @"</1>中文（Chinese），一般特指汉字</1></1>，即汉语的文字表达形式</2>。但</2>有时广义的</3>概念也有所扩展，即既包括书写</4>体系，也包括发音</4>体系。</1>中文的使用人数在15亿以上，范围包括中国（含香港、澳门、台湾地区）、新加坡、马来西亚、印度尼西亚、泰国、越南、柬埔寨、缅甸以及世界各地的华人社区。(</2></1>) -- Code4App 收录代码";
    [self.view addSubview:textView];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
