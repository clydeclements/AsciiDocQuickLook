//
//  GetMetadataForFile.m
//  AsciiDoc Spotlight
//
//  Created by Clyde Clements on 2016-12-29.
//  Copyright © 2016 Clyde Clements. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#import <CoreData/CoreData.h>
#import "AsciiDocHelperProtocol.h"
//#import "AsciiDoc.h"

Boolean GetMetadataForFile(void *thisInterface,
                           CFMutableDictionaryRef attributes,
                           CFStringRef contentTypeUTI, CFStringRef pathToFile);

//==============================================================================
//
//  Get metadata attributes from document files
//
//  The purpose of this function is to extract useful information from the
//  file formats for your document, and set the values into the attribute
//  dictionary for Spotlight to include.
//
//==============================================================================

Boolean GetMetadataForFile(void *thisInterface,
                           CFMutableDictionaryRef attributes,
                           CFStringRef contentTypeUTI, CFStringRef pathToFile)
{
    // Pull any available metadata from the file at the specified path
    // Return the attribute keys and attribute values in the dict
    // Return TRUE if successful, FALSE if there was no data provided
    // The path could point to either a Core Data store file in which
    // case we import the store's metadata, or it could point to a Core
    // Data external record file for a specific record instances

    @autoreleasepool {
        NSLog(@"AsciiDoc Spotlight Plug-in: Attempting to import file %@", (__bridge NSString *)pathToFile);
        if ([(__bridge NSString *)contentTypeUTI isEqualToString:@"org.asciidoc"]) {
            /*
            AsciiDoc *adoc = [[AsciiDoc alloc] initWithPath:pathToFile];
            [adoc getMetadata:(__bridge NSMutableDictionary *)attributes];
            */
            //NSMutableDictionary *attrs = (__bridge NSMutableDictionary *)attributes;
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
            [remoteObject getMetadata:(__bridge NSString *)pathToFile withReply:^(NSData *data) {
                // We have received a response. Update our text field, but do it on the main thread.
                NSLog(@"Reply received");
                NSDictionary *metadata = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
                NSLog(@"Metadata: %@", metadata);
            }];
            
            NSLog(@"Waiting for response from AsciiDocHelper");
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"Closing connection to AsciiDocHelper");
            [helperConnection invalidate];
        }
    }

    // Return the status
    return true;
}
