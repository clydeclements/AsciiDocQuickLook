//
//  AsciiDoc.m
//  AsciiDoc Utilities
//
//  Created by Clyde Clements on 2019-08-31.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Ruby/Ruby.h>
#import "AsciiDoc.h"

#define NSStringize_helper(x) #x
#define NSStringize(x) @NSStringize_helper(x)

VALUE getMetadataViaRuby(VALUE docPath);

@implementation AsciiDoc

- (id) initWithPath:(CFStringRef)path
{
    self = [super init];
    if (self) {
        self.filename = (__bridge NSString *)path;
#if DEBUG
        NSString *resourcePath = NSStringize(RESOURCE_PATH);
        NSString *gemPath = NSStringize(GEM_PATH);
#else
        NSString *identifier = NSStringize(PRODUCT_BUNDLE_IDENTIFIER);
        NSBundle *bundle = [NSBundle bundleWithIdentifier:identifier];
        if (!bundle) {
            return nil;
        }
        NSString *resourcePath = [bundle resourcePath];
        if (!resourcePath) {
            return nil;
        }
        NSMutableString *gemPath = [[resourcePath stringByAppendingPathComponent:@"gems"] mutableCopy];
        [gemPath appendString:@":"];
#endif
        self.gemPath = [NSString stringWithString:gemPath];
        self.metadataScript = [resourcePath stringByAppendingPathComponent:@"get_metadata.rb"];
        self.gemPathEnvVar = getenv("GEM_PATH");
        NSLog(@"Resource path: %@", resourcePath);
        NSLog(@"Gem path: %@", self.gemPath);
        NSLog(@"Metadata script: %@", self.metadataScript);
    }
    return self;
}

- (void) getMetadata:(NSMutableDictionary *)attributes
{
    NSStringEncoding usedEncoding;
    NSError *error;
    NSString *contents = [NSString stringWithContentsOfFile:self.filename
                                               usedEncoding:&usedEncoding
                                                      error:&error];
    if (contents != nil) {
        [attributes setObject:contents forKey:(NSString *)kMDItemTextContent];
    }
    attributes[(NSString *)kMDItemKind] = @"Plain Text Document";
    setenv("GEM_PATH", self.gemPath.UTF8String, 1);
    ruby_setup();
    ruby_init_loadpath();
    const char *tmpstr = self.metadataScript.UTF8String;
    char script[strlen(tmpstr) + 1];
    strncpy(script, tmpstr, strlen(tmpstr));
    script[strlen(tmpstr)] = '\0';
    char *options[] = { "ruby-asciidoctor", "-W0", script };
    void *node = ruby_options(3, options);
    int state;
    if (ruby_executable_node(node, &state)) {
        state = ruby_exec_node(node);
    } else {
        NSLog(@"Exception occurred in ruby_executable_node");
        ruby_cleanup(state);
        return;
    }
    if (state) {
        NSLog(@"Exception occurred in ruby_exec_node");
        ruby_cleanup(state);
        return;
    }
    const char *filename = self.filename.UTF8String;
    VALUE docPath = rb_str_buf_new_cstr(filename);
    VALUE result = rb_protect(getMetadataViaRuby, docPath, &state);
    if (state) {
        NSLog(@"Exception occurred in get_metadata");
        ruby_cleanup(state);
        return;
    }
    char *output = rb_string_value_cstr(&result);
    // Finished with the Ruby VM.
    ruby_cleanup(state);

    // Restore original setting for GEM_PATH environment variable.
    if (self.gemPathEnvVar == NULL) {
        unsetenv("GEM_PATH");
    } else {
        setenv("GEM_PATH", self.gemPathEnvVar, 1);
    }

    if (output == NULL) {
        return;
    }

    // Output from Asciidoctor (via Ruby VM) should be in JSON format; convert
    // it to a dictionary.
    NSString *jsonStr = [NSString stringWithCString:output
                                           encoding:NSUTF8StringEncoding];
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *metadata = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
    if (metadata == nil) {
        NSLog(@"Error when trying to parse AsciiDoc metadata as JSON");
        return;
    }

    NSString *obj;
    static NSISO8601DateFormatter *dateFormater = nil;
    if (dateFormater == nil) {
        dateFormater = [[NSISO8601DateFormatter alloc] init];
        dateFormater.formatOptions = NSISO8601DateFormatWithInternetDateTime;
    }
    if ((obj = metadata[@"doctitle"]) != nil) {
        [attributes setObject:obj forKey:(NSString *)kMDItemTitle];
    }
    if ((obj = metadata[@"authors"]) != nil) {
        NSArray *components = [obj componentsSeparatedByString:@","];
        NSMutableArray *authors = [NSMutableArray arrayWithCapacity:components.count];
        for (NSUInteger i = 0; i < components.count; i++) {
            authors[i] = [components[i] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        }
        attributes[(NSString *)kMDItemAuthors] = authors;
    } else if ((obj = metadata[@"author"]) != nil) {
        NSArray *authors = @[obj];
        attributes[(NSString *)kMDItemAuthors] = authors;
    }
    // NOTE: Date fields expect a full date (i.e., include year, month and day).
    if ((obj = metadata[@"created"]) != nil) {
        NSDate *created = [dateFormater dateFromString:obj];
        attributes[(NSString *)kMDItemContentCreationDate] = created;
    }
    if ((obj = metadata[@"revdate"]) != nil) {
        NSDate *revdate = [dateFormater dateFromString:obj];
        attributes[(NSString *)kMDItemContentModificationDate] = revdate;
    }
    if ((obj = metadata[@"keywords"]) != nil) {
        NSArray *components = [obj componentsSeparatedByString:@","];
        NSMutableArray *keywords = [NSMutableArray arrayWithCapacity:components.count];
        for (NSUInteger i = 0; i < components.count; i++) {
            keywords[i] = [components[i] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        }
        attributes[(NSString *)kMDItemKeywords] = keywords;
    }
    if ((obj = metadata[@"uid"]) != nil) {
        [attributes setObject:obj forKey:(NSString *)kMDItemIdentifier];
    }
    printf("%s\n", output);
}

@end

VALUE getMetadataViaRuby(VALUE docPath)
{
    VALUE result = rb_funcallv(0, rb_intern("get_metadata"), 1, &docPath);
    return result;
}
