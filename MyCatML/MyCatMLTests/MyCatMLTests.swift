//
//  MyCatMLTests.swift
//  MyCatMLTests
//
//  Created by ChunpingLai on 2019/7/1.
//  Copyright © 2019 ChunpingLai. All rights reserved.
//

import XCTest
@testable import MyCatML

class MyCatMLTests: XCTestCase {
    var vc: ViewController!
    
    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        vc = storyboard.instantiateInitialViewController() as? ViewController
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCameraPermission() {
        let permission = vc.checkGalleryPermission()
        XCTAssert(permission, "沒有權限")
    }
    
    func testRecognizeIsMyCat() {
        let img = UIImage.init(named: "mycat.PNG")
        let prediction = vc.getPrediction(newImage: img!)
        XCTAssert(prediction?.classLabel == "MyCat", "辨識錯誤")
    }
    
    func testRecognizeNotMyCat() {
        let img = UIImage.init(named: "notmycat.PNG")
        let prediction = vc.getPrediction(newImage: img!)
        XCTAssert(prediction?.classLabel == "NotMyCat", "辨識錯誤")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
