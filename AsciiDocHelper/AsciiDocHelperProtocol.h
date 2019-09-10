//
//  AsciiDocHelperProtocol.h
//  AsciiDocHelper
//
//  Created by Clyde Clements on 2019-09-07.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

#import <Foundation/Foundation.h>

// The protocol that this service will send as its API.
@protocol AsciiDocHelperProtocol

- (void) getMetadata:(NSString *)filename withReply:(void (^)(NSData *))reply;
    
@end
