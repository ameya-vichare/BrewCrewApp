//
//  MenuListViewModel.swift
//  CoffeeModule
//
//  Created by Ameya on 24/10/25.
//

import AppCore
import Combine
import Foundation
import NetworkMonitoring
import Networking

public protocol MenuListViewNavigationDelegate {
    func showMenuModifierBottomsheet(for item: MenuItem, onOrderItemCreated: @escaping ((CreateOrderItem) -> Void))
}

public protocol MenuListViewModelOutput {
    var state: ScreenViewState { get }
    var datasource: [MenuListCellType] { get }
    var alertData: AlertData? { get }
}

public protocol MenuListViewModelActions {
    func viewDidLoad() async
}

public typealias MenuListViewModel = MenuListViewModelOutput & MenuListViewModelActions & ObservableObject

@MainActor
public final class DefaultMenuListViewModel: MenuListViewModel {
    public let networkMonitor: NetworkMonitoring
    
    public let getMenuUseCase: GetMenuUsecaseProtocol
    public let createOrderUseCase: CreateOrderUsecaseProtocol
    public let retryPendingOrdersUsecase: RetryPendingOrdersUsecaseProtocol
    
    public let navigationDelegate: MenuListViewNavigationDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Output
    @Published public var state: ScreenViewState = .preparing
    @Published public var datasource: [MenuListCellType] = []
    @Published public var alertData: AlertData?
    
    // MARK: - Init
    public init(
        networkMonitor: NetworkMonitoring,
        getMenuUseCase: GetMenuUsecaseProtocol,
        createOrderUseCase: CreateOrderUsecaseProtocol,
        retryPendingOrdersUsecase: RetryPendingOrdersUsecaseProtocol,
        navigationDelegate: MenuListViewNavigationDelegate?
    ) {
        self.networkMonitor = networkMonitor
        self.getMenuUseCase = getMenuUseCase
        self.createOrderUseCase = createOrderUseCase
        self.retryPendingOrdersUsecase = retryPendingOrdersUsecase
        self.navigationDelegate = navigationDelegate
        self.bindChildren()
    }
}

// MARK: - Input
extension DefaultMenuListViewModel {
    public func viewDidLoad() async {
        await getMenuItems()
    }
}

// MARK: - Binding
extension DefaultMenuListViewModel {
    private func bindChildren() {
        self.networkMonitor.monitoringPublisher
            .removeDuplicates()
            .debounce(
                for: .milliseconds(1000),
                scheduler: DispatchQueue.main
            )
            .sink { [weak self] networkStatus in
                guard let self, networkStatus == .available else {
                    return
                }
                Task {
                    await self.retryPendingOrders()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Usecase execution
extension DefaultMenuListViewModel {
    private func getMenuItems() async {
        do {
            self.state = .fetchingData(isInitial: true)
            let response = try await self.getMenuUseCase.execute()
            self.prepareDatasource(using: response)
            self.state = .dataFetched
        } catch let error as NetworkError {
            self.state = .error
            self.showAlert(title: error.title, message: error.message)
        } catch {
            self.state = .error
        }
    }
    
    private func createOrder(orderItem: CreateOrderItem) async {
        do {
            try await self.createOrderUseCase.execute(using: orderItem)
            self.showAlert(title: "Order Success", message: "Your order has been placed!")
        } catch let error as OrderModuleUsecaseError {
            self.showAlert(title: error.title, message: error.message)
        } catch {}
    }
    
    private func retryPendingOrders() async {
        do {
            try await self.retryPendingOrdersUsecase.execute()
            self.showAlert(title: "Order Retry Success", message: "We have sent your previously failed order!")
        } catch let error as NetworkError {
            self.showAlert(title: error.title, message: error.message)
        } catch {}
    }
}

// MARK: - Output
extension DefaultMenuListViewModel {
    private func showAlert(title: String, message: String) {
        let alert = AlertData(
            title: title,
            message: message,
            button: (text: "Okay", action: { })
        )
        self.alertData = alert
    }
    
    private func prepareDatasource(using response: MenuResponse) {
        guard let menuItems = response.menu else { return }
        
        self.datasource = menuItems.compactMap { menuItem in
            let onOrderItemCreated: (CreateOrderItem) -> Void = { [weak self] orderItem in
                guard let self else { return }
                Task {
                    await self.createOrder(orderItem: orderItem)
                }
            }
            
            let onShowMenuModifierBottomSheet: () -> Void = { [weak self] in
                guard let self = self else { return }
                self.navigationDelegate?
                    .showMenuModifierBottomsheet(
                        for: menuItem,
                        onOrderItemCreated: onOrderItemCreated
                    )
            }

            let vm = DefaultMenuListCellViewModel(
                menuItem: menuItem,
                onShowMenuModifierBottomSheet: onShowMenuModifierBottomSheet
            )
            
            return .mainMenu(
                vm: vm
            )
        }
    }
}
