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
        self.url = url
    }
    
    private func buildData(type: String) -> NSData? {
        let task = NSTask()
        let pipe = NSPipe()
        
        task.launchPath = "/usr/local/bin/asciidoctor"
        task.arguments = ["-b", "html5", "-a", "nofooter", "-o", "-", url.path!]
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        if (task.terminationStatus == 0) {
            let handle = pipe.fileHandleForReading
            let data = handle.readDataToEndOfFile()
            let status: String = "Termination status: " + String(task.terminationStatus)
            let htmlContent = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
            NSLog("File converted to HTML")
            NSLog(status)
            NSLog(htmlContent)
            return data
        } else {
            let msg = "Unable to create data for " + type + "; returning nil"
            NSLog(msg)
            return nil
        }
    }
    
    public func buildPreview() -> NSData? {
        return buildData("preview")
    }
    
    public func buildThumbnail() -> NSData? {
        return buildData("thumbnail")
    }
    
    public func buildPreviewProperties() -> CFDictionaryRef {
        return [
            kQLPreviewPropertyTextEncodingNameKey as String : "UTF-8",
            kQLPreviewPropertyMIMETypeKey as String : "text/html"
            ] as CFDictionaryRef
    }
}