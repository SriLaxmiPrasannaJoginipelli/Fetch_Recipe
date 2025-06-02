//
//  Utility.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 6/2/25.
//

import Foundation
import SwiftUI

func makeValidImageData() -> Data {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 20, height: 20))
    let image = renderer.image { ctx in
        UIColor.red.setFill()
        ctx.fill(CGRect(x: 0, y: 0, width: 20, height: 20))
    }
    return image.pngData()!
}
