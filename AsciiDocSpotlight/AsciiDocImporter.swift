//
//  AsciiDocImporter.swift
//  AsciiDoc Spotlight
//
//  Created by Clyde Clements on 2016-12-30.
//  Copyright © 2016 Clyde Clements. All rights reserved.
//

import Foundation

public struct AsciiDocMetadata: Codable {
    var title: String?
    var authors: [String]?
    var contentCreationDate: Date?
    var contentModificationDate: Date?
    var keywords: String?
    var textContent: String?
    let kind: String
    
    init() {
        kind = "Plain Text Document"
    }
}

extension String {
    func toDate(withFormat format: String = "yyyy-MM-dd") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        guard let date = dateFormatter.date(from: self) else {
            return nil
        }
        return date
    }
}

func info(_ msg: String) {
    let log_msg_prefix = "AsciiDoc Spotlight: "
    NSLog(log_msg_prefix + msg)
}

public func getAsciiDocMetadata(atPath docPath: String) -> AsciiDocMetadata
{
    let fileManager = FileManager()
    guard let data = fileManager.contents(atPath: docPath) else {
        info("Unable to read content of file \(docPath) to a string")
        return AsciiDocMetadata()
    }
    info("AsciiDoc file read: \(docPath)")
    return getAsciiDocMetadata(fromData: data)
}

public func getAsciiDocMetadata(fromData data: Data) -> AsciiDocMetadata
{
    guard let content = String.init(data: data, encoding: .utf8) else {
        info("Unable to parse content of data as a UTF-8 encoded string")
        return AsciiDocMetadata()
    }
    var metadata = AsciiDocMetadata()
    metadata.textContent = content
    
    let lines = content.components(separatedBy: "\n")
    info("AsciiDoc file number of lines: \(lines.count)")
    if lines.count == 0 {
        return metadata
    }
    
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
            metadata.title = title
        }
    }
    var properties = [String: String]()
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
    if let author = properties["author"] {
        metadata.authors = [author]
    }
    if let created = properties["created"] {
        metadata.contentCreationDate = created.toDate()
    }
    if let modified = properties["revdate"] {
        metadata.contentModificationDate = modified.toDate()
    }
    info("AsciiDoc file metadata: \(metadata)")
    return metadata
}

@objc public class AsciiDocImporter: NSObject {
    @objc public func importFile(atPath pathToFile: NSString,
                           attributes: NSMutableDictionary) -> Bool {
        info("AsciiDocImporter import")
        
        let metadata: AsciiDocMetadata = getAsciiDocMetadata(
            atPath: pathToFile as String)
        attributes[kMDItemKind!] = metadata.kind
        if let content = metadata.textContent {
            attributes[kMDItemTextContent!] = content
        }
        if let title = metadata.title {
            attributes[kMDItemTitle!] = title
        }
        if let authors = metadata.authors {
            attributes[kMDItemAuthors!] = authors
        }
        if let created = metadata.contentCreationDate {
            attributes[kMDItemContentCreationDate!] = created
        }
        if let revdate = metadata.contentModificationDate {
            attributes[kMDItemContentModificationDate!] = revdate
        }
        var keywords: [String] = []
        if let keyword_prop = metadata.keywords {
            let terms = keyword_prop.components(separatedBy: ",")
            for term in terms {
                let keyword = term.trimmingCharacters(in: .whitespaces)
                keywords.append(keyword)
            }
        }
        //if let category_prop = properties["categories"] {
        //    let terms = category_prop.components(separatedBy: ",")
        //    for term in terms {
        //        let category = "_" + term.trimmingCharacters(in: .whitespaces)
        //        keywords.append(category)
        //    }
        //}
        if keywords.count > 0 {
            attributes[kMDItemKeywords!] = keywords
        }
        return true
    }
}
