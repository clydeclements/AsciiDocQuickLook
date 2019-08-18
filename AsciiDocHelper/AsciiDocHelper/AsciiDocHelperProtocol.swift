//
//  AsciiDocHelperProtocol.swift
//  AsciiDocHelper
//
//  Created by Clyde Clements on 2019-08-18.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

import Foundation

@objc public protocol AsciiDocHelperProtocol {
    func getFileMetadata(atPath path: String, withReply reply: ([String: String]) -> Void)
}
