//
//  XCTTestcase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Perfect Aduh on 18/02/2022.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, potential momery leak", file: file, line: line)
        }
    }
}
