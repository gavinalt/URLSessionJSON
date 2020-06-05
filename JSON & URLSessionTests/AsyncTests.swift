//
//  TestJsonTests.swift
//  TestJsonTests
//
//  Created by Gavin Li on 5/27/20.
//  Copyright © 2020 Gavin Li. All rights reserved.
//

import XCTest
@testable import JSON___URLSession

class AsyncTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadDataSemaphore() throws {
        guard let url = Bundle.main.url(forResource: "response", withExtension: "json") else { return }

        var authors: [Author] = []
        let semaphore = DispatchSemaphore(value: 0)
        NetworkService.loadData(from: url) { (authorsResponse, error) -> Void in
            if let error = error {
                XCTFail("test failed. \(error.localizedDescription)")
            }

            authors = authorsResponse
            semaphore.signal()
        }

        let timeout = DispatchTime.now() + .seconds(1)
        if semaphore.wait(timeout: timeout) == .timedOut { // wait() blocks the current thread until the semaphore is signaled
          XCTFail("timed out")
        }

        XCTAssertTrue(authors[0].name == "John", "test author0")
        XCTAssert(authors[0].book[0].year == 2018)
        XCTAssertEqual(authors[1].name, "Max")
    }

    func testLoadDataPromise() throws {
        guard let url = Bundle.main.url(forResource: "response", withExtension: "json") else { return }

        let promise = expectation(description: "returned authors correctly")
        NetworkService.loadData(from: url) { (authors, error) -> Void in
            if let error = error {
                XCTFail("test failed. \(error.localizedDescription)")
            }

            if authors[0].name == "John" && authors[0].book[0].year == 2018 {
                promise.fulfill()
            }
        }

        wait(for: [promise], timeout: 3)
        // You have to wait for 3 seconds for it to fail
    }

    func testLoadDataPromiseBetter() throws {
        guard let url = Bundle.main.url(forResource: "response", withExtension: "json") else { return }

        var authors: [Author] = []
        let promise = expectation(description: "returned authors correctly")
        NetworkService.loadData(from: url) { (authorsResponse, error) -> Void in
            if let error = error {
                XCTFail("test failed. \(error.localizedDescription)")
            }

            authors = authorsResponse
            promise.fulfill()
        }

        wait(for: [promise], timeout: 3)

        XCTAssertTrue(authors[0].name == "John", "test author0")
        XCTAssert(authors[0].book[0].year == 2018)
        XCTAssertEqual(authors[1].name, "Max")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
