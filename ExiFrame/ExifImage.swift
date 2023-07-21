//
//  ExifImage.swift
//  ExiFrame
//
//  Created by Shumpei Nagata on 2023/07/20.
//

import SwiftUI

struct ExifImage: View {
    private var exif: ExifData?
    private var showFocalLengthIn35mmFilm: Bool
    
    private let margin = CGFloat(16)
    
    init(
        exif: ExifData?,
        showFocalLengthIn35mmFilm: Bool
    ) {
        self.exif = exif
        self.showFocalLengthIn35mmFilm = showFocalLengthIn35mmFilm
    }
    
    var body: some View {
        Group {
            VStack(spacing: 4) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.bottom, margin)
                Group {
                    HStack {
                        Text(cameraMaker)
                        Text(cameraModel)
                    }
                    .foregroundColor(Color.black)
                    Text(lensModel)
                        .foregroundColor(Color.gray)
                }
                HStack {
                    Text(focalLength)
                    Text(fNumber)
                    Text(shutterSpeed)
                    Text(iso)
                }
                .foregroundColor(Color.black)
            }
            .bold()
            .padding(margin)
        }
        .background(Color.white)
    }
}

private extension ExifImage {
    var image: UIImage {
        exif?.imageData.flatMap(UIImage.init(data:)) ?? .filled()
    }

    var cameraMaker: String {
        exif?.cameraMaker ?? "Unknown Maker"
    }
    
    var cameraModel: String {
        exif?.cameraModel ?? "Unknown Camera"
    }
    
    var lensModel: String {
        exif?.lensModel ?? "Unknown Lens"
    }
    
    var focalLength: String {
        let focalLength = {
            if showFocalLengthIn35mmFilm {
                return exif?.focalLengthIn35mmFilm ?? .zero
            } else {
                return exif?.focalLength ?? .zero
            }
        }()
        return "\(focalLength)mm"
    }
    
    var fNumber: String {
        "f/" + .init(format: "%.1f", exif?.fNumber ?? .zero)
    }
    
    var shutterSpeed: String {
        "\(exif?.exposureTime?.fractionalExpression ?? "0")s"
    }
    
    var iso: String {
        "ISO\(exif?.iso ?? .zero)"
    }
}

struct ExifImage_Previews: PreviewProvider {
    static var previews: some View {
        ExifImage(exif: nil, showFocalLengthIn35mmFilm: false)
            .preferredColorScheme(.dark)
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
