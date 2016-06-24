//
//  AsciiDocManager.swift
//  QLAsciiDoc
//
//  Created by Clyde Clements on 2016-06-22.
//  Copyright © 2016 Clyde Clements. All rights reserved.
//

import Foundation
import QuickLook

@objc public class AsciiDocManager: NSObject {
    private let url: NSURL
    
    public init(withUrl url: NSURL) {
        NSLog("In AsciiDocManager.init...")
        self.url = url
    }
    
    private func buildData() -> NSData? {
        NSLog("In AsciiDocManager.buildData...")
        guard let content = try? String(contentsOfFile: "/Users/clyde/Documents/Projects/QLAsciiDoc/compiled-document.html", encoding: NSUTF8StringEncoding) else {
            NSLog("Unable to read file; returning nil")
            return nil
        }
        NSLog("File content read")
        NSLog("%@", content)
        if let data = content.dataUsingEncoding(NSUTF8StringEncoding) {
            NSLog("Data created")
            //let dataPtr = CFDataCreate(kCFAllocatorDefault, UnsafePointer<UInt8>(data.bytes), data.length)
            //return dataPtr
            return data
        }
        NSLog("Unable to create data; returning nil")
        return nil
    }
    
    public func buildPreview() -> NSData? {
        return buildData()
    }
    
    public func buildThumbnail() -> NSData? {
        return buildData()
    }
    
    public func buildPreviewProperties() -> CFDictionaryRef {
        return [
            kQLPreviewPropertyTextEncodingNameKey as String : "UTF-8",
            kQLPreviewPropertyMIMETypeKey as String : "text/html"
            ] as CFDictionaryRef
    }
}