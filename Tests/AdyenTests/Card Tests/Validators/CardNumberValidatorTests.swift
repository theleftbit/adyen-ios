//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardNumberValidatorTests: XCTestCase {
    
    func testValidCards() {
        let validator = CardNumberValidator(isLuhnCheckEnabled: true)
        
        CardNumbers.valid.forEach { cardNumber in
            XCTAssertTrue(validator.isValid(cardNumber))
        }
    }
    
    func testInvalidCards() {
        let validator = CardNumberValidator(isLuhnCheckEnabled: true)
        
        CardNumbers.invalid.forEach { cardNumber in
            XCTAssertFalse(validator.isValid(cardNumber))
        }
    }
    
    func testNonLuhnCheckCards() {
        let validator = CardNumberValidator(isLuhnCheckEnabled: false)
        XCTAssertTrue(validator.isValid("4111111111111112"))
        XCTAssertTrue(validator.isValid("370000000000000"))
        XCTAssertFalse(validator.isValid("37000000000"))
        XCTAssertFalse(validator.isValid("0"))
    }
}
