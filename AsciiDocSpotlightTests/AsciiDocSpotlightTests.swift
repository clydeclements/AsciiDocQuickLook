//
//  AsciiDocSpotlightTests.swift
//  AsciiDocSpotlightTests
//
//  Created by Clyde Clements on 2019-08-21.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

import XCTest
@testable import AsciiDocTools

class AsciiDocSpotlightTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDocWithTitleAuthorAndDates() {
        let doc = """
            = Title
            :author: Author Name
            :created: 2009-12-25
            :revdate: 2010-01-01
            """
        let metadata = getMetadata(fromContents: doc)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        XCTAssertEqual(metadata.title, "Title")
        XCTAssertEqual(metadata.authors, ["Author Name"])
        XCTAssertEqual(metadata.contentCreationDate!, dateFormatter.date(from: "2009-12-25")!)
        XCTAssertEqual(metadata.contentModificationDate!, dateFormatter.date(from: "2010-01-01")!)
    }

    func testDocWithTitleAuthorAndRevisionDate() {
        let doc = """
            = Title
            Author Name
            2010-01-01
            """
        let metadata = getMetadata(fromContents: doc)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        XCTAssertEqual(metadata.title, "Title")
        XCTAssertEqual(metadata.authors, ["Author Name"])
        XCTAssertEqual(metadata.contentModificationDate, dateFormatter.date(from: "2010-01-01"))
    }

    func testDocWithTitleAuthorAndRevisionInfo() {
        let doc = """
            = Title
            Author Name
            v0.1, 2010-01-01
            """
        let metadata = getMetadata(fromContents: doc)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        XCTAssertEqual(metadata.title, "Title")
        XCTAssertEqual(metadata.authors, ["Author Name"])
        XCTAssertEqual(metadata.contentModificationDate, dateFormatter.date(from: "2010-01-01"))
        XCTAssertEqual(metadata.version, "v0.1")
    }

    func testDocWithTitleAuthorAndUid() {
        let doc = """
            = Title
            :uid: abc-123
            """
        let metadata = getMetadata(fromContents: doc)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        XCTAssertEqual(metadata.title, "Title")
        XCTAssertEqual(metadata.identifier, "abc-123")
    }
}
