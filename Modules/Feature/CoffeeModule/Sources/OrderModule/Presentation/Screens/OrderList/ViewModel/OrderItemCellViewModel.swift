//
//  OrderItemCellViewModel.swift
//  CoffeeModule
//
//  Created by Ameya on 11/11/25.
//

import Foundation
import AppCore

// View model for order's items
struct OrderItemCellViewModel {
    let name: String
    let customisation: String
    let imageURL: URL?
    let displayPriceLabel: String
    let displayQuantityLabel: String
    
    init(
        item: OrderItem
    ) {
        self.name = item.name ?? ""
        self.customisation = item.modifier
            .compactMap { $0.name }.joined(separator: ", ")
        self.imageURL = URL(string: item.imageURL ?? "")
        
        if let totalPrice = item.totalPrice, let currency = item.currency {
            self.displayPriceLabel = "\(currency) \(totalPrice)"
        } else {
            self.displayPriceLabel = ""
        }
        
        if let quantity = item.quantity {
            self.displayQuantityLabel = "x\(quantity)"
        } else {
            self.displayQuantityLabel = ""
        }
    }
}
