//
//  FileManager.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 15.03.2021.
//

import Foundation

protocol FileUtilsManagerProtocol {
  func save(data: Data?, fileName: String) -> Bool
  func read(fileName: String) -> Data?
}

class FileUtils: FileUtilsManagerProtocol {
    
    func save(data: Data?, fileName: String) -> Bool {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try data?.write(to: url)
            Logger.log("saved \(fileName) with success")
            return true
        } catch {
            Logger.log("error occured while saving \(fileName) with data \(String(describing: data))")
            return false
        }
    }
    
    func read(fileName: String) -> Data? {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        let data = try? Data(contentsOf: url)
        
        return data
    }
    
    func fileExist(fileName: String) -> Bool {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
}
