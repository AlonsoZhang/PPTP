//
//  PPTP.h
//  PPTP
//
//  Created by Alonso on 2018/6/5.
//  Copyright © 2018 Alonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface PPTP : NSObject
{
    NSStatusItem *StatusItem;
    NSTimer      *UpdataTime;
    BOOL Connected;
}

-(id)init:(NSStatusItem *)Source;
-(void)RunXPC:(const char* )CMD;
-(void)Connect;
-(void)DisConnect;

@end
