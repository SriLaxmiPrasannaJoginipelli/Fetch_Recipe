//
//  FileManager.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 5/31/25.
//

import Foundation

extension FileManager {
    func fileSize(atPath path: String) -> Int64 {
        do {
            let attributes = try attributesOfItem(atPath: path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
    
    func directorySize(atPath path: String) -> Int64 {
        var size: Int64 = 0
        do {
            let contents = try contentsOfDirectory(atPath: path)
            for file in contents {
                let filePath = (path as NSString).appendingPathComponent(file)
                size += fileSize(atPath: filePath)
            }
        } catch {
            return 0
        }
        return size
    }
}
