//
//  PollingAwaitComponentTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/12/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import XCTest
@testable import Adyen

class PollingAwaitComponentTests: XCTestCase {

    func testRetryWhenResultIsReceived() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 3))
        let sut = PollingAwaitComponent(apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()
        delegate.onDidFail = { _, _ in
            XCTFail()
        }

        let onDidProvideExpectation = expectation(description: "ActionComponentDelegate.didProvide must be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)

            let details = data.details as! AwaitActionDetails

            XCTAssertEqual(details.payload, "pay load")

            onDidProvideExpectation.fulfill()
        }

        sut.delegate = delegate

        apiClient.mockedResponse = PaymentStatusResponse(payload: "pay load", resultCode: .received)

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 3)
    }

    func testRetryWhenResultIsPending() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 3))
        let sut = PollingAwaitComponent(apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()
        delegate.onDidFail = { _, _ in
            XCTFail()
        }

        let onDidProvideExpectation = expectation(description: "ActionComponentDelegate.didProvide must be called.")
        onDidProvideExpectation.assertForOverFulfill = true
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)

            let details = data.details as! AwaitActionDetails

            XCTAssertEqual(details.payload, "pay load")

            onDidProvideExpectation.fulfill()
        }

        sut.delegate = delegate

        apiClient.mockedResponse = PaymentStatusResponse(payload: "pay load", resultCode: .pending)

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 3)
    }

    func testNotRetryWhenRequestFails() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 3))
        let sut = PollingAwaitComponent(apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()

        let onDidFailExpectation = expectation(description: "ActionComponentDelegate.didFail must be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(error as? DummyError, DummyError.dummy)

            onDidFailExpectation.fulfill()
        }

        delegate.onDidProvide = { _, _ in
            XCTFail()
        }

        sut.delegate = delegate

        apiClient.mockedError = DummyError.dummy

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 1)
    }


    func testNotRetryWhenResultIsRefused() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 3))
        let sut = PollingAwaitComponent(apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()
        delegate.onDidFail = { _, _ in
            XCTFail()
        }

        let onDidProvideExpectation = expectation(description: "ActionComponentDelegate.didProvide must be called.")
        onDidProvideExpectation.assertForOverFulfill = true
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)

            let details = data.details as! AwaitActionDetails

            XCTAssertEqual(details.payload, "pay load")

            onDidProvideExpectation.fulfill()
        }

        sut.delegate = delegate

        apiClient.mockedResponse = PaymentStatusResponse(payload: "pay load", resultCode: .refused)

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 1)
    }

    func testNotRetryWhenResultIsCancelled() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 3))
        let sut = PollingAwaitComponent(apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()
        delegate.onDidFail = { _, _ in
            XCTFail()
        }

        let onDidProvideExpectation = expectation(description: "ActionComponentDelegate.didProvide must be called.")
        onDidProvideExpectation.assertForOverFulfill = true
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)

            let details = data.details as! AwaitActionDetails

            XCTAssertEqual(details.payload, "pay load")

            onDidProvideExpectation.fulfill()
        }

        sut.delegate = delegate

        apiClient.mockedResponse = PaymentStatusResponse(payload: "pay load", resultCode: .cancelled)

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 1)
    }

    func testNotRetryWhenResultIsError() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 3))
        let sut = PollingAwaitComponent(apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()
        delegate.onDidFail = { _, _ in
            XCTFail()
        }

        let onDidProvideExpectation = expectation(description: "ActionComponentDelegate.didProvide must be called.")
        onDidProvideExpectation.assertForOverFulfill = true
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)

            let details = data.details as! AwaitActionDetails

            XCTAssertEqual(details.payload, "pay load")

            onDidProvideExpectation.fulfill()
        }

        sut.delegate = delegate

        apiClient.mockedResponse = PaymentStatusResponse(payload: "pay load", resultCode: .error)

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 1)
    }

    func testNotRetryWhenResultIsAuthorized() {
        let apiClient = APIClientMock()
        let retryApiClient = RetryAPIClient(apiClient: apiClient, scheduler: SimpleScheduler(maximumCount: 3))
        let sut = PollingAwaitComponent(apiClient: retryApiClient)

        let delegate = ActionComponentDelegateMock()
        delegate.onDidFail = { _, _ in
            XCTFail()
        }

        let onDidProvideExpectation = expectation(description: "ActionComponentDelegate.didProvide must be called.")
        onDidProvideExpectation.assertForOverFulfill = true
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)

            let details = data.details as! AwaitActionDetails

            XCTAssertEqual(details.payload, "pay load")

            onDidProvideExpectation.fulfill()
        }

        sut.delegate = delegate

        apiClient.mockedResponse = PaymentStatusResponse(payload: "pay load", resultCode: .authorised)

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(apiClient.counter, 1)
    }
}
