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
#import "UserInformation.h"
@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSString * currentServer;
    NSMutableArray * loginErrorList;
    NSMutableArray * logoutErrorList;
    NSMutableArray * loginDone;
    NSMutableArray * logoutDone;
    NSMutableDictionary * allUser;
}
-(void) openFile:(NSString *)filename;
-(void) loginToServer:(NSString *)user pw:(NSString *)password;
-(void) logoutOfServer:(NSString *)user;
-(void) printDictionary;
-(NSString *) loginScript:(NSString *)user pw:(NSString *)password;
-(NSString *) logoutScript:(NSString *)user;
@end

