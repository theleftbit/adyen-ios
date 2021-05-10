//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenSwiftUI
import SwiftUI
import PassKit

internal struct ComponentsView: View {

    @ObservedObject internal var viewModel = PaymentsViewModel()

    internal var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items, id: \.self) { section in
                    Section(content: {
                        ForEach(section, id: \.self, content: getButton)
                    })
                }
            }
            .navigationBarTitle("Components", displayMode: .inline)
            .navigationBarItems(trailing: configurationButton)
            .present(viewController: $viewModel.viewControllerToPresent)
            .onAppear {
                self.viewModel.viewDidAppear()
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    private func getButton(with item: ComponentsItem) -> some View {
        if item.isApplePay {
            getApplePayButton(with: item)
        } else {
            getRegularButton(with: item)
        }
    }

    private var configurationButton: some View {
        Button(action: viewModel.presentConfiguration, label: {
            Image(systemName: "gear")
        })
    }
    
    private func getRegularButton(with item: ComponentsItem) -> some View {
        Button(action: {
            item.selectionHandler()
        }, label: {
            Text(item.title)
                .frame(maxWidth: .infinity)
        })
    }
    
    private func getApplePayButton(with item: ComponentsItem) -> some View {
        Button(action: item.selectionHandler,
               label: { Text("") })
            .buttonStyle(ApplePayButtonStyle())
            .frame(height: 44.0)
            .padding(2.0)
    }
}

private struct ApplePayButton: UIViewRepresentable {
    
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> PKPaymentButton {
        return PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
    }
    
}

private struct ApplePayButtonStyle: SwiftUI.ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        return ApplePayButton()
    }
    
}

// swiftlint:disable:next type_name
internal struct ContentView_Previews: PreviewProvider {
    
    internal static var previews: some View {
        ComponentsView()
    }
    
}
