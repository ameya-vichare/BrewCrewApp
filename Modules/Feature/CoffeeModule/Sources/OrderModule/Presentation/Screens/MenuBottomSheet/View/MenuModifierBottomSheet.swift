//
//  MenuModifierBottomSheet.swift
//  CoffeeModule
//
//  Created by Ameya on 25/10/25.
//

import SwiftUI
import ImageLoading
import AppCore
import Combine

public struct MenuModifierBottomSheet: View {
    @ObservedObject private var viewModel: DefaultMenuModifierBottomSheetViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: DefaultMenuModifierBottomSheetViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            MenuModifierHeaderView(
                viewModel: viewModel.headerViewModel
            )
            
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(self.viewModel.modifierViewModels) { viewModel in
                        MenuModifierCellView(viewModel: viewModel)
                    }
                }
            }
            .padding()
            
            Spacer()
            
            MenuModifierFooterView(
                viewModel: viewModel.footerViewModel
            )
        }
        .background(AppColors.secondaryGray)
        .onReceive(
            viewModel.$shouldDismissBottomSheet.receive(on: DispatchQueue.main)
        ) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
}

struct MenuModifierCellView: View {
    @ObservedObject private var viewModel: MenuModifierCategoryCellViewModel
    
    init(viewModel: MenuModifierCategoryCellViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(
                cornerRadius: AppPointSystem.point_12
            )
                .foregroundStyle(AppColors.white)
                .padding([.bottom], AppPointSystem.point_12)
            
            VStack(alignment: .leading) {
                Text(viewModel.name)
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.black)
                
                Text(viewModel.displayDescription)
                    .font(AppFonts.subHeadline)
                    .foregroundStyle(AppColors.primaryGray)
                
                Divider()
                    .padding([.bottom], 10)
                
                ForEach(viewModel.options) { viewModel in
                    MenuModifierSelectionView(viewModel: viewModel)
                }
            }
            .padding()
        }
    }
}

struct MenuModifierSelectionView: View {
    @ObservedObject private var viewModel: DefaultMenuModifierSelectionCellViewModel
    
    init(viewModel: DefaultMenuModifierSelectionCellViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Text(viewModel.name)
                .font(viewModel.isSelected ? AppFonts.subHeadlineMedium : AppFonts.subHeadline)
                .foregroundStyle(AppColors.black)

            Spacer()
            
            Text("\(viewModel.currency) \(viewModel.displayPrice)")
                .font(viewModel.isSelected ? AppFonts.subHeadlineMedium : AppFonts.subHeadline)
                .foregroundStyle(AppColors.black)
            
            Image(systemName: viewModel.isSelected ? "record.circle" : "circle")
                .foregroundStyle(
                    AppColors.primaryCoffee
                )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.toggleSelection()
        }
        .padding([.bottom], 10)
    }
}

struct MenuModifierHeaderView: View {
    @Environment(\.imageService) private var imageService
    
    private var viewModel: MenuModifierBottomSheetHeaderViewModel
    
    init(viewModel: MenuModifierBottomSheetHeaderViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: AppPointSystem.point_80)
                .foregroundStyle(AppColors.white)
                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 4)
            
            HStack(spacing: AppPointSystem.point_12) {
                CustomImageView(
                    url: viewModel.imageURL,
                    targetSize: CGSize(width: AppPointSystem.point_60, height: AppPointSystem.point_60),
                    imageService: imageService) {
                        ProgressView()
                    }
                    .frame(width: AppPointSystem.point_60, height: AppPointSystem.point_60)
                    .clipShape(
                        RoundedRectangle(cornerRadius: AppPointSystem.point_12)
                    )
                
                Text(viewModel.name)
                    .font(AppFonts.title3Medium)
                
                Spacer()
            }
            .padding([.leading, .trailing], 12)
        }
    }
    
}

struct MenuModifierFooterView: View {
    @ObservedObject private var viewModel: DefaultMenuModifierBottomSheetFooterViewModel
    
    init(viewModel: DefaultMenuModifierBottomSheetFooterViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: AppPointSystem.point_80)
                .foregroundStyle(AppColors.white)
            
            HStack(alignment: .center, spacing: AppPointSystem.point_4) {
                MenuStepperButton(viewModel: viewModel)
                
                Spacer()
                
                MenuAddToCartButton(viewModel: viewModel)
            }
            .padding()
        }
    }
}

struct MenuAddToCartButton: View {
    @ObservedObject private var viewModel: DefaultMenuModifierBottomSheetFooterViewModel
    
    init(viewModel: DefaultMenuModifierBottomSheetFooterViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Button {
            viewModel.addItemPressed()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: AppPointSystem.point_12)
                    .frame(height: AppPointSystem.point_44)
                    .foregroundStyle(AppColors.primaryCoffee)
                
                Text(
                    "Add item - \(viewModel.currency) \(viewModel.totalPrice.formatPrice())"
                )
                .font(AppFonts.mediumSixteen)
                    .foregroundStyle(AppColors.white)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MenuModifierBottomSheet(
        viewModel: DefaultMenuModifierBottomSheetViewModel(
            menuItem: MenuItem.createFake(),
            onOrderItemCreated: { _ in },
            priceComputeUseCase: MenuModifierBottomSheetPriceComputeUsecase(),
            createOrderUseCase: MenuModifierBottomSheetCreateOrderUseCase()
        )
    )
}
