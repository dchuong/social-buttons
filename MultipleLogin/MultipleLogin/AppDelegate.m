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
//TODO: need to functionalize sending the commands to ARD into one function
//TODO: timer
//TODO: clean derrickcomplist even if it crash or stop
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    allUser = [[NSMutableDictionary alloc] init];
    loginErrorList = [[NSMutableArray alloc] init];
    logoutErrorList = [[NSMutableArray alloc] init];
    resultLoginDict = [[NSMutableDictionary alloc] init];
    
    myComputerList = @"DerrickCompList";
    [self openFile:@"userInfo.txt"];
    //[self printDictionary];
    
    // enumerate each users to login and logout
    // allUser is a dictionary ( hashmap in C++ )
   
    NSLog(@"Starting Program");

    [_statusLabel setStringValue:@"Program is running..."];
    for(NSString * key in allUser) {
        currentServer = key;
                // make a new server list with a single computer
        [self newComputerList:currentServer];
        
        NSMutableArray * theUsers = allUser[key];
        // go through the array of user for that server
        for (int i = 0; i < [theUsers count]; i++) {
            NSString * tempUsername = [theUsers[i] getUsername];
            [_statusLabel setStringValue:[NSString stringWithFormat:@"It is currently on server: %@ %@", key, tempUsername]];
            NSString * tempPassword = [theUsers[i] getPassword];
            
            [self loginToServer:tempUsername pw:tempPassword];
            sleep(130);
            [self logoutOfServer:tempUsername];
            sleep(10);
        }
        [self removeComputer:currentServer];
    }
    
    [self writeResultFile];
    [_statusLabel setStringValue:[NSString stringWithFormat:@"Program is Done"]];

    NSLog(@"Program is Done");
    NSLog(@"ERRORS REPORT");
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
    NSMutableArray * oneServerArray = [[NSMutableArray alloc] init];
    
    //add an array of user information into the key of the hashmap
    //TODO: need to fix dictionary - check if there is an array already in the dictionary
    for (NSString * line in textByLines) {
        NSArray * components = [line componentsSeparatedByString:@"/"];
        UserInformation * user = [[UserInformation alloc] initUser:components[1] password:components[2]];
        
        // if key exists keep expanding
        if ([allUser objectForKey:components[0]]) {
            [allUser[components[0]] addObject:user];
        }
        else {
        // if key doesn't exists create a new array for that key
            oneServerArray = [[NSMutableArray alloc] init];
            NSMutableArray * resultArray = [[NSMutableArray alloc] init];
            [resultLoginDict setValue:resultArray forKey:components[0]];
            [oneServerArray addObject:user];
            [allUser setValue:oneServerArray forKey:components[0]];
        }
        
    }
}

//write the result to a text file
- (void)writeResultFile {
    NSArray * paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
    NSString * desktopPath = [paths objectAtIndex:0];
    NSDate * currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
    NSString * outFilePath = [NSString stringWithFormat:@"%@/result (%ld-%ld-%ld).txt", desktopPath, (long)[components month], (long)[components day], (long)[components year]];
    NSString * outputString = @"";
   
    // go through the success
    for(NSString * key in resultLoginDict) {
        outputString = [NSString stringWithFormat:@"%@%@:\n",outputString,key];
        NSMutableArray * temp = allUser[key];
        for (int i = 0; i < [temp count]; i++){
            UserInformation * tempUser = temp[i];
            outputString = [NSString stringWithFormat:@"%@%@\n", outputString, [tempUser getUsername]];
        }
        [outputString stringByAppendingString:@"\n\n"];
    }
    
    // error report
    [outputString stringByAppendingString:@"ERRORS REPORT\n"];
    outputString = [NSString stringWithFormat:@"%@Number of Login Errors: %lu\n", outputString,(unsigned long)[loginErrorList count]];
    outputString = [NSString stringWithFormat:@"%@Number of Logout Errors: %lu\n\n", outputString,(unsigned long)[logoutErrorList count]];
    
     // go through the errors
    for(int i = 0; i < [loginErrorList count]; i++){
        outputString = [NSString stringWithFormat:@"%@%@\n", outputString, loginErrorList[i]];
    }
    for(int i = 0; i < [logoutErrorList count]; i++){
        outputString = [NSString stringWithFormat:@"%@%@\n", outputString, logoutErrorList[i]];
    }
    [outputString writeToFile:outFilePath atomically:YES encoding:NSUnicodeStringEncoding error:nil];

}


//create individual server list with that computer in ARD
// The list with all the computers have to be named All Computers
-(NSString *) newComputerScript:(NSString *)selectedServer {
    NSString * createComputer = [NSString stringWithFormat:
    @"tell application \"Remote Desktop\"\n"
    "set computerList to (every computer of computer list \"All Computers\")\n"
    "repeat with comp in computerList\n"
    "set serverName to name of comp\n"
    
    "set derrickCompList to \"%@\"\n" //first %@
                                 "if ((serverName as string) is equal to \"%@\") then\n" // 2nd %@
                                 "if (not (exists computer list derrickCompList)) then\n"
                                "make new computer list with properties {name:derrickCompList}\n"
                                 
                                 "end if\n"
                                 
    "add comp to computer list derrickCompList\n" //
    "end if\n"
    "end repeat\n"
    "end tell", myComputerList, selectedServer];
    return createComputer;
    
}

-(void)newComputerList:(NSString *)selectedServer {
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    NSString * createServerString = [self newComputerScript:selectedServer];
    
    NSAppleScript * createServer = [[NSAppleScript alloc] initWithSource: createServerString];
    
    //execute and the return descriptor returns a string or a null
    returnDescriptor = [createServer executeAndReturnError: &errorDict];
    if (returnDescriptor != NULL)
    {
        //TODO: push into completed login array
        // successful execution
        //NSLog(@"new server list - done");
        
        return;
    }
    else {
        //there is an error! - append to the array
        //TODO: push to errorList
        NSLog(@"new server list - error");
    }
}

//remove a computer from a computer list in ARD
- (NSString *) removeComputerScript:(NSString *)selectedServer {
    NSString * removeSource = [NSString stringWithFormat:
                               @"tell application \"Remote Desktop\"\n"
                               "remove computer \"%@\" from computer list \"%@\"\n"
                               "end tell", selectedServer, myComputerList];
    return removeSource;
}

-(void) removeComputer:(NSString *)selectedServer {
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    NSString * removeString = [self removeComputerScript:selectedServer];
    
    NSString * path = @"/Users/derrick/Desktop/MultipleLogin/removeScript.scpt";
    [removeString writeToFile:path atomically:YES encoding:NSUnicodeStringEncoding error:nil];
    //create the login applescript for it to execute
    NSAppleScript * remove = [[NSAppleScript alloc] initWithSource: removeString];
    
    //execute and the return descriptor returns a string or a null
    returnDescriptor = [remove executeAndReturnError: &errorDict];
    if (returnDescriptor != NULL)
    {
        NSLog(@"remove - done");
        return;
    }
    else {
        NSLog(@"remove - error");
        
    }
}


//login using applescript for unix ARD
-(NSString *) loginScript:(NSString *)user pw:(NSString *)password; {
    NSString * loginSource = [NSString stringWithFormat:
    @"tell application \"Remote Desktop\"\n"
    "set theComputers to first computer of computer list \"%@\"\n" // first %@
    "repeat with x in theComputers\n"
    "set thescript to \"osascript -e 'tell application \\\"System Events\\\"' -e 'keystroke \\\"%@\\\"' -e 'keystroke tab' -e 'delay 0.5' -e 'keystroke \\\"%@\\\"' -e 'delay 0.5' -e 'keystroke return' -e 'end tell'\"\n" // 2nd , 3rd %@
    "set thetask to make new send unix command task with properties {name:\"Login\", script:thescript, showing output:false, user:\"root\"}\n"
    "execute thetask on x\n"
    "end repeat\n"
    "end tell", myComputerList ,user, password];
    return loginSource;
}

// send the command to the ard
-(void) loginToServer:(NSString *)user pw:(NSString *)password {
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    NSLog(@"%@ %@ %@",user, password, currentServer);
    NSString * loginString = [self loginScript:user pw:password];
    
    /* for debugging
    NSString * path = @"/Users/derrick/Desktop/MultipleLogin/LoginScript.scpt";
    [loginString writeToFile:path atomically:YES encoding:NSUnicodeStringEncoding error:nil];
     */
    
    //create the login applescript for it to execute
    NSAppleScript * login = [[NSAppleScript alloc] initWithSource: loginString];
    
    //execute and the return descriptor returns a string or a null
    returnDescriptor = [login executeAndReturnError: &errorDict];
    if (returnDescriptor != NULL)
    {
        
        // successful execution
        NSLog(@"login - done");
        UserInformation * userInfo = [[UserInformation alloc] initUser:user password:password];
        [resultLoginDict[currentServer] addObject:userInfo];
        return;
    }
    else {
        //there is an error! - append to the array
        //TODO: push to errorList
        NSLog(@"login - error");
        [loginErrorList addObject:[NSString stringWithFormat:@"%@ didn't logout at %@", user, currentServer]];
        
    }
}


//TODO: Still need to be fix
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

// logout using a command shell
- (NSString *)logoutScript:(NSString *)user{
    NSString * logoutSource = [NSString stringWithFormat:
    @"tell application \"Remote Desktop\"\n"
    "set theComputers to first computer of computer list \"%@\"\n" // first %@
    "repeat with x in theComputers\n"
    "set thescript to \"osascript -e 'tell application \\\"loginwindow\\\" to  «event aevtrlgo»'\"\n"
    "set thetask to make new send unix command task with properties {name:\"Logout\", script:thescript, showing output:false, user:\"%@\"}\n" // 2nd %@
    "execute thetask on x\n"
    "end repeat\n"
    "end tell", myComputerList,user];
    
    return logoutSource;
}

// Log out without showing a confirmation dialog
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
