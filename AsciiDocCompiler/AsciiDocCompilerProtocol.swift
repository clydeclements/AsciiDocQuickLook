//
//  AsciiDocCompilerProtocol.swift
//  AsciiDocCompiler
//
//  Created by Clyde Clements on 2017-10-09.
//  Copyright © 2017 Clyde Clements. All rights reserved.
//

import Foundation

// The protocol that this service will vend as its API.
@objc(AsciiDocCompilerProtocol) protocol AsciiDocCompilerProtocol {
    func compileDocument(docpath: NSString!, withReply: (NSData?)->Void)
}
