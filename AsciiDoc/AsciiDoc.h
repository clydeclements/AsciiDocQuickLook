//
//  AsciiDoc.h
//  AsciiDoc Utilities
//
//  Created by Clyde Clements on 2019-08-31.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

#ifndef AsciiDoc_h
#define AsciiDoc_h

@interface AsciiDoc : NSObject;

@property NSString *filename;
@property char *gemPathEnvVar;
@property NSString *gemPath;
@property NSString *metadataScript;

- (id) initWithPath: (CFStringRef) path;
- (void) getMetadata: (NSMutableDictionary *) attributes;

@end

#endif /* AsciiDoc_h */
