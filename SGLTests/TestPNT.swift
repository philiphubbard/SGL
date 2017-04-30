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

class TestPNT: XCTestCase {
    
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
                    
                    // The pixels in the left half of the viewport should be the background red.
                    
                    XCTAssertEqual(result[i],     255)
                    XCTAssertEqual(result[i + 1], 0)
                    XCTAssertEqual(result[i + 2], 0)
                } else {
                    
                    // For the pixels in the right half, produced by the shaders with lighting, we 
                    // won't require specific values, as long as they are more green than red.
                    
                    XCTAssertLessThan(result[i],        128)
                    XCTAssertGreaterThan(result[i + 1], 128)
                    XCTAssertLessThan(result[i + 2],    128)
                }
            }
        }
    }
    
    // With the given fragment shader, verify that the vertex shader renders a FlattishSquarePT with
    // a trivial texture.
    
    func doTestPNT<FS: FragmentShading>(fragmentShader: FS) {
        let exp = expectation(description: "test")
        let _ = DisplayLinkTestRunner(expectation: exp) {
            self.startTest()
            
            let vertexShader = BasicVertexShaderPNT()
            XCTAssertNotNil(vertexShader)
            
            let program = ShaderProgram<BasicVertexShaderPNT, FS, FlattishSquarePNT>(vertexShader: vertexShader!, fragmentShader: fragmentShader)
            XCTAssertNotNil(program)
            XCTAssertNotEqual(program!.id, 0)
            
            let texture = Texture(sharegroup: EAGLContext.current().sharegroup)
            let textureData: Array<GLubyte> = [0, 255, 0, 255]
            let set = texture.set(data: textureData, width: 1, height: 1, format: GL_RGBA)
            XCTAssertTrue(set)
            
            let drawable = FlattishSquarePNT(numVerticesX: 4, numVerticesY: 4, maxZ: 0, texture: texture)
            let added = program!.addDrawable(drawable)
            XCTAssertTrue(added)
            
            let scale = GLKMatrix4MakeScale(1, 2, 1)
            let translate = GLKMatrix4MakeTranslation(0.5, 0, 0)
            let modelViewProjMat = GLKMatrix4Multiply(translate, scale)
            drawable.variables.modelViewProjMat.value = modelViewProjMat
            
            var invertible = true
            let normalMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewProjMat), &invertible)
            XCTAssertTrue(invertible)
            drawable.variables.normalMat.value = normalMat
            
            program!.draw()
            
            self.finishTest()
            return true
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Verify the Phong fragment shader.
    
    func testPhongPNT() {
        let fragmentShader = PhongOneDirectionalFragmentShaderPNT()
        XCTAssertNotNil(fragmentShader)
        
        doTestPNT(fragmentShader: fragmentShader!)
    }
    
    // Verify the spherical harmonics fragment shader.
    
    func testSphericalHarmonicsPNT() {
        let fragmentShader = SphericalHarmonicsFragmentShaderPNT()
        XCTAssertNotNil(fragmentShader)
        
        doTestPNT(fragmentShader: fragmentShader!)
    }

}
