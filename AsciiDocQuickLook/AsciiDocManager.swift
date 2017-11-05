//
//  AsciiDocManager.swift
//  AsciiDocQuickLook
//
//  Created by Clyde Clements on 2016-06-22.
//  Copyright © 2016 Clyde Clements. All rights reserved.
//

import Foundation
import QuickLook

@objc open class AsciiDocManager: NSObject {
    fileprivate let url: URL
    
    public init(withUrl url: URL) {
        self.url = url
    }
    
    fileprivate func buildData(_ type: String) -> Data? {
        let task = Process()
        var useDefaultConverter = true
        if let prefs = UserDefaults.init(suiteName: "ca.bluemist2.AsciiDocQuickLook") {
            if let converter = prefs.string(forKey: "AsciiDocConverter") {
                let msg = "AsciiDoc Quick Look: using user-specified " +
                    "converter \(converter)"
                NSLog(msg)
                task.launchPath = converter
                useDefaultConverter = false
            }
        }
        if useDefaultConverter {
            // The PATH setting must include /usr/local/bin in order for the
            // asciidoctor script to run with /usr/local/bin/ruby (if installed)
            // instead of /usr/bin/ruby.
            task.environment = [
                "PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
            ]
            task.launchPath = "/usr/local/bin/asciidoctor"
            task.arguments = [
                "-b", "html5", "-a", "nofooter", "-o", "-", url.path
            ]
        } else {
            task.arguments = [url.path]
        }
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        if (task.terminationStatus == 0) {
            let handle = pipe.fileHandleForReading
            let data = handle.readDataToEndOfFile()
            return data
        } else {
            let msg = "AsciiDoc Quick Look: " +
                "converter termination status \(task.terminationStatus); " +
                "unable to create data for \(type)"
            NSLog(msg)
            return nil
        }
    }
    
    open func buildPreview() -> Data? {
        return buildData("preview")
    }
    
    open func buildThumbnail() -> Data? {
        return buildData("thumbnail")
    }
    
    open func buildPreviewProperties() -> CFDictionary {
        return [
            kQLPreviewPropertyTextEncodingNameKey as String : "UTF-8",
            kQLPreviewPropertyMIMETypeKey as String : "text/html"
            ] as CFDictionary
    }
}
