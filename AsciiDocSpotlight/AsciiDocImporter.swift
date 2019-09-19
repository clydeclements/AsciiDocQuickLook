//
//  AsciiDocImporter.swift
//  AsciiDoc Spotlight
//
//  Created by Clyde Clements on 2016-12-30.
//  Copyright © 2016 Clyde Clements. All rights reserved.
//

import Foundation
import os

public struct AsciiDocMetadata: Codable {
    var title: String?
    var authors: [String]?
    var contentCreationDate: Date?
    var contentModificationDate: Date?
    var version: String?
    var identifier: String?
    var keywords: String?
    var textContent: String?
    var path: String?
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

extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }

    func matches(_ string: String) -> Bool {
        let range = NSRange(string.startIndex..., in: string)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}

func debug(_ msg: String)
{
    os_log("%s", type: .debug, msg)
}

func info(_ msg: String)
{
    os_log("%s", type: .info, msg)
}

func error(_ msg: String)
{
    os_log("%s", type: .error, msg)
}

func extractHeader(fromContents content: String) -> Array<String>
{
    var lines = content.components(separatedBy: "\n")
    
    // From the Asciidoctor User Manual: "The only content permitted above the
    // document title are blank lines, comment lines and document-wide attribute
    // entries."
    //
    // Comments can be single-line comments that start with two slashes or
    // multi-line block comments that start and end with lines containing four
    // slashes.
    // Filter out block comments first.
    let blockCommentLineRegex = NSRegularExpression("^////")
    let blankLineRegex = NSRegularExpression("^\\s*$")
    var inBlockComment = false
    var numCommentLines = 0
    for line in lines {
        if blockCommentLineRegex.matches(line) {
            numCommentLines += 1
            if inBlockComment {
                break  // Last line of block comment
            } else {
                inBlockComment = true  // First line of block comment
            }
        } else {
            if inBlockComment {
                numCommentLines += 1  // Inside block comment
            } else {
                // Occurs if first line does not start a block comment. Skip
                // blank lines.
                if blankLineRegex.matches(line) {
                    numCommentLines += 1
                } else {
                    break
                }
            }
        }
    }
    lines.removeFirst(numCommentLines)
    // Filter out beginning blank or comment lines.
    let blankOrCommentLineRegex = NSRegularExpression("(^\\s*$)|(^//[^/])")
    numCommentLines = 0
    for line in lines {
        if blankOrCommentLineRegex.matches(line) {
            numCommentLines += 1
        } else {
            break
        }
    }
    lines.removeFirst(numCommentLines)

    // TODO: What if document contains no header?
    var header = Array<String>()
    for line in lines {
        if blankLineRegex.matches(line) {
            break
        }
        header.append(line)
    }
    return header
}

func parseAuthorsFromText(_ text: String) -> [String]
{
    let components = text.components(separatedBy: ",")
    var authors = [String]()
    for author in components {
        authors.append(author.trimmingCharacters(in: .whitespaces))
    }
    return authors
}

struct RevisionInfo {
    var revision: String?
    var revisionDate: Date?
}

func parseRevisionInfoFromText(_ text: String) -> RevisionInfo
{
    var revisionInfo = RevisionInfo()
    if text.contains(",") {
        let range = NSRange(text.startIndex..., in: text)
        let revisionInfoRegex = NSRegularExpression("^([^,]*),(.*)$")
        let revision = revisionInfoRegex.stringByReplacingMatches(
            in: text, options: [], range: range, withTemplate: "$1")
        let dateText = revisionInfoRegex.stringByReplacingMatches(
            in: text, options: [], range: range, withTemplate: "$2")
        let revisionDate = dateText.trimmingCharacters(in: .whitespaces).toDate()
        revisionInfo.revision = revision
        revisionInfo.revisionDate = revisionDate
    } else {
        let revisionDate = text.trimmingCharacters(in: .whitespaces).toDate()
        revisionInfo.revisionDate = revisionDate
    }
    return revisionInfo
}

public func getMetadata(fromContentsOf url: URL) -> AsciiDocMetadata
{
    guard let content = try? String.init(contentsOf: url) else {
        error("Unable to read content of file \(url.path) to a string")
        return AsciiDocMetadata()
    }
    debug("AsciiDoc file read: \(url.path)")
    return getMetadata(fromContents: content)
}

public func getMetadata(fromContents content: String) -> AsciiDocMetadata
{
    var metadata = AsciiDocMetadata()
    metadata.textContent = content
    
    let lines = content.components(separatedBy: "\n")
    debug("Number of lines read: \(lines.count)")
    if lines.count == 0 {
        return metadata
    }

    let header = extractHeader(fromContents: content)
    if header.count == 0 {
        return metadata
    }

    // A document title line starts with a single equal sign followed by one or
    // more spaces. It is legal to have document-wide attributes *before* the
    // title line.
    let titleLineRegex = NSRegularExpression("^= +(\\S+.*)$")
    let attributeLineRegex = NSRegularExpression("^:(\\w+): +(.*)")
    var i = 0
    while i < header.count {
        var line = header[i]
        if titleLineRegex.matches(line) {
            let range = NSRange(line.startIndex..., in: line)
            let title = titleLineRegex.stringByReplacingMatches(
                in: line, options: [], range: range, withTemplate: "$1"
            )
            if title.count > 0 {
                metadata.title = title
            }
            // Check for optional author and revision information lines.
            i += 1
            if i == header.count {
                break
            }
            line = header[i]
            if attributeLineRegex.matches(line) {
                break
            }
            metadata.authors = parseAuthorsFromText(line)
            i += 1
            if i == header.count {
                break
            }
            line = header[i]
            if attributeLineRegex.matches(line) {
                break
            }
            let revisionInfo = parseRevisionInfoFromText(line)
            if let revisionDate = revisionInfo.revisionDate {
                metadata.contentModificationDate = revisionDate
            }
            if let revision = revisionInfo.revision {
                metadata.version = revision
            }
            break
        }
        i += 1
    }

    var properties = [String: String]()
    let fieldLineRegex = NSRegularExpression("^:(\\w+): (.*)")
    for line in header {
        let allOfLine = NSRange(line.startIndex..., in: line)
        if !fieldLineRegex.matches(line) {
            continue
        }
        let key = fieldLineRegex.stringByReplacingMatches(
            in: line, options: [], range: allOfLine,
            withTemplate: "$1"
        )
        let value = fieldLineRegex.stringByReplacingMatches(
            in: line, options: [], range: allOfLine,
            withTemplate: "$2"
        )
        properties[key] = value
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
    if let identifier = properties["uid"] {
        metadata.identifier = identifier
    }
    if let keywords = properties["keywords"] {
        metadata.keywords = keywords
    }
    debug("File metadata: \(metadata)")
    return metadata
}

@objc public class AsciiDocImporter: NSObject {
    @objc public func importFile(atPath pathToFile: NSString,
                           attributes: NSMutableDictionary) -> Bool {
        info("Request to import file \(pathToFile)");
        
        let url = URL.init(fileURLWithPath: pathToFile as String)
        let metadata: AsciiDocMetadata = getMetadata(fromContentsOf: url)
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
        if let version = metadata.version {
            attributes[kMDItemVersion!] = version
        }
        if let identifier = metadata.identifier {
            attributes[kMDItemIdentifier!] = identifier
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
