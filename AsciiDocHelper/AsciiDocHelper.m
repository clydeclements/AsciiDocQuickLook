//
//  AsciiDocHelper.m
//  AsciiDocHelper
//
//  Created by Clyde Clements on 2019-09-07.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

#import "AsciiDocHelper.h"

@implementation AsciiDocHelper

// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
- (void)upperCaseString:(NSString *)aString withReply:(void (^)(NSString *))reply {
    //NSString *response = [aString uppercaseString];
    NSLog(@"upperCaseString method called");
    NSString *response = @"AsciiDoc Quick Look";
    reply(response);
}

@end
