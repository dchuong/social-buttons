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

// main loop
//TODO: timing variable
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    allUser = [[NSMutableDictionary alloc] init];

    [self openFile:@"userInfo.txt"];
    //[self printDictionary];
    
    // enumerate each users to login and logout
    
    for(NSString * key in allUser) {
        currentServer = key;
        NSMutableArray * theUsers = allUser[key];
        // go through the array of user for that server
        for (int i = 0; i < [theUsers count]; i++) {
            NSString * tempUsername = [theUsers[i] getUsername];
            NSString * tempPassword = [theUsers[i] getPassword];
            
            [self loginToServer:tempUsername pw:tempPassword];
            // start the timer
            /*
            NSDate * startDate = [NSDate date];
            if ([self sendTimerToServer]) {
                NSDate * finishDate = [NSDate date];
                NSTimeInterval executionTime = [finishDate timeIntervalSinceDate:startDate];
                NSLog(@"Execution Time: %f", executionTime);
            }
             */
            [self logoutOfServer:tempUsername];
            sleep(10);
             
        }
    }
    NSLog(@"Program is Done");
    NSLog(@"REPORTS");
    NSLog(@"Number of Login Errors: %lu", (unsigned long)[loginErrorList count]);
    NSLog(@"Number of Logout Errors: %lu", (unsigned long)[logoutErrorList count]);

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void) openFile:(NSString *)filename{
    // get the desktop path
    NSArray * paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
    NSString * desktopPath = [paths objectAtIndex:0];
    // open up the file
    NSString * filePath = [NSString stringWithFormat:@"%@/%@", desktopPath, filename];
    NSString * text = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:NULL];
    
    // seperate by new lines
    NSArray * textByLines = [text componentsSeparatedByString:@"\n"];
    if ([textByLines count] == 0) {
        NSLog(@"User information text file is empty");
        return;
    }
    //init the hashmap
    NSString * checkNewServer = nil;
    NSMutableArray * oneServerArray = [[NSMutableArray alloc] init];
    
    //add an array of user information into the key of the hashmap
    for (NSString * line in textByLines) {
        NSArray * components = [line componentsSeparatedByString:@"/"];
        UserInformation * user = [[UserInformation alloc] initUser:components[1] password:components[2]];
        
        // if it is the current server keep appending
        if ([checkNewServer isEqualToString:components[0]]) {
            [oneServerArray addObject:user];
        }
        else {
        // if it is a new server create a new array
            oneServerArray = [[NSMutableArray alloc] init];
            [oneServerArray addObject:user];
        }
        
        checkNewServer = components[0];
        [allUser setValue:oneServerArray forKey:components[0]];
    }
}


//login using applescript for unix ARD
-(NSString *) loginScript:(NSString *)user pw:(NSString *)password; {
    NSString * loginSource = [NSString stringWithFormat:
    @"tell application \"Remote Desktop\"\n"
    "set theComputers to the selection\n"
    "repeat with x in theComputers\n"
    "set thescript to \"osascript -e 'tell application \\\"System Events\\\"' -e 'keystroke \\\"%@\\\"' -e 'keystroke tab' -e 'delay 0.5' -e 'keystroke \\\"%@\\\"' -e 'delay 0.5' -e 'keystroke return' -e 'end tell'\"\n"
    "set thetask to make new send unix command task with properties {name:\"Multiple Login\", script:thescript, showing output:false, user:\"root\"}\n"
    "execute thetask on x\n"
    "end repeat\n"
    "end tell",user, password];
    
    return loginSource;
}

// send the command to the ard
//TODO: merge to one function to send commands
-(void) loginToServer:(NSString *)user pw:(NSString *)password {
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    NSLog(@"%@ %@",user, password);
    NSString * loginString = [self loginScript:user pw:password];
    
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
        //TODO: push into completed login array
        // successful execution
        NSLog(@"login - done");
        return;
    }
    else {
        //there is an error! - append to the array
        //TODO: push to errorList
        NSLog(@"login - error");
        [loginErrorList addObject:[NSString stringWithFormat:@"%@ didn't logout at %@", user, currentServer]];
        
    }
}

- (NSString *) timerScript {
    NSString * timerSource = [NSString stringWithFormat:
                               @"tell application \"Remote Desktop\"\n"
                               "set theComputers to the selection\n"
                               "repeat with x in theComputers\n"
                               "set thescript to \"osascript -e 'global processExists' -e 'set processExists to false' -e 'repeat while processExists = false' -e 'tell application \\\"System Events\\\"' -e 'set processExists to exists process \\\"Finder\\\"' -e 'end tell' -e 'end repeat' -e 'return processExists'\"\n"
                               "set thetask to make new send unix command task with properties {name:\"Timer\", script:thescript, showing output:false, user:\"root\"}\n"
                               "execute thetask on x\n"
                               "end repeat\n"
                               "end tell\n"
                               "return true"];
    
    return timerSource;
}

- (BOOL)sendTimerToServer {
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    NSString * timerString = [self timerScript];
    NSAppleScript * timer = [[NSAppleScript alloc] initWithSource: timerString];
    returnDescriptor = [timer executeAndReturnError: &errorDict];
    if (returnDescriptor != NULL)
    {
        // successful execution
        if([[returnDescriptor stringValue] isEqualToString:@"true"]) {
            NSLog(@"mytimer work");
            return true;
        }
    }
    else {
        //there is an error!
        NSLog(@"mytimer suk");
    }
    return false;
}

- (NSString *)logoutScript:(NSString *)user{
    NSString * logoutSource = [NSString stringWithFormat:
    @"tell application \"Remote Desktop\"\n"
    "set theComputers to the selection\n"
    "repeat with x in theComputers\n"
    "set thescript to \"osascript -e 'tell application \\\"System Events\\\"' -e 'keystroke \\\"q\\\" using {command down, shift down, option down}' -e 'end tell'\"\n"
    "set thetask to make new send unix command task with properties {name:\"Multiple Login\", script:thescript, showing output:false, user:\"%@\"}\n"
    "execute thetask on x\n"
    "end repeat\n"
    "end tell", user];
    
    return logoutSource;
}

// logout of the user in a server
- (void)logoutOfServer:(NSString *)user {
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    NSString * logoutString = [self logoutScript:user];
    NSAppleScript * logout = [[NSAppleScript alloc] initWithSource: logoutString];
    returnDescriptor = [logout executeAndReturnError: &errorDict];
    if (returnDescriptor != NULL)
    {
        // successful execution
        NSLog(@"logout - done");
        //TODO: push into completed login array
        return;
    }
    else {
        //there is an error!
        NSLog(@"logout - error");
        [logoutErrorList addObject:[NSString stringWithFormat:@"%@ didn't logout at %@", user, currentServer]];
        
    }
    
}

// dictionary holds the server + user information
- (void) printDictionary {
    NSLog(@"checking work");
    for(NSString * key in allUser) {
        NSLog(@"key=%@", key);
        NSMutableArray * temp = allUser[key];
        for (int i = 0; i < [temp count]; i++){
            UserInformation * tempUser = temp[i];
            NSLog(@"%@ %@", [tempUser getUsername], [tempUser getPassword]);
        }
    }
}
@end
