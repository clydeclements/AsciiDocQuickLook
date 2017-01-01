//
//  GetMetadataForFile.m
//  AsciiDoc Spotlight
//
//  Created by Clyde Clements on 2016-12-29.
//  Copyright © 2016 Clyde Clements. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#import <CoreData/CoreData.h>
#import "AsciiDoc-Swift.h"

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

    Boolean ok = FALSE;
    NSLog(@"AsciiDoc Spotlight Importer: Getting file metadata");
    @autoreleasepool {
        if ([(__bridge NSString *)contentTypeUTI isEqualToString:@"org.asciidoc"]) {
            AsciiDocImporter *importer = [[AsciiDocImporter alloc] init];
            ok = [importer
                  importFileAtPath:(__bridge NSString *)pathToFile
                  attributes:(__bridge NSMutableDictionary *)attributes];
        }
    }
    
    // Return the status
    return ok;
}
