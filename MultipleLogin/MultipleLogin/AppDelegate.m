//
//  AppDelegate.m
//  MultipleLogin
//
//  Created by derrick on 12/10/14.
//  Copyright (c) 2014 derrick. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

// main loop for it to be done
//TODO: parse data
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [self loginToServer];
    sleep(10);
    [self logoutOfServer];
    NSLog(@"Program is Done");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
//login applescript for unix ARD
//TODO: Parameter passing for user and password
- (NSString *)loginScript {
    NSString * loginSource =
    @"tell application \"Remote Desktop\"\n"
    "set theComputers to the selection\n"
    "repeat with x in theComputers\n"
    "set thescript to \"osascript -e 'tell application \\\"System Events\\\"' -e 'keystroke \\\"user123\\\"' -e 'keystroke tab' -e 'delay 0.5' -e 'keystroke \\\"demo@123\\\"' -e 'delay 0.5' -e 'keystroke return' -e 'end tell'\"\n"
    "set thetask to make new send unix command task with properties {name:\"Multiple Login\", script:thescript, showing output:false, user:\"root\"}\n"
    "execute thetask on x\n"
    "end repeat\n"
    "end tell";
    
    return loginSource;
}

- (void) loginToServer {
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    NSString * loginString = [self loginScript];
    
    /*
    NSString * path = @"/Users/derrick/Desktop/MultipleLogin/LoginScript.scpt";
    [loginString writeToFile:path atomically:YES encoding:NSUnicodeStringEncoding error:nil];
    NSAppleScript * loginScript = [[NSAppleScript alloc]
                                   initWithContentsOfURL:[NSURL fileURLWithPath:path]
                                   error:nil];
     */
    //create the login applescript for it to execute
    NSAppleScript * login = [[NSAppleScript alloc] initWithSource: loginString];
    
    //execute and the return descriptor returns a string or a null
    returnDescriptor = [login executeAndReturnError: &errorDict];
    if (returnDescriptor != NULL)
    {
        // successful execution
        NSLog(@"login - done");
        NSLog(@"%@", [returnDescriptor stringValue]);
        return;
    }
    else {
        //there is an error!
        //TODO: push to errorList
        NSLog(@"login - error");
    }
}

- (NSString *)logoutScript {
    NSString * logoutSource =
    @"tell application \"Remote Desktop\"\n"
    "set theComputers to the selection\n"
    "repeat with x in theComputers\n"
    "set thescript to \"osascript -e 'tell application \\\"System Events\\\"' -e 'keystroke \\\"q\\\" using {command down, shift down, option down}' -e 'end tell'\"\n"
    "set thetask to make new send unix command task with properties {name:\"Multiple Login\", script:thescript, showing output:false, user:\"root\"}\n"
    "execute thetask on x\n"
    "end repeat\n"
    "end tell";
    
    return logoutSource;
}

//TODO: parameter passing user
- (void)logoutOfServer {
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    NSString * logoutString = [self logoutScript];
    NSAppleScript * logout = [[NSAppleScript alloc] initWithSource: logoutString];
    returnDescriptor = [logout executeAndReturnError: &errorDict];
    if (returnDescriptor != NULL)
    {
        // successful execution
        NSLog(@"logout - done");
        NSLog(@"%@", [returnDescriptor stringValue]);
        return;
    }
    else {
        //there is an error!
        NSLog(@"logout - error");
        //TODO: push to errorList
    }
    
}

@end
