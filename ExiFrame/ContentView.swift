//
//  ContentView.swift
//  ExiFrame
//
//  Created by Shumpei Nagata on 2023/07/19.
//

import Combine
import PhotosUI
import SwiftUI

struct ExifData {
    let imageData: Data?
    let cameraMaker: String?
    let cameraModel: String?
    let lensModel: String?
    let focalLength: Int?
    let focalLengthIn35mmFilm: Int?
    let fNumber: Double?
    let exposureTime: Fraction?
    let iso: Int?
}

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var pickedPhoto: PhotosPickerItem?
    @Published var showFocalLengthIn35mmFilm = false
    
    @Published private(set) var exif: ExifData?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $pickedPhoto
            .receive(on: DispatchQueue.main)
            .sink { _ in
                Task { @MainActor in
                    await self.parse()
                }
            }
            .store(in: &cancellables)
    }
    
    private func parse() async {
        guard
            let imageData = try? await pickedPhoto?.loadTransferable(type: Data.self),
            let parser = ImageMetadataParser(data: imageData)
        else {
            return
        }
        exif = .init(
            imageData: imageData,
            cameraMaker: parser.parse(for: \.cameraMaker),
            cameraModel: parser.parse(for: \.cameraModel),
            lensModel: parser.parse(for: \.lensModel),
            focalLength: parser.parse(for: \.focalLength),
            focalLengthIn35mmFilm: parser.parse(for: \.focalLengthIn35mmFilm),
            fNumber: parser.parse(for: \.fNumber),
            exposureTime: parser.parse(for: \.exposureTime).map(Fraction.init(number:)),
            iso: parser.parse(for: \.isoSpeedRatings)?.first
        )
    }
    
    deinit {
        cancellables.forEach {
            $0.cancel()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @Environment(\.displayScale) private var displayScale
    
    private let maxWidth = UIScreen.main.bounds.width
    
    private var exifImage: ExifImage {
        .init(
            exif: viewModel.exif,
            showFocalLengthIn35mmFilm: viewModel.showFocalLengthIn35mmFilm
        )
    }

    var body: some View {
        VStack {
            exifImage
            
            PhotosPicker(
                selection: $viewModel.pickedPhoto,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Select a photo")
            }
            
            Toggle(
                "35mm換算する",
                isOn: $viewModel.showFocalLengthIn35mmFilm
            )
            if let image = exifImage
                .frame(width: maxWidth)
                .snapshot(scale: displayScale)
                .map(Image.init(uiImage:)) {
                ShareLink(
                    "画像をシェアする",
                    item: image,
                    preview: .init(
                        "Share ExiFrame Image",
                        image: image
                    )
                )
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    @MainActor
    func snapshot(scale: CGFloat) -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = scale
        return renderer.uiImage
    }
}
