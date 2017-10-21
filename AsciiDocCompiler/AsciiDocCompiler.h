//
//  AsciiDocCompiler.h
//  AsciiDocCompiler
//
//  Created by Clyde Clements on 2017-10-09.
//  Copyright © 2017 Clyde Clements. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsciiDocCompilerProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface AsciiDocCompiler : NSObject <AsciiDocCompilerProtocol>
@end
