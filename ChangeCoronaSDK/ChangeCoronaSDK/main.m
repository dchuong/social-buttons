/*
 osascript <<EndOfMyScript
 do shell script "/applications/server/ChangeCorona.app/Contents/MacOS/ChangeCorona" user name “insert" password “insert" with administrator privileges
 EndOfMyScript

 */
//
//  main.m
//  ChangeCoronaSDK
//
//  Created by derrick on 10/24/14.
//  Copyright (c) 2014 derrick. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSString *basePath = @"/Applications/CoronaSDK/Corona Simulator.app/Contents/Info.plist";
        
        NSDictionary * Dictionary = [[NSDictionary alloc] initWithContentsOfFile:basePath];
        NSString * getVersion = [Dictionary valueForKey:@"CFBundleShortVersionString"];
        
        // add ( ) around version
        
        NSLog(@"%@", getVersion);
        if (getVersion == nil || getVersion == (id)[NSNull null] ) {
            
            NSLog(@"The Version is null - Can't find the path");
        }
        else {
            getVersion = [NSString stringWithFormat: @" (%@)", getVersion];
            NSString *oldName = @"/Applications/CoronaSDK";
            NSString *newName = [oldName stringByAppendingString:getVersion];
            
            NSLog(@"%@", newName);
            
            NSError *error = nil;
            BOOL success =[[NSFileManager defaultManager] moveItemAtPath:oldName toPath:newName error:&error];
            NSLog(@"%@", success ? @"YES" : @"NO");
        }
    }
    return 0;
}
