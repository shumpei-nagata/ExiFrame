//
//  ExifImage.swift
//  ExiFrame
//
//  Created by Shumpei Nagata on 2023/07/20.
//

import SwiftUI

struct ExifImage: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    
    private let margin = CGFloat(16)
    
    var body: some View {
        Group {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.bottom, margin)
                Group {
                    HStack {
                        Text(cameraMaker)
                        Text(cameraModel)
                    }
                    Text(lensModel)
                }
                HStack {
                    Text(focalLength)
                    Text(fNumber)
                    Text(shutterSpeed)
                    Text(iso)
                }
            }
            .foregroundColor(.init(uiColor: .systemBackground))
            .padding(margin)
        }
        .background(Color.white)
    }
}

private extension ExifImage {
    var image: UIImage {
        viewModel.exif?.imageData.flatMap(UIImage.init(data:)) ?? .filled()
    }

    var cameraMaker: String {
        viewModel.exif?.cameraMaker ?? "Unknown Maker"
    }
    
    var cameraModel: String {
        viewModel.exif?.cameraModel ?? "Unknown Camera"
    }
    
    var lensModel: String {
        viewModel.exif?.lensModel ?? "Unknown Lens"
    }
    
    var focalLength: String {
        let focalLength = {
            if viewModel.showFocalLengthIn35mmFilm {
                return viewModel.exif?.focalLengthIn35mmFilm ?? .zero
            } else {
                return viewModel.exif?.focalLength ?? .zero
            }
        }()
        return "\(focalLength)mm"
    }
    
    var fNumber: String {
        "f/" + .init(format: "%.1f", viewModel.exif?.fNumber ?? .zero)
    }
    
    var shutterSpeed: String {
        "\(viewModel.exif?.exposureTime?.fractionalExpression ?? "0")s"
    }
    
    var iso: String {
        "ISO\(viewModel.exif?.iso ?? .zero)"
    }
}

struct ExifImage_Previews: PreviewProvider {
    static var previews: some View {
        ExifImage()
            .environmentObject(ContentViewModel())
            .previewLayout(.fixed(
                width: 375,
                height: 375
            ))
    }
}

extension UIImage {
    static func filled(with color: UIColor = .black) -> UIImage {
        let rect = CGRect(
            origin: .zero,
            size: .init(width: 1, height: 1)
        )
        return UIGraphicsImageRenderer(size: rect.size)
            .image {
                $0.cgContext.setFillColor(color.cgColor)
                $0.fill(rect)
            }
    }
}
