//
//  CoffeeOrderView.swift
//  CoffeeModule
//
//  Created by Ameya on 13/09/25.
//

import SwiftUI
import AppCore
import Combine
import Persistence
import NetworkMonitoring

public struct MenuListView<ViewModel: MenuListViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @State var activeAlert: AlertData?
    @State private var cancellables = Set<AnyCancellable>()
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            AppColors.secondaryGray
            
            List(self.viewModel.datasource) { menu in
                handleCellType(type: menu)
            }
            .listStyle(.plain)
            .task {
                if viewModel.state != ScreenViewState.dataFetched {
                    await self.viewModel.viewDidLoad()
                }
            }
            
            handleState(state: viewModel.state)
        }
        .onAppear(perform: {
            viewModel.alertPublisher
                .receive(on: DispatchQueue.main)
                .sink { alertData in
                    activeAlert = alertData
                }
                .store(in: &cancellables)
        })
        .alert(item: $activeAlert, content: { alertData in
            Alert(
                title: Text(alertData.title),
                message: Text(alertData.message),
                dismissButton: .default(
                    Text(alertData.button.text),
                    action: alertData.button.action
                )
            )
        })
        .navigationTitle("Menu")
    }
    
    @ViewBuilder
    private func handleCellType(type: MenuListCellType) -> some View {
        switch type {
        case .mainMenu(vm: let viewModel):
            MenuCellView(viewModel: viewModel)
                .listCellStyle()
        }
    }
    
    @ViewBuilder
    private func handleState(state: ScreenViewState) -> some View {
        switch state {
        case .fetchingData:
            ProgressView("Getting menu ...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.thinMaterial)
        default:
            EmptyView()
        }
    }
}

#Preview {
    NavigationStack {
        let orderRepository = OrderModuleClientRepository(
            remoteAPI: FakeOrderModuleRemoteAPI(),
            dataStore: FakeOrderModuleDataStore()
        )
        let networkMonitor = FakeNetworkMonitor()
        MenuListView(
            viewModel: DefaultMenuListViewModel(
                networkMonitor: networkMonitor,
                getMenuUseCase: GetMenuUsecase(
                    repository: orderRepository
                ),
                createOrderUseCase: CreateOrderUsecase(
                    repository: orderRepository,
                    networkMonitor: networkMonitor
                ),
                retryPendingOrdersUsecase: RetryPendingOrdersUsecase(
                    repository: orderRepository
                ),
                navigationDelegate: nil
            )
        )
    }
}
