//
//  CoffeeCellView.swift
//  CoffeeModule
//
//  Created by Ameya on 13/09/25.
//

import SwiftUI
import AppCore
import ImageLoading

struct OrderCellView: View {
    private var viewModel: OrderCellViewModel
    
    init(
        viewModel: OrderCellViewModel
    ) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppPointSystem.point_20)
                .foregroundStyle(AppColors.white)
            
            VStack {
                OrderHeaderView(viewModel: viewModel)

                VStack {
                    ForEach(self.viewModel.itemsViewModel, id: \.name) { item in
                        OrderCellDetailView(viewModel: item)
                    }
                }

                Divider()
                    .background(AppColors.secondaryGray)
                    .padding([.top, .bottom], AppPointSystem.point_12)
                
                OrderTotalPriceView(displayTotalPriceLabel: viewModel.displayTotalPriceLabel)
                
                OrderUserNameView(username: viewModel.userName)
                
                OrderStatusView(statusDisplayLabel: viewModel.statusDisplayLabel)
            }
            .padding([.bottom, .top], AppPointSystem.point_12)
            .padding([.leading, .trailing], AppPointSystem.point_16)
        }
    }
}

struct OrderHeaderView: View {
    let viewModel: OrderCellViewModel
    
    init(viewModel: OrderCellViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Order #\(viewModel.id)")
                    .font(AppFonts.title2SemiBold)
                    .padding([.bottom], AppPointSystem.point_2)
                Text("\(viewModel.createdAt)")
                    .font(AppFonts.subHeadline)
                    .foregroundStyle(AppColors.primaryGray)
            }
            
            Spacer()
            
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: AppPointSystem.point_12)
                        .foregroundStyle(AppColors.secondaryGray)
                        .frame(width: AppPointSystem.point_40, height: AppPointSystem.point_40)
                    
                    Image(systemName: "message.fill")
                        .resizable()
                        .frame(width: AppPointSystem.point_20, height: AppPointSystem.point_20)
                }
                
                Button {
                    viewModel.navigateToOrderDetail()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppPointSystem.point_12)
                            .foregroundStyle(AppColors.secondaryGray)
                            .frame(width: AppPointSystem.point_40, height: AppPointSystem.point_40)
                        
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(.plain)

            }
        }
        .padding([.bottom], AppPointSystem.point_12)
    }
}

struct OrderCellDetailView: View {
    private let viewModel: OrderItemCellViewModel
    @Environment(\.imageService) private var imageService: ImageService
    
    init(viewModel: OrderItemCellViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            CustomImageView(
                url: viewModel.imageURL,
                targetSize: CGSize(
                    width: AppPointSystem.point_48,
                    height: AppPointSystem.point_48
                ),
                imageService: imageService
            ) {
                ProgressView()
            }
            .frame(width: AppPointSystem.point_48, height: AppPointSystem.point_48)
            .clipShape(RoundedRectangle(cornerRadius: AppPointSystem.point_12))
            
            VStack(alignment: .leading) {
                Text(viewModel.name)
                    .font(AppFonts.headlineMedium)
                
                Text(viewModel.customisation)
                    .font(AppFonts.captionMedium)
                    .foregroundStyle(AppColors.primaryGray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(viewModel.displayQuantityLabel)
                .font(AppFonts.subHeadline)
                .foregroundStyle(AppColors.primaryGray)
                .padding([.horizontal], AppPointSystem.point_12)
            
            Text(viewModel.displayPriceLabel)
                .font(AppFonts.subHeadline)
                .fixedSize()
        }
    }
}

struct OrderTotalPriceView: View {
    private let displayTotalPriceLabel: String
    
    init(displayTotalPriceLabel: String) {
        self.displayTotalPriceLabel = displayTotalPriceLabel
    }
    
    var body: some View {
        HStack {
            Text("Total:")
                .font(AppFonts.subHeadlineMedium)
            
            Spacer()
            
            Text(displayTotalPriceLabel)
                .font(AppFonts.subHeadlineMedium)
        }
        .padding([.bottom], AppPointSystem.point_4)
    }
}

struct OrderUserNameView: View {
    private let username: String
    
    public init(username: String) {
        self.username = username
    }
    
    var body: some View {
        HStack {
            Text("Ordered by:")
                .font(AppFonts.subHeadline)
                .foregroundStyle(AppColors.primaryGray)
            
            Text("\(username)")
                .font(AppFonts.subHeadline)
            
            Spacer()
        }
        .padding([.bottom], AppPointSystem.point_12)
    }
}

struct OrderStatusView: View {
    let statusDisplayLabel: String
    
    init(statusDisplayLabel: String) {
        self.statusDisplayLabel = statusDisplayLabel
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppPointSystem.point_60/2)
                .frame(height: AppPointSystem.point_60)
                .foregroundStyle(AppColors.secondaryGray)
            
            HStack {
                Image(systemName: "cup.and.saucer")
                
                Text(statusDisplayLabel)
            }
        }
    }
}

#Preview {
    OrderCellView(viewModel:
        DefaultOrderCellViewModel(
            order: Order.createFake(),
            itemsViewModel: [
                OrderItemCellViewModel(
                    item: OrderItem.createFake()
                )
            ],
            onNavigateToOrderDetail: { _ in }
        )
    )
}
