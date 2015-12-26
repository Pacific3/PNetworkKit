//
//  DataValidatorTests.swift
//  PFoundation
//
//  Created by Swanros on 12/26/15.
//  Copyright © 2015 Pacific3. All rights reserved.
//

import XCTest
@testable import PFoundation

class DataValidatorTests: XCTestCase {
    func testMatchEmail() {
        XCTAssert(Match.Email.validate("oscar@swanros.com"))
        XCTAssert(Match.Email.validate("oscar@swanros.co"))
        XCTAssert(Match.Email.validate("m45.@swanros.com"))
        XCTAssertFalse(Match.Email.validate("oscar@swanros.c"))
        XCTAssertFalse(Match.Email.validate(".@swanros.com"))
        XCTAssertFalse(Match.Email.validate("$@swanros.com"))
    }
    
    func testMatchPostiveInteger() {
        XCTAssert(Match.PositiveInteger.validate("1"))
        XCTAssert(Match.PositiveInteger.validate("10"))
        XCTAssertFalse(Match.PositiveInteger.validate("-10"))
        XCTAssertFalse(Match.PositiveInteger.validate("-1"))
    }
    
    func testSixSymbolPassword() {
        XCTAssert(Match.SixSymbolPassword.validate("0$c4R$"))
        XCTAssert(Match.SixSymbolPassword.validate("_SC34d"))
        XCTAssertFalse(Match.SixSymbolPassword.validate("123"))
    }
    
    func testOneWord() {
        XCTAssert(Match.OneWord.validate("Oscar"))
        XCTAssertFalse(Match.OneWord.validate("Oscar E."))
    }
    
    func testTwoWords() {
        XCTAssert(Match.TwoWords.validate("Oscar E."))
        XCTAssert(Match.TwoWords.validate("Oscar Eduardo"))
        XCTAssertFalse(Match.TwoWords.validate("Oscar "))
        XCTAssertFalse(Match.TwoWords.validate("Oscar"))
    }
    
    func testEqualToString() {
        XCTAssert(Equal.ToString("Oscar").validate("Oscar"))
        XCTAssert(Equal.ToString("$%23").validate("$%23"))
        
        XCTAssertFalse(Equal.ToString("Oscar").validate("Swanros"))
        XCTAssertFalse(Equal.ToString("$%@#").validate("Marco"))
        
    }
    
    func testEqualToInt() {
        XCTAssert(Equal.ToInt(1).validate(1))
        XCTAssert(Equal.ToInt(3).validate(3))
        XCTAssert(Equal.ToInt(9000).validate(9000))
        
        XCTAssertFalse(Equal.ToInt(1).validate(3))
        XCTAssertFalse(Equal.ToInt(1).validate(2))
        XCTAssertFalse(Equal.ToInt(1).validate(9))
    }
    
    func testEqualToFloat() {
        XCTAssert(Equal.ToFloat(1.5).validate(1.5))
        XCTAssert(Equal.ToFloat(1.9).validate(1.9))
    }
}