//
//  SwiftUIView.swift
//  CoffeeModule
//
//  Created by Ameya on 22/10/25.
//

import SwiftUI
import ImageLoading
import AppCore
import Combine

struct MenuCellView: View {
    private let viewModel: MenuListCellViewModel
    
    init(viewModel: MenuListCellViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: AppPointSystem.point_8) {
                    CoffeeMenuDetailView(viewModel: viewModel)
                    
                    Spacer()
                    
                    CoffeeMenuActionView(viewModel: viewModel)
                }
                .padding([.bottom, .top], AppPointSystem.point_12)
                .padding([.leading, .trailing], AppPointSystem.point_16)
                
            Divider()
                .background(AppColors.secondaryGray)
        }
    }
}

struct CoffeeMenuDetailView: View {
    private let viewModel: MenuListCellViewModel
    
    init(viewModel: MenuListCellViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.name)
                .font(AppFonts.headlineMedium)
                .padding([.top], 10)
            
            Text("\(viewModel.currency) \(viewModel.displayPrice)")
                .font(AppFonts.subHeadlineMedium)
                .padding([.top], 2)
            
            Text(viewModel.description)
                .font(AppFonts.captionMedium)
                .foregroundStyle(AppColors.primaryGray)
                .padding([.top], 2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct CoffeeMenuActionView: View {
    @Environment(\.imageService) private var imageService: ImageService
    private let viewModel: MenuListCellViewModel
    
    init(viewModel: MenuListCellViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            CustomImageView(
                url: viewModel.imageURL,
                targetSize: CGSize(width: AppPointSystem.point_150, height: AppPointSystem.point_150),
                imageService: imageService) {
                    ProgressView()
            }
                .frame(width: AppPointSystem.point_150, height: AppPointSystem.point_150)
                .clipShape(RoundedRectangle(cornerRadius: AppPointSystem.point_12))
                .overlay(alignment: .bottom) {
                    AddMenuButton(
                        viewModel: viewModel
                    )
                }
                .padding([.bottom], AppPointSystem.point_44/2)
        }
    }
}

#Preview {
    MenuCellView(
        viewModel: DefaultMenuListCellViewModel(
            menuItem: MenuItem.createFake(),
            onShowMenuModifierBottomSheet: {}
        )
    )
}
