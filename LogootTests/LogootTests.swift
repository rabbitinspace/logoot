//
//  LogootTests.swift
//  LogootTests
//
//  Created by Igor Nikitin on 11/2/19.
//  Copyright © 2019 Igor Nikitin. All rights reserved.
//

import XCTest
@testable import Logoot

class LogootTests: XCTestCase {

    func testInsert() {
        let doc = Document(site: 0)
        
        doc.insert("a", at: 0)
        XCTAssertEqual(doc.string, "a")
        
        doc.insert("b", at: 1)
        XCTAssertEqual(doc.string, "ab")
        
        doc.insert("c", at: 1)
        XCTAssertEqual(doc.string, "acb")
        
        doc.insert("d", at: 3)
        XCTAssertEqual(doc.string, "acbd")
    }
    
    func testDelete() {
        let doc = Document(site: 0)
        doc.insert("a", at: 0)
        doc.insert("b", at: 1)
        doc.insert("c", at: 2)
        doc.insert("d", at: 3)
        XCTAssertEqual(doc.string, "abcd")
        
        doc.remove(at: 2)
        XCTAssertEqual(doc.string, "abd")
        
        doc.remove(at: 2)
        XCTAssertEqual(doc.string, "ab")
        
        doc.remove(at: 0)
        XCTAssertEqual(doc.string, "b")
        
        doc.remove(at: 0)
        XCTAssertEqual(doc.string, "")
    }
    
    func testInsertDelete() {
        let doc = Document(site: 0)
        
        doc.insert("a", at: 0)
        doc.insert("b", at: 1)
        doc.insert("c", at: 0)
        doc.remove(at: 1)
        XCTAssertEqual(doc.string, "cb")
    }

}
