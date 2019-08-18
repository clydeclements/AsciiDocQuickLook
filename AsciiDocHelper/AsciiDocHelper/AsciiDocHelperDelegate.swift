//
//  AsciiDocHelperDelegate.swift
//  AsciiDocHelper
//
//  Created by Clyde Clements on 2019-08-18.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

import Foundation

class AsciiDocHelperDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        let exportedObject = AsciiDocHelper()
        newConnection.exportedInterface = NSXPCInterface(with: AsciiDocHelperProtocol.self)
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
}
