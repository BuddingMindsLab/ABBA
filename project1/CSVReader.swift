//
//  CSVReader.swift
//  project1
//
//  Created by Sakshaat Choyikandi on 2018-08-01.
//  Copyright © 2018 The Budding Minds Lab. All rights reserved.
//

import Foundation

class CSVReader {
    func getPresSeq(fileName: String) -> [String] {
        return cleanPicArray(array: readSeqFile(fileName: fileName)).flatMap({$0});
    }
    
    func getTestSeq() -> [[String]] {
        return cleanPicArray(array: readTestFile());
    }
    
    func cleanPicArray(array:[String]) -> [[String]] {
        return array.map{$0.components(separatedBy: ",")};
    }
    
    func readFile(file:String, shuffle:Bool) -> [String] {
        if let file = Bundle.main.url(forResource:file, withExtension: "csv") {
            do {
                var contents = (try String(contentsOf: file)).components(separatedBy: .newlines)
                // contents has form ["hit_1,shapea,shapei,shaped",..., "foil_2,shapeg,shapen,shaped"]
                // randomize the array here for each new subject
                if shuffle == true {
                    // this only applies to testing phase
                    var temp_contents = ["practice1,1,A,B,C,nil,nil", "practice2,2,E,A,I,nil,nil"]
                    contents.shuffle()
                    for cont in contents {
                        temp_contents.append(cont)
                    }
                    contents = temp_contents
                }
                contents = contents.filter({ $0 != ""});
                return contents;
            } catch {}
        } else {
            // example.txt not found!
        }
        
        return []
    }
    
    func readTestFile() -> [String] {
        return readFile(file: "ipad_test_v4", shuffle: true);
    }
    
    func readSeqFile(fileName: String) -> [String] {
        return readFile(file: fileName, shuffle: false);

    }
}
