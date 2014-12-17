//
//  UserInformation.m
//  MultipleLogin
//
//  Created by derrick on 12/12/14.
//  Copyright (c) 2014 derrick. All rights reserved.
//

#import "UserInformation.h"

@implementation UserInformation
-(id)initUser:(NSString*)user password:(NSString *)userPassword {
    self = [super init];
    
    if (self) {
        username = user;
        password = userPassword;
    }
    
    return self;
}
-(NSString *) getUsername {
    return username;
}
-(NSString *) getPassword {
    return password;
}

@end
