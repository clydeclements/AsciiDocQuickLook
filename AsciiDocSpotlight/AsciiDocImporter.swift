//
//  AsciiDocImporter.swift
//  AsciiDoc Spotlight
//
//  Created by Clyde Clements on 2016-12-30.
//  Copyright © 2016 Clyde Clements. All rights reserved.
//

import Foundation

@objc public class AsciiDocImporter: NSObject {
    @objc public func importFile(atPath pathToFile: NSString,
                           attributes: NSMutableDictionary) -> Bool {
        NSLog("AsciiDocImporter import")
        let fileManager = FileManager()
        guard let data = fileManager.contents(atPath: pathToFile as String) else {
            NSLog("Unable to read content of file \(pathToFile) to a string")
            return false
        }
        guard let content = String.init(data: data, encoding: .utf8) else {
            NSLog("Unable to parse content of file \(pathToFile) as a UTF-8 encoded string")
            return false
        }
        NSLog("AsciiDoc file read: \(pathToFile)")
        attributes[kMDItemTextContent!] = content
        attributes[kMDItemKind!] = "Plain Text Document"
        let lines = content.components(separatedBy: "\n")
        NSLog("AsciiDoc file number of lines: \(lines.count)")
        if lines.count == 0 {
            return true
        }
        var properties = [String: String]()
        let firstLine = lines[0]
        let titleLineRegex = try? NSRegularExpression(pattern: "^= (.*)$")
        let range = NSRange(location: 0, length: firstLine.count)
        let titleLineMatch = titleLineRegex!.matches(
            in: firstLine, options: [], range: range
        )
        if titleLineMatch.count > 0 {
            let title = titleLineRegex!.stringByReplacingMatches(
                in: firstLine, options: [], range: range, withTemplate: "$1"
            )
            if title.count > 0 {
                properties["doctitle"] = title
            }
        }
        let fieldLineRegex = try? NSRegularExpression(pattern: "^:(\\w+): (.*)")
        for i in 1..<lines.count {
            let line = lines[i]
            let allOfLine = NSRange(location: 0,
                                    length: line.count)
            let match = fieldLineRegex!.matches(in: line, options: [],
                                                range: allOfLine)
            if match.count > 0 {
                let key = fieldLineRegex!.stringByReplacingMatches(
                    in: line, options: [], range: allOfLine,
                    withTemplate: "$1"
                )
                let value = fieldLineRegex!.stringByReplacingMatches(
                    in: line, options: [], range: allOfLine,
                    withTemplate: "$2"
                )
                properties[key] = value
            } else {
                break
            }
        }
        NSLog("AsciiDoc file attributes: \(properties)")
        if let title = properties["doctitle"] {
            attributes[kMDItemTitle!] = title
        }
        if let author = properties["author"] {
            attributes[kMDItemAuthors!] = [author]
        }
        if let created = properties["created"] {
            attributes[kMDItemContentCreationDate!] = created
        }
        if let revdate = properties["revdate"] {
            attributes[kMDItemContentModificationDate!] = revdate
        }
        var keywords: [String] = []
        if let keyword_prop = properties["keywords"] {
            let terms = keyword_prop.components(separatedBy: ",")
            for term in terms {
                let keyword = term.trimmingCharacters(in: .whitespaces)
                keywords.append(keyword)
            }
        }
        if let category_prop = properties["categories"] {
            let terms = category_prop.components(separatedBy: ",")
            for term in terms {
                let category = "_" + term.trimmingCharacters(in: .whitespaces)
                keywords.append(category)
            }
        }
        if keywords.count > 0 {
            attributes[kMDItemKeywords!] = keywords
        }
        return true
    }
}
