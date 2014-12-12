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
    NSMutableArray * errorList;
    NSMutableDictionary * allUser;
}
-(void) openFile:(NSString *)filename;
-(void) loginToServer;
-(void) logoutOfServer;
-(void) printDictionary;
-(NSString *) loginScript;
-(NSString *) logoutScript;
@end

