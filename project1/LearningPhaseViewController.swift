//
//  ViewController.swift
//  project1
//
//  Created by Sakshaat Choyikandi on 2018-07-09.
//  Copyright © 2018 The Budding Minds Lab. All rights reserved.
//

import UIKit

class LearningPhaseViewController: UIViewController {
    var curr = 0;
    var dataIndex = 0;
    
    var imageArray:[UIImage] = [];
    var startTime: DispatchTime? = nil;
    var reader: CSVReader? = nil;
    var subject: String = "";
    var age: String = "";
    var file_name = ""
    var times: String = "Tap times\n";
    var sequence: [String] = [];
    var elapsedTimes = [String]()
    let slides = ["Slide1", "Slide2", "Slide3", "Slide4", "Slide5", "Slide6"]
    var delay = 0.5

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet var myImageView: UIImageView!
    
    func loadImages(files: [String]) {
        for var file in files {
            file = file.trimmingCharacters(in: .whitespacesAndNewlines);
            //imageArray.append(resizeImage(img: UIImage(named: file)!));
            imageArray.append(UIImage(named: file)!);
        }
    }

    func startExperiment() {
        
        // append times data after subject number and age
        times = subject + age
        
        // set output data file name
        subject = String(subject.dropFirst(12))
        subject = String(subject.dropLast())
        file_name = subject + ".csv"
        let cb_number = String(Int(subject)!%3 + 1)
        times += "," + "CB" + cb_number
        
        myImageView.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        // Readers
        reader = CSVReader();
        let press_sequence = reader!.getPresSeq(fileName: "CB" + cb_number)
        loadImages(files: press_sequence);
        sequence.append(contentsOf: press_sequence)

        // Recognize gesture
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LearningPhaseViewController.imageTapped));
        view.addGestureRecognizer(tapGestureRecognizer);

//        uncomment to see what <sequence> is and its length
//        print(sequence)
//        print("number of items is")
//        print(sequence.count)
        // Display the first image
        showImage()
    }
    
    func showImage() {
        //Idea: look at the current element in sequence array with curr as index
        if curr >= sequence.count {
            trialFinished()
        } else {
            if sequence[curr] == "attn" || slides.contains(sequence[curr]) {
                view.isUserInteractionEnabled = true
                nextImage()
            } else {
                view.isUserInteractionEnabled = false
                nextImage()
                
                if curr < sequence.count {
                    perform(#selector(nextShape), with: nil, afterDelay: delay)
                }

            }
        }
    }
    
    func nextImage() {
//        for v in view.subviews {
//            v.removeFromSuperview()
//        }
        startTime = DispatchTime.now();
        if curr == imageArray.count {
            // Trial done
            trialFinished();
        } else {
            myImageView.contentMode = UIViewContentMode.center
            if (myImageView.bounds.size.width > (imageArray[curr].size.width) && myImageView.bounds.size.height > (imageArray[curr].size.height)){
                myImageView.contentMode = UIViewContentMode.scaleAspectFit;
            }
            //nextImage();
            //print("line 107")
            print(sequence[curr])
//            print(imageArray[curr].size)
//
            myImageView.image = imageArray[curr];
//            let img = UIImageView(image: myImageView.image!)
//            img.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
//            view.addSubview(img)
            
            curr = curr + 1;
        }
    }
    
    func elapsedTimeSinceLastStart() -> Double {
        let endTime = DispatchTime.now();
        let nanoTime = endTime.uptimeNanoseconds - (self.startTime!.uptimeNanoseconds)
        
        // converting to ms
        return (Double(nanoTime) / 1000000)
    }
    
    override func viewDidLoad() {
        self.navigationItem.setHidesBackButton(true, animated: false);
    }

    override func viewWillAppear(_ animated: Bool) {
        startExperiment();
    }
    
    @objc func imageTapped() {
        // Here you can write to csv
        
        //let lst = 1...277
        if curr >= 1 && curr <= sequence.count-5 {
            if (curr-1) % 3 == 0 {
                times += "\n"
                let subsequence = sequence[curr-1...curr+1]
                let subsequence_string = subsequence.joined(separator: ",")
                times += subsequence_string + ","
            }
            if sequence[curr] == "attn" {
                times += String(elapsedTimeSinceLastStart())    // when does it start?
            } else {
                times += "500"
            }
            
            // record tap time on the go
            
            let this_file = getDocumentsDirectory().appendingPathComponent(file_name)
            
            do{
                try times.write(to: this_file, atomically: true, encoding: String.Encoding.utf8)
                print("file written")
            } catch {
                print("Failed to write")
            }
            
            times += ","
            
        } else if curr == sequence.count-3 {
            sleep(3)
        }
        
        // Update the time
        startTime = DispatchTime.now();
        //nextImage();
        showImage()
    }
    
    @objc func nextShape() {
        //let lst = 1...277
        if curr >= 1 && curr <= sequence.count-5 {
            if (curr-1) % 3 == 0 {
                times += "\n"
                let subsequence = sequence[curr-1...curr+1]
                let subsequence_string = subsequence.joined(separator: ",")
                times += subsequence_string + ","
            }
            if sequence[curr] == "attn" {
                times += String(elapsedTimeSinceLastStart())    // when does it start?
            } else {
                times += "500"
            }

            // record tap time on the go

            let this_file = getDocumentsDirectory().appendingPathComponent(file_name)

            do{
                try times.write(to: this_file, atomically: true, encoding: String.Encoding.utf8)
                print("file written")
            } catch {
                print("Failed to write")
            }

            times += ","

        } else if curr == sequence.count-3 {
            sleep(3)
        }

        // Update the time
        startTime = DispatchTime.now();
        //nextImage();
        showImage()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    func resizeImage(img: UIImage) -> UIImage {
        let heightSize = screenHeight;
        let widthSize = screenWidth;
        let size = img.size;
        let heightR = heightSize / size.height;
        let widthR = widthSize / size.width;
        let newSize = CGSize(width: size.width * heightR, height: size.height * widthR);
        //let newSize = CGSize(width: size.width, height: size.height);
        let rect = CGRect(x: 0, y: 0, width: widthSize, height: heightSize);
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0);
        img.draw(in: rect);
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return newImage!;
    }
    
    func setSubject(subj : String) {
        self.subject = subj
    }
    
    func setAge(age : String) {
        self.age = age
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
    func trialFinished() {
        print("trial finished")
        
        
        performSegue(withIdentifier: "testSegue", sender: self);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC: TestingPhaseViewController = segue.destination as! TestingPhaseViewController
        destVC.subject = subject
        destVC.age = age
        destVC.times = times.dropLast() + "\n"
    }
}

