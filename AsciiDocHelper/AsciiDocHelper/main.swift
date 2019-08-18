//
//  main.swift
//  AsciiDocHelper
//
//  Created by Clyde Clements on 2019-08-18.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

import Foundation

let delegate = AsciiDocHelperDelegate()
let listener = NSXPCListener.service()
listener.delegate = delegate
listener.resume()
