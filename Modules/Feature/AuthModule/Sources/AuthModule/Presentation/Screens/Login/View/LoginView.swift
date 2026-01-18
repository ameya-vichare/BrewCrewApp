//
//  LoginView.swift
//  AuthModule
//
//  Created by Ameya on 03/12/25.
//

import SwiftUI
import AppCore
import Persistence
import Combine

public struct LoginView: View {
    @ObservedObject private var viewModel: DefaultLoginViewModel
    @StateObject private var kb = KeyboardObserver()
    @FocusState private var focussedField: FocussedField?
    
    enum FocussedField {
        case username
        case password
    }
    
    public init(viewModel: DefaultLoginViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            AppColors.secondaryGray.ignoresSafeArea()
            
            VStack {
                Text("Welcome to BrewCrew!")
                    .font(AppFonts.mediumThirty)
                    .foregroundStyle(AppColors.black)
                    .padding([.top], AppPointSystem.point_100)
                
                Text("Login to your account")
                    .font(AppFonts.headlineRegular)
                    .foregroundStyle(AppColors.primaryGray)
                    .padding([.bottom], AppPointSystem.point_48)
                
                VStack(alignment: .leading) {
                    Text("Username")
                        .font(AppFonts.headlineMedium)
                    
                    TextField(
                        "Username",
                        text: $viewModel.username,
                        prompt: Text(
                            "for e.g john.doe"
                        )
                        .foregroundColor(AppColors.primaryGray)
                        .font(AppFonts.subHeadline)
                    )
                        .focused($focussedField, equals: FocussedField.username)
                        .submitLabel(.next)
                        .onSubmit {
                            focussedField = .password
                        }
                        .textFieldStyle(.plain)
                        .padding([.horizontal], AppPointSystem.point_16)
                        .padding([.vertical], AppPointSystem.point_16)
                        .background(
                            RoundedRectangle(cornerRadius: AppPointSystem.point_8)
                                .foregroundStyle(AppColors.white)
                        )
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding([.bottom], AppPointSystem.point_8)
                        .accessibilityIdentifier("UsernameTextField")
                }
                .padding([.bottom], AppPointSystem.point_12)
                
                VStack(alignment: .leading) {
                    Text("Password")
                        .font(AppFonts.headlineMedium)
                    
                    SecureField(
                        "Password",
                        text: $viewModel.password,
                        prompt: Text(
                            "for e.g 1234, seriously don't use this!"
                        )
                        .foregroundColor(AppColors.primaryGray)
                        .font(AppFonts.subHeadline)
                    )
                        .focused($focussedField, equals: FocussedField.password)
                        .submitLabel(.done)
                        .onSubmit {
                            focussedField = nil
                        }
                        .textFieldStyle(.plain)
                        .padding([.horizontal], AppPointSystem.point_16)
                        .padding([.vertical], AppPointSystem.point_16)
                        .background(
                            RoundedRectangle(cornerRadius: AppPointSystem.point_8)
                                .foregroundStyle(AppColors.white)
                        )
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("PasswordTextField")
                }

                Button {
                    viewModel.onLoginClicked()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppPointSystem.point_12)
                            .frame(height: AppPointSystem.point_52)
                            .foregroundStyle(
                                viewModel.isFormValid ? AppColors.primaryCoffee : AppColors.primaryGray
                            )
                        
                        Text(
                            "Login"
                        )
                        .font(AppFonts.mediumSixteen)
                            .foregroundStyle(AppColors.white)
                    }
                }
                .disabled(!viewModel.isFormValid)
                .buttonStyle(.plain)
                .padding([.top], AppPointSystem.point_32)
                .accessibilityIdentifier("LoginButton")
                
                Spacer()
            }
            .padding([.horizontal], AppPointSystem.point_24)
            .padding(.bottom, kb.height)
            .animation(.easeOut, value: kb.height)
        }
        .onTapGesture {
            focussedField = nil
        }
        .alert(item: $viewModel.alertData, content: { alertData in
            Alert(
                title: Text(alertData.title),
                message: Text(alertData.message),
                dismissButton: .default(
                    Text(alertData.button.text),
                    action: alertData.button.action
                ),
            )
        })
    }
}

#Preview {
    LoginView(
        viewModel: DefaultLoginViewModel(
            userLoginUseCase: UserLoginUseCase(
                repository: AuthRepository(
                    dataStore: FakeAuthModuleDataStore(),
                    remoteAPI: FakeAuthRemoteAPI()
                )
            ),
            loginValidationUseCase: LoginValidationUseCase(),
            navigationDelegate: nil
        )
    )
}
