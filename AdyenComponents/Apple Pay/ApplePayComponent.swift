//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import PassKit

/// A component that handles Apple Pay payments.
public class ApplePayComponent: NSObject, PresentableComponent, PaymentComponent, Localizable, FinalizableComponent {
    
    /// :nodoc:
    private let payment: Payment

    /// :nodoc:
    internal let applePayPaymentMethod: ApplePayPaymentMethod

    /// :nodoc:
    public let apiContext: APIContext

    /// The Apple Pay payment method.
    public var paymentMethod: PaymentMethod { applePayPaymentMethod }

    /// Apple Pay component configuration.
    internal let configuration: Configuration
    internal var paymentAuthorizationViewController: PKPaymentAuthorizationViewController?
    internal var paymentAuthorizationCompletion: ((PKPaymentAuthorizationStatus) -> Void)?
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// Initializes the component.
    /// - Warning: didFinalize() must be called before dismissing this component.
    ///
    /// - Parameter paymentMethod: The Apple Pay payment method. Must include country code.
    /// - Parameter apiContext: The API environment and credentials.
    /// - Parameter payment: The describes the current payment.
    /// - Parameter configuration: Apple Pay component configuration
    /// - Throws: `ApplePayComponent.Error.userCannotMakePayment`.
    /// if user can't make payments on any of the payment request’s supported networks.
    /// - Throws: `ApplePayComponent.Error.deviceDoesNotSupportApplyPay` if the current device's hardware doesn't support ApplePay.
    /// - Throws: `ApplePayComponent.Error.emptySummaryItems` if the summaryItems array is empty.
    /// - Throws: `ApplePayComponent.Error.negativeGrandTotal` if the grand total is negative.
    /// - Throws: `ApplePayComponent.Error.invalidSummaryItem` if at least one of the summary items has an invalid amount.
    /// - Throws: `ApplePayComponent.Error.invalidCountryCode` if the `payment.countryCode` is not a valid ISO country code.
    /// - Throws: `ApplePayComponent.Error.invalidCurrencyCode` if the `Amount.currencyCode` is not a valid ISO currency code.
    public init(paymentMethod: ApplePayPaymentMethod,
                apiContext: APIContext,
                payment: Payment,
                configuration: Configuration) throws {
        guard PKPaymentAuthorizationViewController.canMakePayments() else {
            throw Error.deviceDoesNotSupportApplyPay
        }
        let supportedNetworks = paymentMethod.supportedNetworks
        guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks) else {
            throw Error.userCannotMakePayment
        }
        guard CountryCodeValidator().isValid(payment.countryCode) else {
            throw Error.invalidCountryCode
        }
        guard CurrencyCodeValidator().isValid(payment.amount.currencyCode) else {
            throw Error.invalidCurrencyCode
        }
        guard configuration.summaryItems.count > 0 else {
            throw Error.emptySummaryItems
        }
        guard let lastItem = configuration.summaryItems.last, lastItem.amount.doubleValue >= 0 else {
            throw Error.negativeGrandTotal
        }
        guard configuration.summaryItems.filter({ $0.amount.isEqual(to: NSDecimalNumber.notANumber) }).count == 0 else {
            throw Error.invalidSummaryItem
        }

        let request = configuration.createPaymentRequest(payment: payment,
                                                         supportedNetworks: supportedNetworks)
        guard let viewController = ApplePayComponent.createPaymentAuthorizationViewController(from: request) else {
            throw UnknownError(
                errorDescription: "Failed to instantiate PKPaymentAuthorizationViewController because of unknown error"
            )
        }

        self.configuration = configuration
        self.apiContext = apiContext
        self.paymentAuthorizationViewController = viewController
        self.applePayPaymentMethod = paymentMethod
        self.payment = payment
        super.init()

        viewController.delegate = self
    }
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public var viewController: UIViewController {
        getPaymentAuthorizationViewController()
    }
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?

    /// Finalizes ApplePay payment after being proccessed by payment provider.
    /// - Parameter success: The status of the payment.
    public func didFinalize(with success: Bool) {
        paymentAuthorizationCompletion?(success ? .success : .failure)
    }

    // MARK: - Private

    internal func dismiss(completion: (() -> Void)?) {
        paymentAuthorizationViewController?.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.paymentAuthorizationViewController = nil
            completion?()
        }
    }
    
    private func getPaymentAuthorizationViewController() -> PKPaymentAuthorizationViewController {
        if paymentAuthorizationViewController == nil {
            let supportedNetworks = applePayPaymentMethod.supportedNetworks
            let request = configuration.createPaymentRequest(payment: payment, supportedNetworks: supportedNetworks)
            paymentAuthorizationViewController = ApplePayComponent.createPaymentAuthorizationViewController(from: request)
            paymentAuthorizationViewController?.delegate = self
            paymentAuthorizationCompletion = nil
        }
        return paymentAuthorizationViewController!
    }
    
    private static func createPaymentAuthorizationViewController(from request: PKPaymentRequest) -> PKPaymentAuthorizationViewController? {
        guard let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request) else {
            adyenPrint("Failed to instantiate PKPaymentAuthorizationViewController.")
            return nil
        }
        
        return paymentAuthorizationViewController
    }
}

extension ApplePayComponent {

    /// Describes the error that can occur during Apple Pay payment.
    public enum Error: Swift.Error, LocalizedError {
        /// Indicates that the user can't make payments on any of the payment request’s supported networks.
        case userCannotMakePayment

        /// Indicates that the current device's hardware doesn't support ApplePay.
        case deviceDoesNotSupportApplyPay

        /// Indicates that the summaryItems array is empty.
        case emptySummaryItems

        /// Indicates that the grand total summary item is a negative value.
        case negativeGrandTotal

        /// Indicates that at least one of the summary items has an invalid amount.
        case invalidSummaryItem

        /// Indicates that the country code is invalid.
        case invalidCountryCode

        /// Indicates that the currency code is invalid.
        case invalidCurrencyCode

        /// :nodoc:
        public var errorDescription: String? {
            switch self {
            case .userCannotMakePayment:
                return "The user can’t make payments on any of the payment request’s supported networks."
            case .deviceDoesNotSupportApplyPay:
                return "The current device's hardware doesn't support ApplePay."
            case .emptySummaryItems:
                return "The summaryItems array is empty."
            case .negativeGrandTotal:
                return "The grand total summary item should be greater than or equal to zero."
            case .invalidSummaryItem:
                return "At least one of the summary items has an invalid amount."
            case .invalidCountryCode:
                return "The country code is invalid."
            case .invalidCurrencyCode:
                return "The currency code is invalid."
            }
        }
    }

}
