//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenActions
import XCTest

class ActionTests: XCTestCase {
    
    func testRedirectActionDecoding() {
        let json =
            """
            {
                "type": "redirect",
                "url": "https://example.org/",
                "paymentData": "example_data"
            }
            """
        
        let action = try? JSONDecoder().decode(Action.self, from: json.data(using: .utf8)!)
        
        var redirectAction: RedirectAction?
        if case let .redirect(redirect)? = action {
            redirectAction = redirect
        }
        
        XCTAssertNotNil(redirectAction)
        XCTAssertEqual(redirectAction?.url.absoluteString, "https://example.org/")
        XCTAssertEqual(redirectAction?.paymentData, "example_data")
    }
    
    func testQRCodeActionDecoding() {
        let json =
            """
            {
                "type": "qrCode",
                "qrCodeData": "example_data",
                "paymentData": "example_data",
                "paymentMethodType": "pix"
            }
            """
        
        let action = try? JSONDecoder().decode(Action.self, from: json.data(using: .utf8)!)
        
        var qrCodeAction: QRCodeAction?
        if case let .qrCode(qrCode)? = action {
            qrCodeAction = qrCode
        }

        XCTAssertNotNil(qrCodeAction)
        XCTAssertEqual(qrCodeAction?.paymentData, "example_data")
        XCTAssertTrue(qrCodeAction?.paymentMethodType == .some(.pix))
    }
    
    func testQRCodeToRedirectActionDecoding() {
        let json =
            """
            {
                "type": "qrCode",
                "url": "https://example.org/",
                "paymentData": "example_data",
                "paymentMethodType": "bcmc_mobile"
            }
            """
        
        let action = try? JSONDecoder().decode(Action.self, from: json.data(using: .utf8)!)
        
        var qrToRedirectAction: RedirectAction?
        if case let .redirect(redirect)? = action {
            qrToRedirectAction = redirect
        }
        
        XCTAssertNotNil(qrToRedirectAction)
        XCTAssertEqual(qrToRedirectAction?.url.absoluteString, "https://example.org/")
        XCTAssertEqual(qrToRedirectAction?.paymentData, "example_data")
    }
    
    func test3DS2FingerprintActionDecoding() {
        let json =
            """
            {
                "type": "threeDS2Fingerprint",
                "token": "example_token",
                "paymentData": "example_data"
            }
            """
        
        let action = try? JSONDecoder().decode(Action.self, from: json.data(using: .utf8)!)
        
        var fingerprintAction: ThreeDS2FingerprintAction?
        if case let .threeDS2Fingerprint(fingerprint)? = action {
            fingerprintAction = fingerprint
        }
        
        XCTAssertNotNil(fingerprintAction)
        XCTAssertEqual(fingerprintAction?.fingerprintToken, "example_token")
        XCTAssertEqual(fingerprintAction?.paymentData, "example_data")
    }
    
    func test3DS2ChallengeActionDecoding() {
        let json =
            """
            {
                "type": "threeDS2Challenge",
                "token": "example_token",
                "paymentData": "example_data"
            }
            """
        
        let action = try? JSONDecoder().decode(Action.self, from: json.data(using: .utf8)!)
        
        var challengeAction: ThreeDS2ChallengeAction?
        if case let .threeDS2Challenge(challenge)? = action {
            challengeAction = challenge
        }
        
        XCTAssertNotNil(challengeAction)
        XCTAssertEqual(challengeAction?.challengeToken, "example_token")
        XCTAssertEqual(challengeAction?.paymentData, "example_data")
    }
    
    func testInvalidActionDecoding() {
        let json = "{ \"type\": \"InvalidType\" }"
        let data = json.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(Action.self, from: data))
    }
    
}
