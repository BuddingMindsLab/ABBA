//
//  CSVWriter.swift
//  Card Match Game
//
//  Created by Budding Minds Admin on 2018-02-25.
//  Copyright © 2018 Budding Minds Admin. All rights reserved.
//

import Foundation

// OutputStream extension from community wiki
extension OutputStream {
    func write(_ string: String, encoding: String.Encoding = .utf8, allowLossyConversion: Bool = false) -> Int {
        if let data = string.data(using: encoding, allowLossyConversion: allowLossyConversion) {
            return data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Int in
                var pointer = bytes
                var bytesRemaining = data.count
                var totalBytesWritten = 0
                
                while bytesRemaining > 0 {
                    let bytesWritten = self.write(pointer, maxLength: bytesRemaining)
                    if bytesWritten < 0 {
                        return -1
                    }
                    
                    bytesRemaining -= bytesWritten
                    pointer += bytesWritten
                    totalBytesWritten += bytesWritten
                }
                
                return totalBytesWritten
            }
        }
        
        return -1
    }
}

var version = -1

class CSVWriter {
    var writtenHeader = false
    
    // Function that gets the default documents directory where we save files
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Write the header
    func writeHeader() {
        let header = "Exp Name,Group ID,Subject #,Block ID,Layout ID,Trial #,Goal Location,Goal Obj,Rep #,Touch Location,Touch Obj,Touch Time,Accuracy,Block Start/End Time\n"
        
        // This prints the path to the directory where the files are found
        //        #if arch(i386) || arch(x86_64)
        //            if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
        //                print("Documents Directory: \(documentsPath)")
        //            }
        //        #endif
        
        writeHelper(str: header, app: false)
    }
    
    // Function to write a single line of the csv file, takes in a list of the elements to write
    func writeLine(elements: [String]) {
        if !writtenHeader && !unpausing {
            let latestVer = getLatestVersion()
            
            if latestVer == -1 {
                version = 1
            } else {
                version = latestVer + 1
            }
            
            writtenHeader = true
            writeHeader()
        } else if !writtenHeader && unpausing {
            version = getLatestVersion()
        }
        
        var line = ""
        
        for i in 0...(elements.count - 1) {
            if i == (elements.count - 1) {
                line += "\(elements[i])\n"
            } else {
                line += "\(elements[i]),"
            }
        }
        
        writeHelper(str: line, app: true)
    }
    
    // Helper method to reduce amount of code inside other functions, actually writes the given str to the file
    func writeHelper(str: String, app: Bool) {
        let name = "\(experimentName)-\(participantId)-\(version).csv"
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
    
    // Gets that latest (highest) version of file with same experiment name and participant id
    // Filenames look like "experiment name-participant id-version.csv"
    func getLatestVersion() -> Int {
        let fm = FileManager.default
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        var version = -1
        do {
            let items = try fm.contentsOfDirectory(atPath: path)
            
            for item in items {
                if item.hasPrefix("\(experimentName)-\(participantId)") {
                    if item.contains("-") {
                        let splitHyph = item.split(separator: "-")
                        let splitVersion = splitHyph[splitHyph.count-1].split(separator: ".")
                        let v = Int(splitVersion[0])
                        
                        if  v! > version {
                            version = v!
                        }
                    } else {
                        version = 1
                    }
                }
            }
        } catch {
            print("Error - Failed to read directory")
        }
        return version
    }
}

