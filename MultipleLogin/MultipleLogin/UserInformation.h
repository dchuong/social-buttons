//
//  UserInformation.h
//  MultipleLogin
//
//  Created by derrick on 12/12/14.
//  Copyright (c) 2014 derrick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInformation : NSObject {
    NSString * username;
    NSString * password;
}

-(id)initUser:(NSString*)user password:(NSString *)userPassword;
-(NSString *) getUsername;
-(NSString *) getPassword;

@end
