//
//  main.swift
//  AsciiDocCompiler
//
//  Created by Clyde Clements on 2017-10-09.
//  Copyright © 2017 Clyde Clements. All rights reserved.
//

import Foundation

class ServiceDelegate : NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener,
                  shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        // This method is where the NSXPCListener configures, accepts, and
        // resumes a new incoming NSXPCConnection.

        // Configure the connection.
        // First, set the interface that the exported object implements.
        //newConnection.exportedInterface = NSXPCInterface(`protocol`: AsciiDocCompilerProtocol.self)
        NSLog("Setting exported interface for AsciiDoc XPC service")
        newConnection.exportedInterface = NSXPCInterface(with: AsciiDocCompilerProtocol.self)

        // Next, set the object that the connection exports. All messages sent
        // on the connection to this service will be sent to the exported object
        // to handle. The connection retains the exported object.
        NSLog("Setting exported object for AsciiDoc XPC service")
        newConnection.exportedObject = AsciiDocCompiler()

        // Resuming the connection allows the system to deliver more incoming
        // messages.
        NSLog("Starting connection for AsciiDoc XPC service")
        newConnection.resume()

        // Returning true from this method tells the system that you have
        // accepted this connection. If you want to reject the connection for
        // some reason, call `invalidate` on the connection and return false.
        return true
    }
}

NSLog("Creating XPC service for AsciiDoc compiler")
// Create the delegate for the service.
NSLog("Creating delegate for AsciiDoc XPC service")
let delegate = ServiceDelegate()
    
// Set up the one NSXPCListener for this service. It will handle all incoming
// connections.
NSLog("Creating listener for AsciiDoc XPC service")
let listener = NSXPCListener.service()
listener.delegate = delegate;

// Resuming the serviceListener starts this service. This method does not
// return.
NSLog("Starting listener for AsciiDoc XPC service")
listener.resume()
