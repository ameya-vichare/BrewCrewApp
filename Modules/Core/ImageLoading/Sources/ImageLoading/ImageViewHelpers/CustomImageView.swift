//
//  CustomImageView.swift
//  ImageLoading
//
//  Created by Ameya on 18/10/25.
//

import SwiftUI

public struct CustomImageView<Placeholder: View>: View {
    private let url: URL?
    private let preferredSize: CGSize
    private let placeholder: () -> Placeholder
    @StateObject private var loader: SwiftUIImageLoader
    
    public init(
        url: URL?,
        targetSize: CGSize,
        imageService: ImageService,
        placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.preferredSize = targetSize
        self.placeholder = placeholder
        self._loader = StateObject(wrappedValue: SwiftUIImageLoader(imageService: imageService))
    }
    
    public var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                placeholder()
            }
        }
        .id(url)
        .task(id: url) {
            if let url = url {
                do {
                    try await loader.loadImage(with: url, preferredSize: preferredSize)
                } catch {}
            }
        }
    }
}
