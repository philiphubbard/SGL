// Copyright (c) 2017 Philip M. Hubbard
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
// NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// http://opensource.org/licenses/MIT

import XCTest
import GLKit

// Runs the specified closure (the body of a test) as part of the GLKViewController rendering loop.
// Fullfils the specified XCTestExpecation if the closure returns true, thus successfully ending an 
// asynchronous  test.  If the closure returns false, the XCTestExpecation will time out and the
// test will fail.

class DisplayLinkTestRunner: NSObject {
    init(expectation: XCTestExpectation, closure: @escaping () -> Bool) {
        self.expectation = expectation
        self.closure = closure
        super.init()
        
        let displaylink = CADisplayLink(target: self, selector: #selector(selector))
        displaylink.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    func selector(displaylink: CADisplayLink) {
        if closure() {
            expectation.fulfill()
            displaylink.remove(from: .current, forMode: .defaultRunLoopMode)
        }
    }
    
    var expectation: XCTestExpectation
    var closure: () -> Bool
}
