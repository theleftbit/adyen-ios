//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenComponents
import XCTest

class BoletoComponentTests: XCTestCase {
    
    private var sut: BoletoComponent!

    func testUIConfiguration() {
        let dummyExpectation = expectation(description: "Dummy Expectation")
        var style = FormComponentStyle()
        
        let textStyle = TextStyle(
            font: .preferredFont(forTextStyle: .body),
            color: .brown,
            textAlignment: .natural
        )
        
        let imageStyle = ImageStyle(
            borderColor: .cyan,
            borderWidth: 10.0,
            cornerRadius: 10.0,
            clipsToBounds: true,
            contentMode: .left
        )
        
        style.backgroundColor = .blue
        
        style.sectionHeader = TextStyle(
            font: .systemFont(ofSize: 20, weight: .semibold),
            color: .darkGray,
            textAlignment: .left
        )
        
        style.textField = FormTextItemStyle(
            title: textStyle,
            text: textStyle,
            placeholderText: textStyle,
            icon: imageStyle
        )
        
        var switchStyle = FormToggleItemStyle(title: textStyle)
        switchStyle.tintColor = UIColor.red
        switchStyle.separatorColor = UIColor.yellow
        switchStyle.backgroundColor = UIColor.blue
        
        style.toggle = switchStyle
        
        style.hintLabel = textStyle
        
        style.mainButtonItem = FormButtonItemStyle(
            button: ButtonStyle(title: textStyle, cornerRadius: 25.0, background: .gray),
            background: .magenta
        )
        
        style.secondaryButtonItem = FormButtonItemStyle(
            button: ButtonStyle(title: textStyle, cornerRadius: 25.0, background: .gray),
            background: .magenta
        )
        
        sut = BoletoComponent(
            configuration: getConfiguration(with: nil, showEmailAddress: true),
            apiContext: Dummy.context,
            style: style
        )
        
        let sutVC = sut.viewController
        
        UIApplication.shared.keyWindow?.rootViewController = sutVC
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let firstNameField: UITextField? = sutVC.view.findView(by: "firstNameItem.textField") as? UITextField
            let lastNameField: UITextField? = sutVC.view.findView(by: "lastNameItem.textField") as? UITextField
            let socialSecurityNumberField: UITextField? = sutVC.view.findView(by: "socialSecurityNumberItem.textField") as? UITextField
            let emailSwitch: UISwitch? = sutVC.view.findView(by: "sendCopyToEmailItem.switch") as? UISwitch
            let emailSwitchTitleLabel: UILabel? = sutVC.view.findView(by: "sendCopyToEmailItem.titleLabel") as? UILabel
            let emailField: UITextField? = sutVC.view.findView(by: "emailItem.textField") as? UITextField
            let submitButton: SubmitButton? = sutVC.view.findView(by: "payButtonItem.button") as? SubmitButton
            
            // Test first name field
            XCTAssertNotNil(firstNameField)
            XCTAssertEqual(firstNameField?.textColor, style.textField.text.color)
            XCTAssertEqual(firstNameField?.textAlignment, textStyle.textAlignment)
            XCTAssertEqual(firstNameField?.font, textStyle.font)
            
            // Test last name field
            XCTAssertNotNil(lastNameField)
            XCTAssertEqual(lastNameField?.textColor, style.textField.text.color)
            XCTAssertEqual(lastNameField?.textAlignment, textStyle.textAlignment)
            XCTAssertEqual(lastNameField?.font, textStyle.font)
            
            // Test social security number field
            XCTAssertNotNil(socialSecurityNumberField)
            XCTAssertEqual(socialSecurityNumberField?.textColor, style.textField.text.color)
            XCTAssertEqual(socialSecurityNumberField?.textAlignment, textStyle.textAlignment)
            XCTAssertEqual(socialSecurityNumberField?.font, textStyle.font)
            
            // Test send copy by email item
            XCTAssertNotNil(emailSwitch)
            XCTAssertFalse(emailSwitch!.isOn)
            XCTAssertEqual(emailSwitch?.onTintColor, switchStyle.tintColor)
            XCTAssertNotNil(emailSwitchTitleLabel)
            XCTAssertEqual(emailSwitchTitleLabel?.textColor, switchStyle.title.color)
            XCTAssertEqual(emailSwitchTitleLabel?.textAlignment, switchStyle.title.textAlignment)
            XCTAssertEqual(emailSwitchTitleLabel?.font, switchStyle.title.font)

            // Test email field
            XCTAssertNotNil(emailField)
            XCTAssertEqual(emailField?.textColor, style.textField.text.color)
            XCTAssertEqual(emailField?.textAlignment, textStyle.textAlignment)
            XCTAssertEqual(emailField?.font, textStyle.font)
            
            // Test submit button
            XCTAssertNotNil(submitButton)
            
            dummyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFullPrefilledInfo() {
        let dummyExpectation = expectation(description: "Dummy Expectation")
        
        let prefilledInformation = dummyFullPrefilledInformation
        
        sut = BoletoComponent(
            configuration: getConfiguration(with: prefilledInformation, showEmailAddress: true),
            apiContext: Dummy.context
        )
        
        let sutVC = sut.viewController
        
        UIApplication.shared.keyWindow?.rootViewController = sutVC
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            
            let firstNameField: UITextField? = sutVC.view.findView(by: "firstNameItem.textField") as? UITextField
            let lastNameField: UITextField? = sutVC.view.findView(by: "lastNameItem.textField") as? UITextField
            let socialSecurityNumberField: UITextField? = sutVC.view.findView(by: "socialSecurityNumberItem.textField") as? UITextField
            let emailField: UITextField? = sutVC.view.findView(by: "emailItem.textField") as? UITextField
            let addressLabel: UILabel? = self.sut.viewController.view.findView(by: "preFilledBillingAddress") as? UILabel
            
            XCTAssertNotNil(firstNameField)
            XCTAssertEqual(firstNameField?.text, prefilledInformation.shopperName?.firstName)
            
            XCTAssertNotNil(lastNameField)
            XCTAssertEqual(lastNameField?.text, prefilledInformation.shopperName?.lastName)

            XCTAssertNotNil(socialSecurityNumberField)
            XCTAssertEqual(socialSecurityNumberField?.text, prefilledInformation.socialSecurityNumber)
            
            XCTAssertNotNil(emailField)
            XCTAssertEqual(emailField?.text, prefilledInformation.emailAddress)

            XCTAssertNotNil(addressLabel)
            XCTAssertEqual(addressLabel?.text, self.dummyAddress.formatted)
            
            dummyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testNoPrefilledInformation() {
        let dummyExpectation = expectation(description: "Dummy Expectation")
        
        sut = BoletoComponent(
            configuration: getConfiguration(with: nil, showEmailAddress: true),
            apiContext: Dummy.context
        )
        
        let sutVC = sut.viewController
        
        UIApplication.shared.keyWindow?.rootViewController = sutVC
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            
            let firstNameField: UITextField? = sutVC.view.findView(by: "firstNameItem.textField") as? UITextField
            let lastNameField: UITextField? = sutVC.view.findView(by: "lastNameItem.textField") as? UITextField
            let socialSecurityNumberField: UITextField? = sutVC.view.findView(by: "socialSecurityNumberItem.textField") as? UITextField
            let emailField: UITextField? = sutVC.view.findView(by: "emailItem.textField") as? UITextField
            let addressLabel: UILabel? = self.sut.viewController.view.findView(by: "preFilledBillingAddress") as? UILabel
            
            XCTAssertNotNil(firstNameField)
            XCTAssertNil(firstNameField?.text?.adyen.nilIfEmpty)
            
            XCTAssertNotNil(lastNameField)
            XCTAssertNil(lastNameField?.text?.adyen.nilIfEmpty)
            
            XCTAssertNotNil(socialSecurityNumberField)
            XCTAssertNil(socialSecurityNumberField?.text?.adyen.nilIfEmpty)
            
            XCTAssertNotNil(emailField)
            XCTAssertNil(emailField?.text?.adyen.nilIfEmpty)
            
            XCTAssertNil(addressLabel)
            
            dummyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testNoEmailSection() {
        let dummyExpectation = expectation(description: "Dummy Expectation")
        
        sut = BoletoComponent(
            configuration: getConfiguration(with: nil, showEmailAddress: false),
            apiContext: Dummy.context
        )
        
        let sutVC = sut.viewController
        
        UIApplication.shared.keyWindow?.rootViewController = sutVC
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let emailSwitch: UISwitch? = sutVC.view.findView(by: "sendCopyToEmailItem.switch") as? UISwitch
            let emailField: UITextField? = sutVC.view.findView(by: "emailItem.textField") as? UITextField
            
            // Test that email switch does not exist
            XCTAssertNil(emailSwitch)

            // Test that email field does not exist
            XCTAssertNil(emailField)

            dummyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testEmailFieldHiding() {
        let dummyExpectation = expectation(description: "Dummy Expectation")
        
        sut = BoletoComponent(
            configuration: getConfiguration(with: dummyFullPrefilledInformation, showEmailAddress: true),
            apiContext: Dummy.context
        )
        
        let sutVC = sut.viewController
        
        UIApplication.shared.keyWindow?.rootViewController = sutVC
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            
            let emailSwitchItem: FormToggleItemView? = sutVC.view.findView(by: "sendCopyToEmailItem") as? FormToggleItemView
            
            XCTAssertNotNil(emailSwitchItem)
            
            let emailSwitch: UISwitch? = emailSwitchItem!.findView(by: "sendCopyToEmailItem.switch") as? UISwitch
            let emailItem: FormItemView? = sutVC.view.findView(by: "emailItem") as? FormTextItemView<FormTextInputItem>
            
            // Test that email switch has false by default
            XCTAssertNotNil(emailSwitch)
            XCTAssertFalse(emailSwitch!.isOn)
            
            // Test that email field is hidden
            XCTAssertNotNil(emailItem)
            XCTAssertTrue(emailItem!.isHidden)
            
            emailSwitchItem?.accessibilityActivate()
                
            // Test that email field is visible
            XCTAssertFalse(emailItem!.isHidden)
                
            dummyExpectation.fulfill()
    
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testPaymentDataProvided() {
        let mockInformation = dummyFullPrefilledInformation
        let mockConfiguration = getConfiguration(with: mockInformation, showEmailAddress: true)
        let mockDelegate = PaymentComponentDelegateMock()
        let dummyExpectation = expectation(description: "Dummy Expectation")
        
        mockDelegate.onDidSubmit = { paymentData, paymentComponent in
            let boletoDetails = paymentData.paymentMethod as? BoletoDetails
            XCTAssertNotNil(boletoDetails)
            
            XCTAssertEqual(boletoDetails?.shopperName, mockInformation.shopperName)
            XCTAssertEqual(boletoDetails?.socialSecurityNumber, mockInformation.socialSecurityNumber)
            XCTAssertEqual(boletoDetails?.emailAddress, mockInformation.emailAddress)
            XCTAssertEqual(boletoDetails?.billingAddress, mockInformation.billingAddress)
            XCTAssertEqual(boletoDetails?.type, mockConfiguration.boletoPaymentMethod.type)
            XCTAssertNil(boletoDetails?.telephoneNumber)
            
            dummyExpectation.fulfill()
        }
        
        sut = BoletoComponent(configuration: mockConfiguration, apiContext: Dummy.context)
        sut.delegate = mockDelegate
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
        
            let submitButton: SubmitButton? = self.sut.viewController.view.findView(by: "payButtonItem.button") as? SubmitButton
        
            submitButton?.sendActions(for: .touchUpInside)
            
        }
    
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testPaymentDataProvidedNoEmail() {
        var mockInformation = dummyFullPrefilledInformation
        mockInformation.emailAddress = nil
        let mockConfiguration = getConfiguration(with: mockInformation, showEmailAddress: true)
        let mockDelegate = PaymentComponentDelegateMock()
        let dummyExpectation = expectation(description: "Dummy Expectation")

        mockDelegate.onDidSubmit = { paymentData, paymentComponent in
            XCTAssertTrue(paymentComponent === self.sut)

            let boletoDetails = paymentData.paymentMethod as? BoletoDetails
            XCTAssertNotNil(boletoDetails)

            XCTAssertNil(boletoDetails?.emailAddress)

            dummyExpectation.fulfill()
        }

        sut = BoletoComponent(configuration: mockConfiguration, apiContext: Dummy.context)
        sut.delegate = mockDelegate

        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {

            let submitButton: SubmitButton? = self.sut.viewController.view.findView(by: "payButtonItem.button") as? SubmitButton

            submitButton?.sendActions(for: .touchUpInside)

        }

        waitForExpectations(timeout: 15, handler: nil)
    }
    
    private let dummyAddress = PostalAddress(
        city: "São Paulo",
        country: "BR",
        houseNumberOrName: "952",
        postalCode: "04386040",
        stateOrProvince: "SP",
        street: "Rua Funcionarios",
        apartment: nil
    )
    
    private let dummyName = ShopperName(firstName: "Eerst", lastName: "Laatst")
    
    private let dummySocialSecurityNumber = "66818021000127"
    
    private let dummyEmail = "foo@bar.baz"
    
    private var dummyFullPrefilledInformation: PrefilledShopperInformation {
        PrefilledShopperInformation(
            shopperName: dummyName,
            emailAddress: dummyEmail,
            telephoneNumber: nil,
            billingAddress: dummyAddress,
            socialSecurityNumber: dummySocialSecurityNumber
        )
    }
    
    private func getConfiguration(
        with shopperInfo: PrefilledShopperInformation?,
        showEmailAddress: Bool
    ) -> BoletoComponent.Configuration {
        BoletoComponent.Configuration(
            boletoPaymentMethod:
            BoletoPaymentMethod(type: "boletobancario_santander_test", name: "Boleto Bancario"),
            payment: Payment(amount: Amount(value: 25000, currencyCode: "BRL"), countryCode: "BR"),
            shopperInfo: shopperInfo,
            showEmailAddress: showEmailAddress
        )
    }

}
