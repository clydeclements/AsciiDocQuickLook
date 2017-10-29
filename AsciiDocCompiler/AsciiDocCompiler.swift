//
//  AsciiDocCompiler.m
//  AsciiDocCompiler
//
//  Created by Clyde Clements on 2017-10-09.
//  Copyright © 2017 Clyde Clements. All rights reserved.
//

import Foundation

class AsciiDocCompiler: NSObject, AsciiDocCompilerProtocol {
    fileprivate let configDir: String
    
    public override init() {
        // TODO: let configPath = "\(NSHomeDirectory())/.asciidoc.qlconf"
        //configDir = "\(NSHomeDirectory())/.asciidoctor"
        NSLog("Setting config directory for AsciiDoc compiler")
        configDir = "/Users/clyde/.asciidoctor"
    }
    
    func compileDocument(docpath: NSString!, withReply: (NSData?)->Void) {
        NSLog("Request to compile AsciiDoc file " + String(docpath))
        let task = Process()
        let pipe = Pipe()
        
        let docInfoDirAttribute = "docinfodir=\(configDir)"
        let loadLibrary = "\(configDir)/devonthink-uri-processor.rb"
        task.launchPath = "/usr/local/bin/asciidoctor"
        task.arguments = [
            "-b", "html5",
            "-a", "nofooter",
            "-a", "allow-uri-read",
            "-a", "data-uri",
            "-a", docInfoDirAttribute,
            "-a", "docinfo1",
            "-r", loadLibrary,
            "-o", "-", String(docpath)
        ]
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
            withReply(data as NSData?)
        } else {
            let msg = "Unable to compile document"
            NSLog(msg)
            withReply(nil)
        }
    }
}
