//
//  AppDelegate.m
//  PPTP
//
//  Created by Alonso on 2018/6/5.
//  Copyright © 2018 Alonso. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSFileManager * fm = [NSFileManager defaultManager];
    BOOL PlistisYES    = [fm fileExistsAtPath:@"/Library/LaunchDaemons/com.apple.bsd.SMJobBlessHelper.plist"];
    BOOL HelperisYES   = [fm fileExistsAtPath:@"/Library/PrivilegedHelperTools/com.apple.bsd.SMJobBlessHelper"];
    
    if ( !PlistisYES || !HelperisYES)
    {
        NSError *error = nil;
        if (![self blessHelperWithLabel:@"com.apple.bsd.SMJobBlessHelper" error:&error])
        {
            NSString *statues=[NSString stringWithFormat:@"Failed to bless helper. Error: %@",error];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@""];
            [alert setInformativeText:statues];
            [alert addButtonWithTitle:@"OK"];
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert runModal];
            [NSApp terminate:nil];
            return;
        }
    }
    
    
    self.StatusItem  = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self StatusBarItem];
    
    
    MyPPTP = [[PPTP alloc]init:self.StatusItem];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)StatusBarItem
{
    NSMenu *MainMenu = [[NSMenu alloc]init];
    
    
    NSMenuItem *ToConnect = [[NSMenuItem alloc] initWithTitle:@"Connect" action:@selector(Connect) keyEquivalent:@""];
    [MainMenu addItem:ToConnect];
    
    NSMenuItem *DisConnect = [[NSMenuItem alloc] initWithTitle:@"DisConnect" action:@selector(DisConnect) keyEquivalent:@""];
    [MainMenu addItem:DisConnect];
    
    
    NSMenuItem *Quit = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(Quit) keyEquivalent:@""];
    [MainMenu addItem:Quit];
    
    
    [self.StatusItem setImage:[NSImage imageNamed:@"VPND"]];
    [self.StatusItem setMenu:MainMenu];
}


-(void)Quit
{
    [self DisConnect];
    [NSApp terminate:self];
}

-(void)Connect
{
    [MyPPTP Connect];
}


-(void)DisConnect
{
    [MyPPTP DisConnect];
}


- (BOOL)blessHelperWithLabel:(NSString *)label
                       error:(NSError **)error {
    
    BOOL result = NO;
    
    AuthorizationItem authItem        = { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
    AuthorizationRights authRights    = { 1, &authItem };
    AuthorizationFlags flags        =    kAuthorizationFlagDefaults                |
    kAuthorizationFlagInteractionAllowed    |
    kAuthorizationFlagPreAuthorize            |
    kAuthorizationFlagExtendRights;
    
    AuthorizationRef authRef = NULL;
    
    /* Obtain the right to install privileged helper tools (kSMRightBlessPrivilegedHelper). */
    OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &authRef);
    if (status != errAuthorizationSuccess) {
        //        [self appendLog:[NSString stringWithFormat:@"Failed to create AuthorizationRef. Error code: %ld", status]];
        
    } else {
        /* This does all the work of verifying the helper tool against the application
         * and vice-versa. Once verification has passed, the embedded launchd.plist
         * is extracted and placed in /Library/LaunchDaemons and then loaded. The
         * executable is placed in /Library/PrivilegedHelperTools.
         */
        CFErrorRef cferror = NULL ;
        result = SMJobBless(kSMDomainSystemLaunchd, (CFStringRef)@"com.apple.bsd.SMJobBlessHelper", authRef, &cferror);
        *error = CFBridgingRelease(cferror);
    }
    
    return result;
}
@end
