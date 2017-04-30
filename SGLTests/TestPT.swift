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
import OpenGLES
@testable import SGL

// Tests: BasicFragmentShaderPT, BasicVertexShaderPT, FlatSquarePT, VariablesPT
// Depends on: DisplayLinkTestRunner, ShaderProgram, Texture

class TestPT: XCTestCase {

    // General testing code.
    
    let ViewportWidth = 2
    let ViewportHeight = 2
    
    // Start a test by clearing to a red color.
 
    func startTest() {
        glViewport(0, 0, GLsizei(ViewportWidth), GLsizei(ViewportHeight))
        glClearColor(1.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    // End a test by reading the pixels and verifying that the square has been drawn in the right
    // half of the viewport.

    func finishTest() {
        var result = Array<UInt8>(repeating: 0, count: ViewportWidth * ViewportHeight * 4)
        glReadPixels(0, 0, GLsizei(ViewportWidth), GLsizei(ViewportHeight), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), &result)
        
        for y in 0..<ViewportHeight {
            for x in 0..<ViewportWidth {
                let i = (y * ViewportWidth + x) * 4
                if x < ViewportWidth / 2 {
                    XCTAssertEqual(result[i],     255)
                    XCTAssertEqual(result[i + 1], 0)
                    XCTAssertEqual(result[i + 2], 0)
                } else {
                    XCTAssertEqual(result[i],     0)
                    XCTAssertEqual(result[i + 1], 255)
                    XCTAssertEqual(result[i + 2], 0)
                }
            }
        }
    }
    
    // Verify that the basic "PT" shaders render a FlatSquarePT with a trivial texture.
    
    func testBasicPT() {
        let exp = expectation(description: "test")
        let _ = DisplayLinkTestRunner(expectation: exp) {
            self.startTest()
            
            let vertexShader = BasicVertexShaderPT()
            XCTAssertNotNil(vertexShader)
            
            let fragmentShader = BasicFragmentShaderPT()
            XCTAssertNotNil(fragmentShader)
            
            let program = ShaderProgram<BasicVertexShaderPT, BasicFragmentShaderPT, FlatSquarePT>(vertexShader: vertexShader!, fragmentShader: fragmentShader!)
            XCTAssertNotNil(program)
            XCTAssertNotEqual(program!.id, 0)
            
            let texture = Texture(sharegroup: EAGLContext.current().sharegroup)
            let textureData: Array<GLubyte> = [0, 255, 0, 255]
            let set = texture.set(data: textureData, width: 1, height: 1, format: GL_RGBA)
            XCTAssertTrue(set)
            
            let drawable = FlatSquarePT(texture: texture)
            let added = program!.addDrawable(drawable)
            XCTAssertTrue(added)
            
            // Position the square so it covers the right half of the viewport.
            
            let scale = GLKMatrix4MakeScale(1, 2, 1)
            let translate = GLKMatrix4MakeTranslation(0.5, 0, 0)
            drawable.variables.modelViewProjMat.value = GLKMatrix4Multiply(translate, scale)
            
            program!.draw()
            
            self.finishTest()
            return true
        }
        waitForExpectations(timeout: 1.0, handler: nil)        
    }
    
}
