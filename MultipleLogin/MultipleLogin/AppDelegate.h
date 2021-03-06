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
    AUTOLOGOUT,
    REMOVECOMPUTERLIST,
    ADDCOMPUTERLIST,
    KILL_LOGINWINDOW
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

//preparing the program
-(void) openFile:(NSString *)filename;

//exiting the program
-(void) writeResultFile;
-(void)checkAllServers:(int)time;

// the Scripts for unix command or ask the ARD to do something
-(NSString *) loginScript:(NSString *)user pw:(NSString *)password;
-(NSString *) logoutScript:(NSString *)user;
-(NSString *) timerScript:(int)time;
-(NSString *) checkUserLogin;
-(NSString *) newComputerScript:(NSString *)selectedServer;
-(NSString *) removeComputerScript:(NSString *)selectedServer;
-(NSString *) kill_all_login_window;

// Create the script and send it to the ARD
-(BOOL) sendUserToServer:(NSString *)user pw:(NSString *)password timer:(int)time server:(NSString *) selectedServer script:(enum MyScript)kind;

//MISC - debugging
-(void) printDictionary;
@property (weak) IBOutlet NSTextField *statusLabel;


@end

