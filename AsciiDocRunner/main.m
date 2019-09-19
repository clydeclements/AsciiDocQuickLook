//
//  main.m
//  AsciiDocRunner
//
//  Created by Clyde Clements on 2019-09-01.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsciiDocImporter-Swift.h"

#define NSStringize_helper(x) #x
#define NSStringize(x) @NSStringize_helper(x)

int main(int argc, const char * argv[]) {
    Boolean status = FALSE;
    @autoreleasepool {
        NSString *srcRoot = NSStringize(SRCROOT);
        //NSString* path = [srcRoot stringByAppendingPathComponent:@"Tests/modèle.adoc"];
        NSString* path = [srcRoot stringByAppendingPathComponent:@"Tests/test1.adoc"];
        AsciiDocImporter *importer = [[AsciiDocImporter alloc] init];
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        status = [importer importFileAtPath:path attributes:attributes];
        
        NSLog(@"Metadata attributes: %@", attributes);
    }
    return status == TRUE ? 0 : 1;
}
