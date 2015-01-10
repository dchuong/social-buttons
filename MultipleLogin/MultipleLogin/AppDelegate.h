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
#import "ScriptToRemoteDesktop.h"

typedef NS_ENUM(NSInteger, MyScript) {
    TIMER,
    CHECKLOGIN,
    AUTOLOGIN,
    AUTOLOGOUT
};

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSString * currentServer;
    NSString * myComputerList;
    NSMutableArray * loginErrorList;
    NSMutableArray * logoutErrorList;
    NSMutableDictionary * resultLoginDict;
    NSMutableArray * logoutDone;
    NSMutableDictionary * allUser;
    NSMutableArray * checkServerList;
    enum MyScript sendWhichScript;
    
}
-(void) openFile:(NSString *)filename;
-(void) writeResultFile;

-(NSString *) newComputerScript:(NSString *)selectedServer;
-(void) newComputerList:(NSString *)selectedServer;
-(NSString *) removeComputerScript:(NSString *)selectedServer;
-(void)removeComputer:(NSString *)selectedServer;
-(void)checkAllServers:(int)time;

-(void) loginToServer:(NSString *)user pw:(NSString *)password;
-(BOOL) sendTimerToServer:(int)time script:(enum MyScript)kind;
-(void) logoutOfServer:(NSString *)user;


-(NSString *) loginScript:(NSString *)user pw:(NSString *)password;
-(NSString *) timerScript:(int)time;
-(NSString *) logoutScript:(NSString *)user;
-(NSString *) checkUserLogin;

-(void) printDictionary;


@property (weak) IBOutlet NSTextField *statusLabel;


@end

