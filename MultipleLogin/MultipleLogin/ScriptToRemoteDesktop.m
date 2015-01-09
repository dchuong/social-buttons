//
//  ScriptToRemoteDesktop.m
//  MultipleLogin
//
//  Created by derrick on 1/6/15.
//  Copyright (c) 2015 derrick. All rights reserved.
//

#import "ScriptToRemoteDesktop.h"

@implementation ScriptToRemoteDesktop

// stop the 
+ (void)stopCurrentTaskScript {
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    
    NSString * stopTask = [NSString stringWithFormat:
                           @"tell application \"Remote Desktop\" to activate\n"
                           "tell application \"System Events\"\n"
                           "keystroke \".\" using {command down, option down}\n"
                           "end tell"
                           ];
    
    NSString * path = @"/Users/derrick/Desktop/MultipleLogin/stopTask.scpt";
    [stopTask writeToFile:path atomically:YES encoding:NSUnicodeStringEncoding error:nil];
    
    NSAppleScript * stopCurrentTask = [[NSAppleScript alloc] initWithSource: stopTask];
    returnDescriptor = [stopCurrentTask executeAndReturnError: &errorDict];
    if (returnDescriptor != NULL)
    {
      NSLog(@"stopCurrentTaskScript - done");
      return;
    }
    else {
      NSLog(@"stopCurrentTaskScript - error");
    }
}
@end
