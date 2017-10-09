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
    fileprivate let configDir: String
    
    public init(withUrl url: URL) {
        self.url = url
        //configDir = "\(NSHomeDirectory())/.asciidoctor"
        configDir = "/Users/clyde/.asciidoctor"
        //self.configDir = "TEST"
        // TODO: let configPath = "\(NSHomeDirectory())/.asciidoc.qlconf"
    }
    
    fileprivate func buildData(_ type: String) -> Data? {
        let task = Process()
        let pipe = Pipe()
        
        let docInfoDirAttribute = "docinfodir=\(configDir)"
        let loadLibrary = "\(configDir)/devonthink-uri-processor.rb"
        task.launchPath = "/usr/local/bin/asciidoctor"
        task.arguments = ["-b", "html5",
                          "-a", "nofooter",
                          "-a", "allow-uri-read", "-a", "data-uri",
                          "-a", docInfoDirAttribute, "-a", "docinfo1",
                          "-r", loadLibrary,
                          "-o", "-", url.path]
/*
        task.arguments = ["-b", "html5", "-a", "nofooter", "-o", "-", url.path!]
 */
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        if (task.terminationStatus == 0) {
            let handle = pipe.fileHandleForReading
            let data = handle.readDataToEndOfFile()
            let status: String = "Termination status: " + String(task.terminationStatus)
            let htmlContent = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
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
