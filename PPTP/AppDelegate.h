//
//  AppDelegate.h
//  PPTP
//
//  Created by Alonso on 2018/6/5.
//  Copyright © 2018 Alonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PPTP.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    PPTP *MyPPTP;
}

@property(readwrite, retain) NSStatusItem *StatusItem;

@end

//参考文章https://blog.csdn.net/suhuaiqiang_janlay/article/details/71374287
