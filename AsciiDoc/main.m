//
//  main.m
//  AsciiDocRunner
//
//  Created by Clyde Clements on 2019-09-01.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsciiDocHelperProtocol.h"

#define NSStringize_helper(x) #x
#define NSStringize(x) @NSStringize_helper(x)

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *srcRoot = NSStringize(SRCROOT);
        //NSString* path = [srcRoot stringByAppendingPathComponent:@"Tests/modèle.adoc"];
        NSString* path = [srcRoot stringByAppendingPathComponent:@"README.adoc"];

        NSXPCConnection *helperConnection = [[NSXPCConnection alloc]
                                             initWithMachServiceName:@"ca.bluemist2.AsciiDocHelper"
                                                             options:0];
        helperConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(AsciiDocHelperProtocol)];
        // TODO: Set interruption handler.
        //helperConnection.interruptionHandler = <#^(void)#>
        // TODO: Set invalidation handler?
        //helperConnection.invalidationHandler = <#^(void)#>
        [helperConnection resume];
        NSLog(@"Connection to AsciiDocHelper established");

        id remoteObject = [helperConnection remoteObjectProxyWithErrorHandler:^(NSError *error) {
            NSLog(@"Error in AsciiDocHelper connection: %@", [error debugDescription]);
        }];
        [remoteObject getMetadata:path withReply:^(NSData *data) {
            // We have received a response. Update our text field, but do it on the main thread.
            NSLog(@"Reply received");
            NSDictionary *attributes = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSLog(@"Attributes: %@", attributes);
        }];
        
        NSLog(@"Waiting for response from AsciiDocHelper");
        [NSThread sleepForTimeInterval:5.0];
        NSLog(@"Closing connection to AsciiDocHelper");
        [helperConnection invalidate];
    }
    return 0;
}
