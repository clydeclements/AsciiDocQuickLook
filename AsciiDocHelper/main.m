//
//  main.m
//  AsciiDocHelper
//
//  Created by Clyde Clements on 2019-09-07.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Ruby/Ruby.h>
#import "AsciiDocHelper.h"

#define NSStringize_helper(x) #x
#define NSStringize(x) @NSStringize_helper(x)

void cleanup(void);

@interface ServiceDelegate : NSObject <NSXPCListenerDelegate>
@end

@implementation ServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    // This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
    NSLog(@"New incoming connection");
    
    // Configure the connection.
    // First, set the interface that the exported object implements.
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(AsciiDocHelperProtocol)];
    
    // Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
    AsciiDocHelper *exportedObject = [[AsciiDocHelper alloc] init];
    newConnection.exportedObject = exportedObject;
    
    // Resuming the connection allows the system to deliver more incoming messages.
    [newConnection resume];
    
    // Returning YES from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call -invalidate on the connection and return NO.
    return YES;
}

@end

int main(int argc, const char *argv[])
{
    NSLog(@"Setting up AsciiDocHelper service");
    // Create the delegate for the service.
    ServiceDelegate *delegate = [ServiceDelegate new];
    
    // Set up the one NSXPCListener for this service. It will handle all incoming connections.
    NSString *name = NSStringize(PRODUCT_BUNDLE_IDENTIFIER);
    NSXPCListener *listener = [[NSXPCListener alloc] initWithMachServiceName:name];
    listener.delegate = delegate;
    atexit(cleanup);

    NSLog(@"Starting AsciiDocHelper service");
    [listener resume];
    [[NSRunLoop currentRunLoop] run];
    return 0;
}

void cleanup()
{
    ruby_cleanup(0);
}
