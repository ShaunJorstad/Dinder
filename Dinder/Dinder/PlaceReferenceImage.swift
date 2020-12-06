//
//  PlaceReferenceImage.swift
//  Dinder
//
//  Created by Luke on 12/5/20.
//

import SwiftUI
import Combine

struct PlaceReferenceImage: View {
    @ObservedObject var asyncImage: RemoteImage
    
    init(fromReference: String, width: Int, height: Int) {
        self.asyncImage = RemoteImage(from: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(width)&maxheight=\(height)&photoreference=\(fromReference)&key=AIzaSyDNvJmFkPt54ZFAqa3O0U4ZdDGaFsyB3fk")
    }
    
    var body: some View {
        if let image = asyncImage.image {
            Image(uiImage: image)
        } else {
            Text("Loading Image")
                .dinderRegularStyle()
            ProgressView()
        }
    }
}

class RemoteImage: ObservableObject {
    @Published var image: UIImage?
    
    var pipeline: AnyCancellable?
    
    init(from: String) {
        self.pipeline = getRemoteDataAsync(from: from)
            .map { UIImage(data: $0) }
            .sink(receiveCompletion: {
                print("Could not download image: \($0)")
            }, receiveValue: {
                self.image = $0
            })
    }
}

