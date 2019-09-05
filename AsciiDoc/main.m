//
//  main.m
//  AsciiDocRunner
//
//  Created by Clyde Clements on 2019-09-01.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsciiDoc.h"

#define NSStringize_helper(x) #x
#define NSStringize(x) @NSStringize_helper(x)

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *srcRoot = NSStringize(SRCROOT);
        NSString* path = [[srcRoot stringByAppendingPathComponent:@"Tests"]
                           stringByAppendingPathComponent:@"modèle.adoc"];
        AsciiDoc* adoc = [[AsciiDoc alloc] initWithPath:(__bridge CFStringRef)(path)];
        NSMutableDictionary* attributes;
        [adoc getMetadata:attributes];
    }
    return 0;
}
