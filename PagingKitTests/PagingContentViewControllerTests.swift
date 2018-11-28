//
//  PagingContentViewControllerTests.swift
//  PagingKitTests
//
//  Copyright (c) 2017 Kazuhiro Hayashi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import XCTest
@testable import PagingKit

class PagingContentViewControllerTests: XCTestCase {
    var pagingContentViewController: PagingContentViewController?
    var dataSource: PagingContentViewControllerDataSource?
    
    override func setUp() {
        super.setUp()
        pagingContentViewController = PagingContentViewController()
        pagingContentViewController?.view.frame = CGRect(x: 0, y: 0, width: 320, height: 667)
    }
    
    override func tearDown() {
        super.tearDown()
        dataSource = nil
    }
    
    func testCallingDataSource() {
        let dataSource = PagingContentVcDataSourceMock()
        pagingContentViewController?.dataSource = dataSource
        pagingContentViewController?.reloadData()
        wait(for: [dataSource.numberOfItemExpectation, dataSource.viewControllerExpectation], timeout: 1)
        self.dataSource = dataSource
    }
    
    func testReloadData() {
        let expectation = XCTestExpectation(description: "finish reloadData")
        let dataSource = PagingContentVcDataSourceSpy()
        pagingContentViewController?.dataSource = dataSource
        pagingContentViewController?.loadViewIfNeeded()
        pagingContentViewController?.reloadData(with: 3, completion: { [weak self] in
            XCTAssertEqual(self?.pagingContentViewController?.scrollView.contentSize, CGSize(width: 1600, height: 667), "expected scrvollView layout")
            XCTAssertEqual(self?.pagingContentViewController?.scrollView.contentOffset, CGPoint(x: 960, y: 0), "expected offset")
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
        self.dataSource = dataSource
    }
    
    func testScrollAfterReloadData() {
        let expectation = XCTestExpectation(description: "finish reloadData")
        let dataSource = PagingContentVcDataSourceSpy()
        pagingContentViewController?.dataSource = dataSource
        pagingContentViewController?.loadViewIfNeeded()
        pagingContentViewController?.reloadData(with: 0, completion: { [weak self] in
            self?.pagingContentViewController?.scroll(to: 4, animated: false)
            XCTAssertEqual(self?.pagingContentViewController?.scrollView.contentSize, CGSize(width: 1600, height: 667), "expected scrvollView layout")
            XCTAssertEqual(self?.pagingContentViewController?.scrollView.contentOffset, CGPoint(x: 1280, y: 0), "expected offset")
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
        self.dataSource = dataSource
    }
    
    func testHookCompletionHandlerAfterReloadData() {
        guard let pagingContentViewController = pagingContentViewController else {
            XCTFail()
            return
        }

        let dataSource = PagingContentVcDataSourceSpy(count: 100)
        pagingContentViewController.dataSource = dataSource
        pagingContentViewController.loadViewIfNeeded()
        
        do {
            let expectation = XCTestExpectation(description: "index: 4")
            pagingContentViewController.reloadData(with: 50, completion: {
                let expectedOffsetX = pagingContentViewController.scrollView.bounds.width * 50
                XCTAssertEqual(
                    pagingContentViewController.scrollView.contentOffset,
                    CGPoint(x: expectedOffsetX, y: 0),
                    "PagingContentViewController has completely finished reloading"
                )
                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 1)
        }
        
        do {
            let expectation = XCTestExpectation(description: "index: 2")
            pagingContentViewController.reloadData(with: 98, completion: {
                let expectedOffsetX = pagingContentViewController.scrollView.bounds.width * 98
                XCTAssertEqual(
                    pagingContentViewController.scrollView.contentOffset,
                    CGPoint(x: expectedOffsetX, y: 0),
                    "PagingContentViewController has completely finished reloading"
                )
                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 1)
        }
        
        do {
            let expectation = XCTestExpectation(description: "index: 5")
            pagingContentViewController.reloadData(with: 40, completion: {
                let expectedOffsetX = pagingContentViewController.scrollView.bounds.width * 40
                XCTAssertEqual(
                    pagingContentViewController.scrollView.contentOffset,
                    CGPoint(x: expectedOffsetX, y: 0),
                    "PagingContentViewController has completely finished reloading"
                )
                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 1)
        }

        self.dataSource = dataSource
    }
    
    func testContentOffsetRatioInScrolling() {
        let expectation = XCTestExpectation(description: "finish reloadData")
        let dataSource = PagingContentVcDataSourceSpy()
        pagingContentViewController?.dataSource = dataSource
        pagingContentViewController?.loadViewIfNeeded()
        pagingContentViewController?.reloadData(with: 0, completion: { [weak self] in
            XCTAssertEqual(self?.pagingContentViewController?.contentOffsetRatio, 0, "At first, scrollview is in index 0")
            self?.pagingContentViewController?.scroll(to: 4, animated: false)
            XCTAssertEqual(self?.pagingContentViewController?.contentOffsetRatio, 1, "Next, scrollview is in index 4")
            self?.pagingContentViewController?.scroll(to: 2, animated: false)
            XCTAssertEqual(self?.pagingContentViewController?.contentOffsetRatio, 0.5, "Then, scrollview is in index 2")
            self?.pagingContentViewController?.scroll(to: 1, animated: false)
            XCTAssertEqual(self?.pagingContentViewController?.contentOffsetRatio, 0.25, "After all, scrollview is in index 1")
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
        self.dataSource = dataSource
    }
    
    func testViewDidLayoutSubviews() {
        let expectation = XCTestExpectation(description: "finish reloadData")
        let dataSource = PagingContentVcDataSourceSpy()
        pagingContentViewController?.dataSource = dataSource
        pagingContentViewController?.loadViewIfNeeded()
        pagingContentViewController?.reloadData(with: 2, completion: { [weak self] in
            self?.pagingContentViewController?.view.frame = CGRect(x: 0, y: 0, width: 667, height: 320)
            self?.pagingContentViewController?.view.setNeedsLayout()
            self?.pagingContentViewController?.view.layoutIfNeeded()
            XCTAssertEqual(self?.pagingContentViewController?.scrollView.contentSize, CGSize(width: 667 * 5, height: 320), "correct ")
            XCTAssertEqual(self?.pagingContentViewController?.contentOffsetRatio, 0.5, "correct content offset")
            let actualSubviewSizes = self?.pagingContentViewController?.scrollView.subviews.map { $0.bounds.size } ?? []
            let expectedSubviewSizes = self?.pagingContentViewController?.scrollView.subviews.map { _ in CGSize(width: 667, height: 320) } ?? []
            XCTAssertEqual(actualSubviewSizes, expectedSubviewSizes, "correct content sizes")
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
        self.dataSource = dataSource
    }
}

class PagingContentVcDataSourceMock: NSObject, PagingContentViewControllerDataSource {
    let numberOfItemExpectation = XCTestExpectation(description: "call numberOfItemsForContentViewController")
    let viewControllerExpectation = XCTestExpectation(description: "call viewController")
    
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        numberOfItemExpectation.fulfill()
        return 2
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        viewControllerExpectation.fulfill()
        return UIViewController()
    }
}

class PagingContentVcDataSourceSpy: NSObject, PagingContentViewControllerDataSource {
    init(count: Int = 5) {
        vcs = Array(repeating: UIViewController(), count: count)
        super.init()
    }
    
    let vcs: [UIViewController]
    
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return vcs.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        let vc = vcs[index]
        vc.view.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        return vc
    }
}
