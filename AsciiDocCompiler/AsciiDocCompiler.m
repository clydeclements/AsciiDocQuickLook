//
//  AsciiDocCompiler.m
//  AsciiDocCompiler
//
//  Created by Clyde Clements on 2017-10-09.
//  Copyright © 2017 Clyde Clements. All rights reserved.
//

#import "AsciiDocCompiler.h"

@implementation AsciiDocCompiler

// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
- (void)upperCaseString:(NSString *)aString withReply:(void (^)(NSString *))reply {
    NSString *response = [aString uppercaseString];
    reply(response);
}

@end
