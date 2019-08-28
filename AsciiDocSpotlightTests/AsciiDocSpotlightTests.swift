//
//  AsciiDocSpotlightTests.swift
//  AsciiDocSpotlightTests
//
//  Created by Clyde Clements on 2019-08-21.
//  Copyright © 2019 Clyde Clements. All rights reserved.
//

import XCTest
@testable import AsciiDoc

class AsciiDocSpotlightTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDoc() {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let doc = """
            = Title
            :author: Author Name
            :created: 2009-12-25
            :revdate: 2010-01-01
            """
        let docData = doc.data(using: .utf8)!
        let metadata = getAsciiDocMetadata(fromData: docData)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        XCTAssertEqual(metadata.title, "Title")
        XCTAssertEqual(metadata.authors, ["Author Name"])
        XCTAssertEqual(metadata.contentCreationDate!, dateFormatter.date(from: "2009-12-25")!)
        XCTAssertEqual(metadata.contentModificationDate!, dateFormatter.date(from: "2010-01-01")!)
    }
}
