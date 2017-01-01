//
//  AsciiDocImporter.swift
//  AsciiDoc Spotlight
//
//  Created by Clyde Clements on 2016-12-30.
//  Copyright © 2016 Clyde Clements. All rights reserved.
//

import Foundation

@objc public class AsciiDocImporter: NSObject {
    public func importFile(atPath pathToFile: NSString,
                           attributes: NSMutableDictionary) -> Bool {
        NSLog("AsciiDocImporter import")
        let task = Process()
        let pipe = Pipe()
        let userName = NSUserName()
        let homeDirectory = NSHomeDirectoryForUser(userName)
        let templateDirectory = "\(homeDirectory!)/.asciidoctor/Spotlight/templates"
        task.launchPath = "/usr/local/bin/asciidoctor"
        task.arguments = ["-b", "html5",
                          "-a", "nofooter",
                          "-T", templateDirectory,
                          "-o", "-", pathToFile as String]
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        if (task.terminationStatus == 0) {
            let handle = pipe.fileHandleForReading
            let data = handle.readDataToEndOfFile()
            if let content = String.init(data: data, encoding: .utf8) {
                NSLog("AsciiDoc file parsed: \(pathToFile)")
                NSLog("AsciiDoc file attributes: \(content)")
                if let properties = NSDictionary.init(contentsOfFile: content) {
                    //let attributes = NSMutableDictionary()
                    if let title = properties["doctitle"] as? String {
                        attributes[kMDItemTitle] = title
                    }
                    if let author = properties["author"] as? String {
                        attributes[kMDItemAuthors] = [author]
                    }
                    if let created = properties["created"] as? String {
                        attributes[kMDItemContentCreationDate] = created
                    }
                    if let keywords = properties["keywords"] as? String {
                        let terms = keywords.components(separatedBy: ",")
                        attributes[kMDItemKeywords] = terms
                    }
                    return true
                } else {
                    NSLog("Unable to convert content of file \(pathToFile) to a dictionary")
                    return false
                }
            } else {
                NSLog("Unable to convert content of file \(pathToFile) to a string")
                return false
            }
        } else {
            NSLog("Unable to determine attributes of file \(pathToFile)")
            let status = "Termination status of asciidoctor: " + String(task.terminationStatus)
            NSLog(status)
            return false
        }
    }
}
