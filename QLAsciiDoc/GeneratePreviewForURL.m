#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>
#import "QLAsciiDoc-Swift.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
 Generate a preview for file
 This function's job is to create preview for designated file
 ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    if (QLPreviewRequestIsCancelled(preview)) {
        return noErr;
    }
    
    AsciiDocManager* adManager = [[AsciiDocManager alloc] initWithUrl:(__bridge NSURL *)url];
    
    CFDataRef data = (__bridge CFDataRef)[adManager buildPreview];
    
    if (QLPreviewRequestIsCancelled(preview)) {
        return noErr;
    }
    
    CFDictionaryRef properties = [adManager buildPreviewProperties];
    
    if (QLPreviewRequestIsCancelled(preview)) {
        return noErr;
    }
    
    QLPreviewRequestSetDataRepresentation(preview, data, kUTTypeHTML, properties);
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}