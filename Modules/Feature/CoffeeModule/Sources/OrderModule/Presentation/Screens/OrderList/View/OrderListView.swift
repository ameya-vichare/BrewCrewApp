//
//  SwiftUIView.swift
//  CoffeeModule
//
//  Created by Ameya on 13/09/25.
//

import SwiftUI
import AppCore
import Persistence
import NetworkMonitoring
import Combine

public struct OrderListView: View {
    @ObservedObject var viewModel: DefaultOrderListViewModel

    public init(viewModel: DefaultOrderListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        let _ = print("Rerender OrderListView")
        let _ = Self._printChanges()
        ZStack {
            AppColors.secondaryGray
            
            List(self.viewModel.datasource) { item in
                cell(for: item)
                    .listRowSeparator(.hidden)
                    .listRowBackground(AppColors.clear)
                    .listRowInsets(EdgeInsets(top: AppPointSystem.point_12, leading: AppPointSystem.point_16, bottom: AppPointSystem.point_12, trailing: AppPointSystem.point_16))
                    .onAppear {
                        if let cellIndex = self.viewModel.datasource.firstIndex { $0.id == item.id },
                            cellIndex >= self.viewModel.datasource.count - 3 {
                            Task {
                                await self.viewModel.loadNextPage()
                            }
                        }
                    }
            }
            .listStyle(.plain)
            .background(AppColors.clear)
            .task {
                if self.viewModel.state != .dataFetched {
                    await self.viewModel.viewDidLoad()
                }
            }
            .refreshable {
                await self.viewModel.didRefresh()
            }
            .alert(item: $viewModel.alertData, content: { alertData in
                Alert(
                    title: Text(alertData.title),
                    message: Text(alertData.message),
                    dismissButton: .default(
                        Text(alertData.button.text),
                        action: alertData.button.action
                    )
                )
            })
            
            handleState(state: viewModel.state)
        }
        .navigationTitle("Orders")
        .accessibilityIdentifier("OrderListView")
    }
    
    @ViewBuilder
    private func cell(for type: OrderListCellType) -> some View {
        switch type {
        case .coffeeOrder(let viewModel):
            OrderCellView(viewModel: viewModel)
        }
    }
    
    @ViewBuilder
    private func handleState(state: ScreenViewState) -> some View {
        switch state {
        case .preparing, .dataFetched, .error:
            EmptyView()
        case .fetchingData(let isInitial):
            if isInitial {
                ProgressView("Loading orders ...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.thinMaterial)
            }
        }
    }
}

#Preview {
    NavigationStack {
        OrderListView(
            viewModel: DefaultOrderListViewModel(
                getOrdersUseCase: GetOrdersUseCase(
                    repository: OrderModuleClientRepository(
                        remoteAPI: FakeOrderModuleRemoteAPI(),
                        dataStore: FakeOrderModuleDataStore()
                    )
                ),
                navigationDelegate: nil
            )
        )
    }
}
