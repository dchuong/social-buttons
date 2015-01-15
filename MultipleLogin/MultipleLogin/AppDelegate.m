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
//TODO: line cartiage in reading the text file
//TODO: need to functionalize sending the commands to ARD into one function
//TODO: clean derrickcomplist even if it crash or stop
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    BOOL writeUserTime = NO;
    allUser = [[NSMutableDictionary alloc] init];
    loginErrorList = [[NSMutableArray alloc] init];
    logoutErrorList = [[NSMutableArray alloc] init];
    resultLoginDict = [[NSMutableDictionary alloc] init];
    checkServerList = [[NSMutableArray alloc] init];
    
    myComputerList = @"DerrickCompList";
    [self openFile:@"usertest.txt"]; // The text file needs to be in the desktop and the name goes here.
    
    // enumerate each users to login and logout
    // allUser is a dictionary ( hashmap in C++ )
    NSLog(@"Starting Program");
    [_statusLabel setStringValue:@"Program is running..."];
    for(NSString * key in allUser) {
        currentServer = key;
        
        // make a new server list with a single computer
        [self sendUserToServer:@"" pw:@"" timer:0 server:currentServer script:sendWhichScript = ADDCOMPUTERLIST];
        [checkServerList addObject:[NSString stringWithFormat:@"%@", currentServer]];
        NSMutableArray * theUsers = allUser[key];
        
        // go through the array of user for that server
        for (int i = 0; i < [theUsers count]; i++) {
            writeUserTime = NO;
            NSString * tempUsername = [theUsers[i] getUsername];
            NSString * tempPassword = [theUsers[i] getPassword];
    
            // login
            [self sendUserToServer:tempUsername pw:tempPassword timer:0 server:currentServer script:sendWhichScript = AUTOLOGIN];
            // start time
            NSDate * startDate = [NSDate date];
            UserInformation * userInfo = [[UserInformation alloc] initUser:tempUsername password:@""];
            [_statusLabel setStringValue:[NSString stringWithFormat:@"It is currently on server: %@ %@", key, tempUsername]];
            sleep(5);
            
            if ([self sendUserToServer:@"" pw:@"" timer:90 server:currentServer script:sendWhichScript = TIMER]) {
                NSDate * finishDate = [NSDate date];
                NSTimeInterval executionTime = [finishDate timeIntervalSinceDate:startDate];
                NSLog(@"Execution Time: %f", executionTime);
            
                //if the login takes too long - stop it and keep going
                if(executionTime > 95) {
                    [userInfo setTime:[NSString stringWithFormat:@"Took too long to login (over %f)", executionTime]];
                }
                else {
                    [userInfo setTime:[NSString stringWithFormat:@"%f", executionTime]];
                }
                writeUserTime = YES;
                [resultLoginDict[currentServer] addObject:userInfo];
            // For some servers the timer has stop but the ARD active tasks keep continuing (infinite loop from ARD)
            
            }
  
            sleep(10);
            // remove the active script for timer
            [ScriptToRemoteDesktop stopCurrentTaskScript];
            [self sendUserToServer:tempUsername pw:@"" timer:0 server:currentServer script:sendWhichScript = AUTOLOGOUT];
            sleep(2);
            // remove the active script for logout
            [ScriptToRemoteDesktop stopCurrentTaskScript];
            sleep(3);
            NSLog(@"\n");
        }
        [self sendUserToServer:@"" pw:@"" timer:0 server:currentServer script:sendWhichScript = REMOVECOMPUTERLIST];
      
        sleep(2);
    }
    //check if all users are logout in server
    [self writeResultFile];
    [_statusLabel setStringValue:[NSString stringWithFormat:@"Program is Done"]];
    NSLog(@"Program is Done");
    NSLog(@"ERRORS REPORT");
    NSLog(@"Number of Login Errors: %lu", (unsigned long)[loginErrorList count]);
    NSLog(@"Number of Logout Errors: %lu", (unsigned long)[logoutErrorList count]);
   
    NSLog(@"checking servers");
    [self checkAllServers:3];

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
    NSString * text = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
 
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
        if ([line length] == 0) {
            continue;
        }
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

//go through the unique server in the textfile and check if any user is still login
- (void)checkAllServers:(int)time  {
    sleep(3);
    for (NSString * oneServer in checkServerList) {
    [self sendUserToServer:@"" pw:@"" timer:0 server:oneServer script:sendWhichScript = ADDCOMPUTERLIST ];
        if ([self sendUserToServer:@"" pw:@"" timer:time server:oneServer script:sendWhichScript = CHECKLOGIN]) {
            [self sendUserToServer:@"root" pw:@"" timer:0 server:oneServer script:sendWhichScript = AUTOLOGOUT];
            [ScriptToRemoteDesktop stopCurrentTaskScript];
        };
        [ScriptToRemoteDesktop stopCurrentTaskScript];
        [self sendUserToServer:@"" pw:@"" timer:0 server:oneServer script:sendWhichScript = REMOVECOMPUTERLIST];

    }
}

//write the result to a text file
- (void)writeResultFile {
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
    NSString * desktopPath = [paths objectAtIndex:0];
    NSDate * currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
    NSString * outFilePath;
    int i = 1;
    while (true) {
        outFilePath = [NSString stringWithFormat:@"%@/result (%ld-%ld-%ld)%i.txt", desktopPath, (long)[components month], (long)[components day], (long)[components year], i];
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        BOOL fileExists = [fileMgr fileExistsAtPath:outFilePath];
        if (fileExists == NO) {
            break;
        }
        i++;
    }
 

    NSString * outputString = @"";
   
    // go through the success
    for(NSString * key in resultLoginDict) {
        outputString = [NSString stringWithFormat:@"%@%@:\n",outputString,key];
        NSMutableArray * temp = resultLoginDict[key];
        for (int i = 0; i < [temp count]; i++){
            UserInformation * tempUser = temp[i];
            outputString = [NSString stringWithFormat:@"%@%@ %@\n", outputString, [tempUser getUsername], [tempUser getTimer]];
        }
        outputString = [NSString  stringWithFormat:@"%@\n",outputString];
    }
    
    // error report
    outputString = [NSString stringWithFormat:@"%@ERRORS REPORT\n",outputString];
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

//remove a computer from a computer list in ARD
- (NSString *) removeComputerScript:(NSString *)selectedServer {
    NSString * removeSource = [NSString stringWithFormat:
                               @"tell application \"Remote Desktop\"\n"
                               "remove computer \"%@\" from computer list \"%@\"\n"
                               "end tell", selectedServer, myComputerList];
    return removeSource;
}

//login using applescript for unix ARD
-(NSString *) loginScript:(NSString *)user pw:(NSString *)password; {
    NSString * loginSource = [NSString stringWithFormat:
    @"tell application \"Remote Desktop\" to activate \n"
    "tell application \"Remote Desktop\"\n"
    "set theComputers to first computer of computer list \"%@\"\n" // first %@
    "repeat with x in theComputers\n"
    "set thescript to \"osascript -e 'tell application \\\"System Events\\\"' -e 'keystroke \\\"%@\\\"' -e 'keystroke tab' -e 'delay 0.5' -e 'keystroke \\\"%@\\\"' -e 'delay 0.5' -e 'keystroke return' -e 'end tell'\"\n" // 2nd , 3rd %@
    "set thetask to make new send unix command task with properties {name:\"Login\", script:thescript, showing output:false, user:\"root\"}\n"
    "execute thetask on x\n"
    "end repeat\n"
    "end tell", myComputerList ,user, password];
    return loginSource;
}

//TODO: Need to end when certain amount of time as gone pass
- (NSString *) timerScript:(int)time {
    
    NSString * timerSource = [NSString stringWithFormat:
                               @"tell application \"Remote Desktop\"\n"
                              "set theComputers to first computer of computer list \"%@\"\n" // first %@
                              "repeat with x in theComputers\n"
                              "set thescript to \"osascript <<EndOfMyScript \nset startTime to (get current date)\nset loggedInUser to do shell script \\\"/bin/ls -l /dev/console | /usr/bin/awk \\\\\\\"{print $3 }\\\\\\\"\\\" \n set check_user to words 3 of loggedInUser \nglobal findUser\n set findUser to true \n repeat while findUser = true \n set loggedInUser to do shell script \\\"/bin/ls -l /dev/console | /usr/bin/awk \\\\\\\"{print $3 }\\\\\\\"\\\"\n set check_user to words 3 of loggedInUser\n if (check_user is not equal to \\\"root\\\") then \n set findUser to false \n end if \n set endTime to (get current date) \n set duration to endTime - startTime \n if (duration > %i) then error number -128 \n end repeat \nEndOfMyScript\"\n"
                               "set thetask to make new send unix command task with properties {name:\"Timer\", script:thescript, showing output:false, user:\"root\"}\n"
                               "execute thetask on x\n"
                               "end repeat\n"
                               "end tell\n"
                               "return true", myComputerList, time];
    
    return timerSource;
}

- (NSString *)checkUserLogin {
    NSString * checkUser = [NSString stringWithFormat:
                              @"tell application \"Remote Desktop\"\n"
                              "set theComputers to first computer of computer list \"%@\"\n" // first %@
                              "repeat with x in theComputers\n"
                              "set thescript to \"osascript <<EndOfMyScript \nset loggedInUser to do shell script \\\"/bin/ls -l /dev/console | /usr/bin/awk \\\\\\\"{print $3 }\\\\\\\"\\\" \n set check_user to words 3 of loggedInUser \n if (check_user is equal to \\\"root\\\") then error number -128 \nEndOfMyScript\"\n"
                              "set thetask to make new send unix command task with properties {name:\"CheckUser\", script:thescript, showing output:false, user:\"root\"}\n"
                              "execute thetask on x\n"
                              "end repeat\n"
                              "end tell", myComputerList];
    
    return checkUser;
   
}

// logout using a command shell
- (NSString *)logoutScript:(NSString *)user{
    NSString * logoutSource = [NSString stringWithFormat:
                               @"tell application \"Remote Desktop\"\n"
                               "set theComputers to first computer of computer list \"%@\"\n" // first %@
                               "repeat with x in theComputers\n"
                               "set thescript to \"osascript -e 'tell application \\\"System Events\\\" to keystroke \\\"q\\\" using {command down, option down, shift down}'\"\n"
                               "set thetask to make new send unix command task with properties {name:\"Logout\", script:thescript, showing output:false, user:\"%@\"}\n" // 2nd %@
                               "execute thetask on x\n"
                               "end repeat\n"
                               "end tell", myComputerList,user];
    
    return logoutSource;
}

// this function creates the script and send it to ARD
-(BOOL) sendUserToServer:(NSString *)user pw:(NSString *)password timer:(int)time server:(NSString *) selectedServer script:(enum MyScript)kind {
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    NSString * scriptString;

    /* for debugging
     NSString * path = @"/Users/derrick/Desktop/MultipleLogin/LoginScript.scpt";
     [loginString writeToFile:path atomically:YES encoding:NSUnicodeStringEncoding error:nil];
     */
    
    // Control structure for which script to run it
    switch (kind) {
        case TIMER:
            scriptString = [self timerScript:time];
            break;
        case CHECKLOGIN:
            scriptString = [self checkUserLogin];
            break;
        case AUTOLOGIN:
            NSLog(@"%@ %@ %@",user, password, selectedServer);
            scriptString = [self loginScript:user pw:password];
            break;
        case AUTOLOGOUT:
            scriptString = [self logoutScript:user];
            break;
        case ADDCOMPUTERLIST:
            scriptString = [self newComputerScript:selectedServer];
            break;
        case REMOVECOMPUTERLIST:
            scriptString = [self removeComputerScript:selectedServer];
            break;
        default:
            break;
    }
    
    NSAppleScript * timer = [[NSAppleScript alloc] initWithSource: scriptString];
    returnDescriptor = [timer executeAndReturnError: &errorDict];
    
    //check login need fix
    if (returnDescriptor != NULL)
    {
        switch (kind) {
            case CHECKLOGIN:
                NSLog(@"true:");
                return true;
                break;
            case AUTOLOGIN:
                NSLog(@"login - done");
                break;
            case AUTOLOGOUT:
                NSLog(@"logout - done");
                break;
            default:
                break;
        }
        // successful execution
        return true;
    }
    else {
        //there is an error!
        switch (kind) {
            case CHECKLOGIN:
                NSLog(@"false:");
                return false;
                break;
            case AUTOLOGIN:
                NSLog(@"login - error");
                [loginErrorList addObject:[NSString stringWithFormat:@"%@ didn't login at %@", user, currentServer]];     break;
            case AUTOLOGOUT:
                NSLog(@"logout - error");
                break;
            case ADDCOMPUTERLIST:
                NSLog(@"new server list - error");
                break;
            case REMOVECOMPUTERLIST:
                NSLog(@"remove server list - error");
            default:
                break;
        }
        return false;
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
