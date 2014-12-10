//
//  AppDelegate.h
//  MultipleLogin
//
//  Created by derrick on 12/10/14.
//  Copyright (c) 2014 derrick. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <AppleScriptObjC/AppleScriptObjC.h>
@interface AppDelegate : NSObject <NSApplicationDelegate>

-(void) loginToServer;
-(void) logoutOfServer;
-(NSString *) loginScript;
-(NSString *) logoutScript;
@end

