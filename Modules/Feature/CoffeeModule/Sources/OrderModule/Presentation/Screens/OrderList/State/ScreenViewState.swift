//
//  CoffeeListViewState.swift
//  CoffeeModule
//
//  Created by Ameya on 24/10/25.
//

enum ScreenViewState: Equatable {
    case preparing
    case fetchingData(isInitial: Bool)
    case dataFetched
    case error
}
