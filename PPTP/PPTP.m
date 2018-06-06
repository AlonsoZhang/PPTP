//
//  PPTP.m
//  PPTP
//
//  Created by Alonso on 2018/6/5.
//  Copyright © 2018 Alonso. All rights reserved.
//

#import "PPTP.h"
#define XPCServer "zhangwu.tech.ZWHelper"

@implementation PPTP

- (id)init:(NSStatusItem *)Source
{
    self = [super init];
    if (self)
    {
        StatusItem  = Source;
        Connected   = false;
        
        NSString *CMD = [NSString stringWithFormat:@"sudo cp -r %@/peers /private/etc/ppp",  [[NSBundle mainBundle] resourcePath] ];
        [self RunXPC:[CMD UTF8String]];
    }
    return self;
}

-(void)Connect
{
    [self RunXPC:"sudo pppd call PPTP &"];
    UpdataTime = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(CheckIP)
                                                userInfo:nil repeats:YES];
}

-(void)DisConnect
{
    [UpdataTime invalidate];
    Connected  = false;
    [self RunXPC:"killall pppd"];
    [StatusItem setImage:[NSImage imageNamed:@"VPND"]];
}

-(void)RunXPC:(const char* )CMD
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        xpc_connection_t connection = xpc_connection_create_mach_service(XPCServer, NULL, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);
        if (!connection)
        {
            return;
        }
        xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
            xpc_type_t type = xpc_get_type(event);
            
            if (type == XPC_TYPE_ERROR)
            {
                if (event == XPC_ERROR_CONNECTION_INTERRUPTED)
                {
                }
                else if (event == XPC_ERROR_CONNECTION_INVALID)
                {
                    
                }
                else
                {
                    
                }
            }
            else
            {
                
            }
        });
        xpc_connection_resume(connection);
        xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
        xpc_dictionary_set_string(message, "request", CMD);
        xpc_dictionary_set_date(message, "worktype", 1);
        xpc_connection_send_message_with_reply(connection, message, dispatch_get_main_queue(), ^(xpc_object_t event) {
            const char* response = xpc_dictionary_get_string(event, "reply");
            NSLog(@"%s",response);
        });
    });
}

- (void)CheckIP
{
    NSString *address = @"";
    NSString *address1 = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                address1 = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                if(![address1 isEqualToString:@"127.0.0.1"])
                    address = [NSString stringWithFormat:@"%@%@\n",address,address1];
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    
    if( !Connected )
    {
        if ([address1 rangeOfString:@"192.168"].location != NSNotFound )
        {
            [StatusItem setImage:[NSImage imageNamed:@"VPNC"]];
            Connected = true;
        }
    }
    else
    {
        if ([address1 rangeOfString:@"192.168"].location == NSNotFound )
        {
            [self DisConnect];
        }
    }
}

@end
