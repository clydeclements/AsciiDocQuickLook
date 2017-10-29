//
//  AsciiDocManager.swift
//  AsciiDocQuickLook
//
//  Created by Clyde Clements on 2016-06-22.
//  Copyright © 2016 Clyde Clements. All rights reserved.
//

import Foundation
import QuickLook

@objc(AsciiDocCompilerProtocol) protocol AsciiDocCompilerProtocol {
    func compileDocument(docpath: NSString!, withReply: (NSData?)->Void)
}

@objc open class AsciiDocManager: NSObject {
    fileprivate let url: URL
    fileprivate let configDir: String
    fileprivate var compiledDocument: NSData? = nil
    fileprivate let semaphore = DispatchSemaphore(value: 0)
    fileprivate var remoteProxyError = false
    
    // Connection to XPC service that compiles the AsciiDoc document.
    lazy var asciiDocCompilerConnection: NSXPCConnection = {
        NSLog("Establishing connection to AsciiDoc compiler service")
        let connection = NSXPCConnection(serviceName: "ca.bluemist2.AsciiDocCompiler")
        connection.remoteObjectInterface = NSXPCInterface(with: AsciiDocCompilerProtocol.self)
        connection.resume()
        return connection
    }()
    
    public init(withUrl url: URL) {
        NSLog("Generating preview for file \(url.path)")
        self.url = url
        //configDir = "\(NSHomeDirectory())/.asciidoctor"
        configDir = "/Users/clyde/.asciidoctor"
    }
    
    deinit {
        NSLog("Shutting down connection to AsciiDoc compiler service")
        self.asciiDocCompilerConnection.invalidate()
    }
    
    fileprivate func buildData(_ type: String) -> NSData? {
        NSLog("Retrieving remote object proxy for AsciiDoc compiler service")
        let compiler = self.asciiDocCompilerConnection.remoteObjectProxyWithErrorHandler {
            (error) in
            NSLog("Remote proxy error \(error)")
            self.remoteProxyError = true
            self.semaphore.signal()
        } as! AsciiDocCompilerProtocol
        let docpath = url.path as NSString
        NSLog("Requesting compilation of AsciiDoc file \(docpath)")
        compiler.compileDocument(docpath: docpath) {
            (data) in
            NSLog("Compilation of AsciiDoc file finished")
            self.compiledDocument = data
            self.semaphore.signal()
        }
        let timeout = DispatchTime.now() + .seconds(2)
        if semaphore.wait(timeout: timeout) == .timedOut {
            NSLog("Unable to compile document due to timeout")
        }
        if remoteProxyError {
            NSLog("Unablet to compile document due to remote proxy error")
        }
        //return self.compiledDocument!
        return nil
    }
    
    open func buildPreview() -> NSData? {
        return buildData("preview")
    }
    
    open func buildThumbnail() -> NSData? {
        return buildData("thumbnail")
    }
    
    open func buildPreviewProperties() -> CFDictionary {
        return [
            kQLPreviewPropertyTextEncodingNameKey as String : "UTF-8",
            kQLPreviewPropertyMIMETypeKey as String : "text/html"
            ] as CFDictionary
    }
}
