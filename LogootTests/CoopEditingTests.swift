//
//  CoopEditingTests.swift
//  LogootTests
//
//  Created by Igor Nikitin on 13/2/19.
//  Copyright © 2019 Igor Nikitin. All rights reserved.
//

@testable
import Logoot

import XCTest

class CoopEditingTests: XCTestCase {

    func testOneDocInsertions() {
        let d1 = Document(site: 0)
        let d2 = Document(site: 1)
        
        let op1 = d1.insert("a", at: 0)
        let op2 = d1.insert("b", at: 1)
        let op3 = d1.insert("c", at: 0)
        
        d2.apply(op1)
        d2.apply(op2)
        d2.apply(op3)
        
        XCTAssertEqual(d1.string, "cab")
        XCTAssertEqual(d1.string, d2.string)
    }
    
    func testOneDocInsertionsAndRemovals() {
        let d1 = Document(site: 0)
        let d2 = Document(site: 1)
        
        let op1 = d1.insert("a", at: 0)
        let op2 = d1.insert("b", at: 1)
        let op3 = d1.insert("c", at: 0)
        let op4 = d1.remove(at: 1)
        let op5 = d1.insert("d", at: 1)
        let op6 = d1.insert("e", at: 3)
        let op7 = d1.remove(at: 0)
        
        d2.apply(op1)
        d2.apply(op2)
        d2.apply(op3)
        d2.apply(op4)
        d2.apply(op5)
        d2.apply(op6)
        d2.apply(op7)
        
        XCTAssertEqual(d1.string, "dbe")
        XCTAssertEqual(d1.string, d2.string)
    }

    func testBothInsertAndDelete() {
        let d1 = Document(site: 0)
        let d2 = Document(site: 1)
        
        d2.apply(d1.insert("a", at: 0))
        d2.apply(d1.insert("b", at: 1))
        d2.apply(d1.insert("c", at: 2))
        d2.apply(d1.insert("d", at: 3))
        
        XCTAssertEqual(d1.string, d2.string)
        
        let ins = d1.insert("e", at: 0)
        let rem = d2.remove(at: 2)
        
        d1.apply(rem)
        d2.apply(ins)
        
        XCTAssertEqual(d1.string, "eabd")
        XCTAssertEqual(d1.string, d2.string)
    }
    
}
