//
//  AsciiDocHelper.m
//  AsciiDocHelper
//
//  Created by Clyde Clements on 2019-09-07.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

#import "AsciiDocHelper.h"
#import <Ruby/Ruby.h>

#define NSStringize_helper(x) #x
#define NSStringize(x) @NSStringize_helper(x)

VALUE getMetadata_wrapper(VALUE docPath);

enum RubyVmState {
    Uninitialized, Initialized, Malfunctioning
};

@interface AsciiDocHelper()

@property char *gemPathEnvVar;
@property NSString *gemPath;
@property NSString *metadataScript;
@property int rubyVmState;

@end

@implementation AsciiDocHelper

- (id)init
{
    self = [super init];
    if (self) {
        self.rubyVmState = Uninitialized;
        NSString *identifier = NSStringize(PRODUCT_BUNDLE_IDENTIFIER);
        NSBundle *bundle = [NSBundle bundleWithIdentifier:identifier];
        if (!bundle) {
            return nil;
        }
        NSString *resourcePath = [bundle resourcePath];
        if (!resourcePath) {
            return nil;
        }
        NSMutableString *gemPath = [[resourcePath stringByAppendingPathComponent:@"ruby"] mutableCopy];
        [gemPath appendString:@":"];
        self.gemPath = [NSString stringWithString:gemPath];
        self.metadataScript = [resourcePath stringByAppendingPathComponent:@"get_metadata.rb"];
        NSLog(@"Resource path: %@", resourcePath);
        NSLog(@"Gem path: %@", self.gemPath);
        NSLog(@"Metadata script: %@", self.metadataScript);
    }
    return self;
}

- (void)getMetadata:(NSString *)filename withReply:(void (^)(NSData *))reply
{
    NSLog(@"Getting metadata for file %@", filename);
    NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
    NSStringEncoding usedEncoding;
    NSError *error;
    NSString *contents = [NSString stringWithContentsOfFile:filename
                                               usedEncoding:&usedEncoding
                                                      error:&error];
    if (contents != nil) {
        [attributes setObject:contents forKey:(NSString *)kMDItemTextContent];
    }
    attributes[(NSString *)kMDItemKind] = @"Plain Text Document";
    if (self.rubyVmState == Malfunctioning) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:attributes];
        reply(data);
        return;
    }

    int state;
    if (self.rubyVmState == Uninitialized) {
        setenv("GEM_PATH", self.gemPath.UTF8String, 1);
        NSLog(@"Setting up Ruby VM");
        ruby_setup();
        NSLog(@"Initializing Ruby VM load path");
        ruby_init_loadpath();
        const char *tmpstr = self.metadataScript.UTF8String;
        char script[strlen(tmpstr) + 1];
        strncpy(script, tmpstr, strlen(tmpstr));
        script[strlen(tmpstr)] = '\0';
        char *options[] = { "ruby-asciidoctor", "-W0", script };
        NSLog(@"Setting options for Ruby VM");
        void *node = ruby_options(3, options);
        if (ruby_executable_node(node, &state)) {
            state = ruby_exec_node(node);
            if (state) {
                NSLog(@"Exception occurred in ruby_exec_node");
                self.rubyVmState = Malfunctioning;
            }
        } else {
            NSLog(@"Exception occurred in ruby_executable_node");
            self.rubyVmState = Malfunctioning;
        }
        if (self.rubyVmState == Malfunctioning) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:attributes];
            reply(data);
            ruby_cleanup(state);
            return;
        }
        NSLog(@"Ruby VM initialized");
        self.rubyVmState = Initialized;
    }
    
    const char *cfilename = filename.UTF8String;
    VALUE docPath = rb_str_buf_new_cstr(cfilename);
    VALUE result = rb_protect(getMetadata_wrapper, rb_ary_new_from_args(1, docPath), &state);
    if (state) {
        NSLog(@"Exception occurred in get_metadata");
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:attributes];
        reply(data);
        self.rubyVmState = Malfunctioning;
        ruby_cleanup(state);
        return;
    }
    char *jsonOutput = rb_string_value_cstr(&result);
    
    if (jsonOutput == NULL) {
        NSLog(@"Null JSON output from Ruby VM");
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:attributes];
        reply(data);
        return;
    }
    
    // Output from Asciidoctor (via Ruby VM) should be in JSON format; convert
    // it to a dictionary.
    NSString *jsonStr = [NSString stringWithCString:jsonOutput
                                           encoding:NSUTF8StringEncoding];
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *metadata = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
    if (metadata == nil) {
        NSLog(@"Error when trying to parse AsciiDoc metadata as JSON");
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:attributes];
        reply(data);
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

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:attributes];
    reply(data);
    
    if (jsonOutput != NULL) free(jsonOutput);
    return;
}

@end

VALUE getMetadata_wrapper(VALUE args)
{
    return rb_funcall(rb_mKernel, rb_intern("get_metadata"), 1, rb_ary_entry(args, 0));
}
