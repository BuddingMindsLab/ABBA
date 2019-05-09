//
//  TestingPhaseViewController.swift
//  project1
//
//  Created by Sakshaat Choyikandi on 2018-08-10.
//  Copyright © 2018 The Budding Minds Lab. All rights reserved.
//

import UIKit
import MessageUI

class TestingPhaseViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var file_name = "";
    var subject: String = "";
    var age: String = "";
    var times: String = "";
    var responses: String = "";
    var path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Times.csv")
    
    // let
    let ISI:TimeInterval = 0;
    let DISPLAY_TIME:TimeInterval = 1;
    
    // Response time
    var startTime: DispatchTime? = nil;
    
    var imageArray:[UIImage] = [];
    var currentTest : Int? = nil;
    var currentImg = 0;
    var tests = CSVReader().getTestSeq();
    
    var shape_sequence_text:[[String]] = []
    var labels_text = [[String]]()
    var categories = [[String]]()
    
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func noButtonClicked(_ sender: Any) {
        // change this code to log a frown
        times += String(format:"Frown, %.3f", elapsedTimeSinceLastStart())+"\n";
        update_output(data: times, file: file_name)
        startNextTest();
    }
    
    @IBAction func yesButtonClicked(_ sender: Any) {
        // change this code to log a smiley
        times += String(format:"Smile, %.3f", elapsedTimeSinceLastStart())+"\n";
        update_output(data: times, file: file_name)
        startNextTest();
    }
    
    func update_output(data: String, file: String) {
        let this_file = getDocumentsDirectory().appendingPathComponent(file)
        
        do{
            try data.write(to: this_file, atomically: true, encoding: String.Encoding.utf8)
            print("file written")
        } catch {
            print("Failed to write")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBOutlet var imageView: UIImageView!
    
    func write_to_csv() {
        let text = subject + age + times
        do {
            try text.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to save")
        }
    }
    
    /**
     * Load the images to be displayed
     */
    func loadImages(files: [String]) -> [UIImage] {
        var res:[UIImage] = [];
//        let practice_images = ["A", "B", "C", "E", "A", "I"]
//        for name in practice_images {
//            res.append(resizeTestingImage(img: UIImage(named: name)!));
//        }
        for var file in files {
            file = file.trimmingCharacters(in: .whitespacesAndNewlines);
            
            //imageArray.append(resizeImage(img: UIImage(named: file)!));
            
            res.append(resizeTestingImage(img: UIImage(named: file)!));
        }

        return res;
    }
    
    /**
     * Return the elapsed time
     */
    func elapsedTimeSinceLastStart() -> Double {
        let endTime = DispatchTime.now();
        let nanoTime = endTime.uptimeNanoseconds - (self.startTime!.uptimeNanoseconds)
        
        // converting to ms
        let timeElapsed = (Double(nanoTime) / 1000000)

        return timeElapsed;
    }
    
    /**
     * Resize the image to a square size.
     */
    func resizeImage(img: UIImage, size: Double) -> UIImage {
        let sideSize = CGFloat(size);
        let size = img.size;
        let heightR = sideSize / size.height;
        let newSize = CGSize(width: size.width * heightR, height: size.height * heightR);
        let rect = CGRect(x: 0, y: 0, width: sideSize, height: sideSize);

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0);
        img.draw(in: rect);

        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return newImage!;
    }
    
    func resizeTestingImage(img: UIImage) -> UIImage {
        let heightSize = CGFloat(600.0);
        let widthSize = CGFloat(800.0);
        let size = img.size;
        let heightR = heightSize / size.height;
        let widthR = widthSize / size.width;
        let newSize = CGSize(width: size.width * widthR, height: size.height * heightR);
        let rect = CGRect(x: 0, y: 0, width: widthSize, height: heightSize);
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0);
        img.draw(in: rect);
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage!;
    }
    
    /**
     * Show the next image.
     */
    func nextImage() {
        imageView.image = imageArray[self.currentImg];
    }

    /***
     When the view is about to appear.
    */
    override func viewDidLoad() {
        self.navigationItem.setHidesBackButton(true, animated: false);
        
        // resized Yes
        let resizedYes = resizeImage(img: UIImage(named: "smile")!, size: 200.0);
        yesButton.setImage(resizedYes, for: .normal);
        
        // resized No
        let resizedNo = resizeImage(img: UIImage(named: "frown")!, size: 200.0);
        noButton.setImage(resizedNo, for: .normal);
    }
    
    func modify_test_array() {
        
        var temp_labels_text = [[String]]()
        var temp_shape_sequence_text = [[String]]()
        var temp_categories = [[String]]()
//        print("tests")
//        print(tests)
        for item in tests {
            temp_labels_text.append([item[0], item[1]])
            let item_list = item[2...4]
            temp_shape_sequence_text.append(Array(item_list))
            temp_categories.append(Array(item[5...]))
        }
        tests = temp_shape_sequence_text
//        print("modified")
//        print(tests)
        labels_text = temp_labels_text
        categories = temp_categories
//        print("categories")
//        print(categories)
    }
    
    /**
     * View is about to appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        modify_test_array();
        startTesting();
    }
    
    /**
     * Test finished.
     */
    func testFinished() {
        imageView.image = #imageLiteral(resourceName: "finished_slide")
        sleep(3)
        let results = subject + age + times
        update_output(data: results, file: file_name)
        sendEmail(data: results)
        
//        var save_file = subject
//        path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(save_file + ".csv")
//        write_to_csv()
//        let vc = UIActivityViewController(activityItems: [path!], applicationActivities: nil)
//        present(vc, animated: true, completion: nil)
//        if let popOver = vc.popoverPresentationController {
//            popOver.sourceView = self.view
//        }
        //_ = navigationController?.popToRootViewController(animated: true);
    }
    
    
    /**
     * Start the next test
     */
    func startNextTest() {
        // hide buttons
        hideButtons();

        if(currentTest == nil) {
            currentTest = 0;
        } else {
            currentTest! += 1;
        }
        
        if(currentTest == tests.count) {
            testFinished();
        } else {
            let triplet_sequence = tests[currentTest!]
            let triplet_description = labels_text[currentTest!][0] + "," + labels_text[currentTest!][1]
            let triplet_text = triplet_sequence.joined(separator: ",")
            let triplet_category = categories[currentTest!][0] + "," + categories[currentTest!][1]
            times += triplet_description + ","
            times += triplet_text + ","
            times += triplet_category + ","
            imageArray = loadImages(files: tests[currentTest!]);
            currentImg = 0;
            Timer.scheduledTimer(withTimeInterval: DISPLAY_TIME, repeats: true) {
                (timer) in self.onTick(timer:timer);
            }
        }
    }
    
    /**
     * Hide the buttons.
     */
    func hideButtons() {
        yesButton.isHidden = true;
        noButton.isHidden = true;
    }
    
    /**
     * Show the buttons.
     */
    func showButtons() {
        yesButton.isHidden = false;
        noButton.isHidden = false;
    }
    
    /**
     * Start the testing
    */
    func startTesting() {
        imageView.backgroundColor = UIColor.black
        file_name = subject + ".csv"
        startNextTest();
    }
    
    /**
     * Every time the timer ticks.
    */
    func onTick(timer:Timer) {
        // remove previous image
        imageView.image = nil;
        
        if(self.currentImg == tests[currentTest!].count) {
            timer.invalidate();
            startTime = DispatchTime.now();
            showButtons();
            
        } else {
            // Change this to add ISI
            Timer.scheduledTimer(withTimeInterval: ISI, repeats: false) {
                _ in
                    self.nextImage();
                    self.currentImg += 1;
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
    func sendEmail(data: String) {
        let fileName = subject + ".csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        do {
            try data.write(to: path!, atomically: true, encoding: String.Encoding.utf8)

            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self as MFMailComposeViewControllerDelegate
                mail.setToRecipients(["taforest@gmail.com"])
                mail.setSubject("Data for subject " + subject)
                mail.setMessageBody("Hi,\n\nPlease find attached the .csv file\n\nBudding Minds Lab", isHTML: false)
                try mail.addAttachmentData(NSData(contentsOf: path!) as Data, mimeType: "text/csv", fileName: subject + ".csv")
                present(mail, animated: true)
            } else {
                print("Email failed")
            }
        } catch {
            print("Attachment failed")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
