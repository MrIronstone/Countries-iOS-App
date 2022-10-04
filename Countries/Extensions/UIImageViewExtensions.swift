//
//  UIImageViewExtensions.swift
//  Countries
//
//  Created by admin on 4.10.2022.
//

import Foundation
import UIKit
import SVGKit

extension UIImageView {
    func downloadedsvg(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let receivedicon: SVGKImage = SVGKImage(data: data),
                let image = receivedicon.uiImage
            else {
                self.downloadedsvg(from: url)
                return
            }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
}
