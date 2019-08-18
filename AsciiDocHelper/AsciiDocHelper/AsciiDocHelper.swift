//
//  AsciiDocHelper.swift
//  AsciiDocHelper
//
//  Created by Clyde Clements on 2019-08-18.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

import Foundation

class AsciiDocHelper: NSObject, AsciiDocHelperProtocol {
    func getFileMetadata(atPath path: String, withReply reply: ([String: String]) -> Void) {
        var properties = [String: String]()
        properties["doctitle"] = "Hello World"
        reply(properties)
    }
}
