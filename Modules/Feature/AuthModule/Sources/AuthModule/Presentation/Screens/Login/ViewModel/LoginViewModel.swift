//
//  LoginViewModel.swift
//  AuthModule
//
//  Created by Ameya on 05/12/25.
//

import Combine
import Foundation
import AppCore
import Networking

public protocol LoginViewModelOutput {
    var username: String { get set }
    var password: String { get set }
    var isFormValid: Bool { get }
    var alertData: AlertData? { get }
}

public protocol LoginViewModelActions {
    func onLoginClicked()
}

public protocol LoginViewNavigationDelegate {
    func onUserLoginSuccess(userSession: UserSession)
}

public typealias LoginViewModel = LoginViewModelOutput & LoginViewModelActions

@MainActor
public final class DefaultLoginViewModel: ObservableObject, LoginViewModel {
    // MARK: - Input
    @Published public var username: String = ""
    @Published public var password: String = ""
    @Published public var isFormValid: Bool = false
    @Published public var alertData: AlertData?
    
    // MARK: - Usecases
    private let userLoginUseCase: UserLoginUseCaseProtocol
    private let loginValidationUseCase: LoginValidationUseCaseProtocol

    // MARK: - Navigation
    let navigationDelegate: LoginViewNavigationDelegate?
    
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init
    public init(
        userLoginUseCase: UserLoginUseCaseProtocol,
        loginValidationUseCase: LoginValidationUseCaseProtocol,
        navigationDelegate: LoginViewNavigationDelegate?
    ) {
        self.userLoginUseCase = userLoginUseCase
        self.loginValidationUseCase = loginValidationUseCase
        self.navigationDelegate = navigationDelegate
        self.bindPublishers()
    }
    
    // MARK: - Private
    private func bindPublishers() {
        Publishers.CombineLatest($username, $password)
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] username, password in
                guard let self else { return }
                
                let isUsernameValid = self.loginValidationUseCase.validateUsername(username)
                let isPasswordValid = self.loginValidationUseCase.validatePassword(password)
                self.isFormValid = isUsernameValid && isPasswordValid
            }
            .store(in: &cancellables)
    }
    
    private func showAlert(title: String, message: String) {
        self.alertData = AlertData(
            title: title,
            message: message,
            button: (text: "Okay", action: { })
        )
    }
}

// MARK: - Actions
extension DefaultLoginViewModel {
    public func onLoginClicked() {
        Task {
            do {
                let userSession = try await userLoginUseCase.execute(
                    userName: username,
                    password: password
                )
                navigationDelegate?.onUserLoginSuccess(userSession: userSession)
            } catch let error as NetworkError {
                showAlert(title: error.title, message: error.message)
            } catch {
                showAlert(title: "Login Failed", message: "Please try again.")
            }
        }
    }
}
