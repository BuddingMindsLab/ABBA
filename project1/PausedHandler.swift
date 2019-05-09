//
//  PausedHandler.swift
//  Card Match Game
//
//  Created by Budding Minds Admin on 2018-02-25.
//  Copyright © 2018 Budding Minds Admin. All rights reserved.
//

import Foundation

class PausedHandler {
    
    var pausedIDs = [String]()
    var csvWriter = CSVWriter()
    
    // Function that gets the default documents directory where we save files
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Function that reads in the IDs of all currently paused participants
    func readInPausedIDs() {
        do {
            let fileURL = getDocumentsDirectory().appendingPathComponent("paused.txt")
            
            let savedText = try String(contentsOf: fileURL)
            pausedIDs = savedText.components(separatedBy: "\n")
        } catch {
            print("Could not read in paused IDs, check to see if paused.txt exists!")
        }
    }
    
    // Determine whether the current ID and version is paused
    func checkPaused(id: String) -> Bool {
        readInPausedIDs()
        
        return pausedIDs.contains("\(experimentName)-\(id)-\(csvWriter.getLatestVersion())")
    }
    
    // Add the current id and version to the paused list
    func writePaused(id: String) {
        writeHelper(str: "\(experimentName)-\(id)-\(version)\n", app: true)
    }
    
    // Remove the current id from the paused list
    func removePaused(id: String) {
        readInPausedIDs()
        
        let rem = "\(experimentName)-\(id)"
        
        pausedIDs.remove(at: pausedIDs.index(of: rem)!)
        
        let upperBound = (((pausedIDs.count - 1) >= 0) ? (pausedIDs.count - 1) : 0)
        print(upperBound)
        
        for i in 0...upperBound {
            if i == 0 {
                writeHelper(str: "\(pausedIDs[i])\n", app: false)
            } else {
                writeHelper(str: "\(pausedIDs[i])\n", app: true)
            }
        }
    }
    
    // Helper method to reduce amount of code inside other functions, actually writes the given str to the file
    func writeHelper(str: String, app: Bool) {
        let name = "paused.txt"
        let path = getDocumentsDirectory().appendingPathComponent(name)
        
        if let outputStream = OutputStream(url: path, append: app) {
            outputStream.open()
            let bytesWritten = outputStream.write(str)
            if bytesWritten < 0 { print("Write failure") }
            outputStream.close()
        } else {
            print("Unable to open file")
        }
    }
}

