//
//  OrderListViewModel.swift
//  CoffeeModule
//
//  Created by Ameya on 13/09/25.
//

import SwiftUI
import AppCore
import Networking
import Combine

public protocol OrderListNavigationDelegate {
    func navigateToOrderDetail(orderID: String)
}

protocol OrderListViewModelOutput {
    var datasource: [OrderListCellType] { get }
    var state: ScreenViewState { get }
    var alertData: AlertData? { get }
}

protocol OrderListViewModelInput {
    func viewDidLoad() async
    func didRefresh() async
    func loadNextPage() async
}

typealias OrderListViewModel = OrderListViewModelInput & OrderListViewModelOutput

@MainActor
public final class DefaultOrderListViewModel: ObservableObject, OrderListViewModel {
    let getOrdersUseCase: GetOrdersUseCaseProtocol
    let navigationDelegate: OrderListNavigationDelegate?
    
    // MARK: - Output
    @Published var datasource: [OrderListCellType] = []
    @Published var state: ScreenViewState = .preparing
    @Published var alertData: AlertData?
    
    // MARK: - Private
    private var pageData: OrderPagination?
    
    // MARK: - Init
    public init(
        getOrdersUseCase: GetOrdersUseCaseProtocol,
        navigationDelegate: OrderListNavigationDelegate?
    ) {
        self.getOrdersUseCase = getOrdersUseCase
        self.navigationDelegate = navigationDelegate
    }
}

// MARK: - Actions
extension DefaultOrderListViewModel {
    func viewDidLoad() async {
        await self.getOrders()
    }
    
    func didRefresh() async {
        self.resetData()
        await self.getOrders()
    }
    
    func loadNextPage() async {
        guard shouldLoadNextPage() else { return }
        await self.getOrders()
    }
}

// MARK: - Private
extension DefaultOrderListViewModel {
    private func getOrders() async {
        self.state = .fetchingData(isInitial: pageData == nil ? true : false)

        do {
            let orderResponse = try await self.getOrdersUseCase.execute(using: pageData)
            self.prepareDatasource(orders: orderResponse.orders)
            self.preparePaginationData(pagination: orderResponse.pagination)
            self.state = .dataFetched
        } catch let error as NetworkError {
            self.state = .error
            self.showAlert(title: error.title, message: error.message)
        } catch {
            self.state = .error
        }
    }
    
    private func prepareDatasource(orders: [Order]?) {
        guard let orders else { return }
        
        let orderCells: [OrderListCellType] = orders.compactMap { order in
            guard let orderID = order.id,
                  !orderID.isEmpty else {
                return nil
            }
            
            func getItemsVM(items: [OrderItem]) -> [OrderItemCellViewModel] {
                items.map { OrderItemCellViewModel(item: $0) }
            }
            
            func getOrderVM(order: Order, itemsVM: [OrderItemCellViewModel]) -> OrderCellViewModel {
                let onNavigateToOrderDetail: (String) -> Void = { [weak self] orderId in
                    guard let self else { return }
                    self.navigationDelegate?.navigateToOrderDetail(orderID: orderId)
                }
                
                return DefaultOrderCellViewModel(
                    order: order,
                    itemsViewModel: itemsVM,
                    onNavigateToOrderDetail: onNavigateToOrderDetail
                )
            }

            return OrderListCellType.coffeeOrder(
                vm: getOrderVM(
                    order: order,
                    itemsVM: getItemsVM(items: order.items)
                )
            )
        }
        
        self.datasource.append(contentsOf: orderCells)
    }
    
    private func preparePaginationData(pagination: OrderPagination?) {
        guard let pagination else { return }
        self.pageData = pagination
    }
    
    private func shouldLoadNextPage() -> Bool {
        guard let hasMore = pageData?.hasMore
        else {
            return false
        }
        
        return hasMore && state == .dataFetched
    }
    
    private func resetData() {
        self.datasource = []
        self.pageData = nil
    }
    
    private func showAlert(title: String, message: String) {
        self.alertData = AlertData(
            title: title,
            message: message,
            button: (text: "Okay", action: {})
        )
    }
}
