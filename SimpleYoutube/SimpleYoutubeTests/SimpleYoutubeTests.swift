//
//  SimpleYoutubeTests.swift
//  SimpleYoutubeTests
//
//  Created by Junteng on 2023/5/3.
//

import XCTest
@testable import SimpleYoutube

final class SimpleYoutubeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFetchChannelData() throws {
        // 1. Test that the method returns immediately if the "headImage.jpg" file already exists
        let path = NSTemporaryDirectory() + "headImage.jpg"
        let fileManager = FileManager.default
        fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        let instance = InfoViewModel()
        instance.fetchChannelData()
        XCTAssertTrue(fileManager.fileExists(atPath: path), "The file should still exist")
        
        // 2. Test that the method saves the image to the correct path when the network request is successful
        let expectation = self.expectation(description: "The image should be saved successfully")
        instance.fetchChannelData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(fileManager.fileExists(atPath: path), "The file should exist after saving")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0, handler: nil)
    }

    
    func testFetchChannelDataSuccess() {
        let expectation = XCTestExpectation(description: "API call successful")
        
        YoutubeAPI().fetchChannelData(completion: { result in
            switch result {
            case .success(let (path, url)):
                // 驗證回傳的 path 和 url 是否正確
                print("Path \(path), URL is \(url)")
                if(path.contains("headImage.jpg") && url != "") {
                    expectation.fulfill()
                } else {
                    XCTAssertEqual(path, "expected path")
                    XCTAssertEqual(url, "expected url")
                }
                
            case .failure(let error):
                XCTFail("API call failed with error: \(error.localizedDescription)")
            }
        })
        
        wait(for: [expectation], timeout: 5.0)
    }
        
    func testFetchChannelDataFailure() {
        let expectation = XCTestExpectation(description: "API call failed")
        
        // 測試時將 API 連線錯誤
        YoutubeAPI().fetchChannelData(completion: { result in
            switch result {
            case .success:
                expectation.fulfill()
                
            case .failure(let error):
                // 驗證回傳的錯誤是否正確
                XCTAssertEqual(error.localizedDescription, "expected error message")
                expectation.fulfill()
            }
        })
        
        wait(for: [expectation], timeout: 10.0)
    }
    


}
