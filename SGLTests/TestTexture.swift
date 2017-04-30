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
import CoreFoundation
import ImageIO
@testable import SGL

// Tests: Texture
// Depends on: DisplayLinkTestRunner, BasicFragmentShaderPT, BasicVertexShaderPT, FlatSquarePT,
// ShaderProgram

class TestTexture: XCTestCase {
    
    // General testing code.
    
    let ViewportWidth = 2
    let ViewportHeight = 2
    
    // Start a test by clearing to a red color.

    func startTest() {
        glViewport(0, 0, GLsizei(ViewportWidth), GLsizei(ViewportHeight))
        glClearColor(1.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    // End a test by reading the pixels and verifying that the texture fills the viewport.

    func finishTest() {
        var result = Array<UInt8>(repeating: 0, count: ViewportWidth * ViewportHeight * 4)
        glReadPixels(0, 0, GLsizei(ViewportWidth), GLsizei(ViewportHeight), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), &result)
        
        for y in 0..<ViewportHeight {
            for x in 0..<ViewportWidth {
                let i = (y * ViewportWidth + x) * 4
                
                // It seems to be difficult to generate a PNG file with exact RGB values on OS X,
                // so 37, 255, 8 (and not 0, 255, 0) is "green".
                
                XCTAssertEqual(result[i],     37)
                XCTAssertEqual(result[i + 1], 255)
                XCTAssertEqual(result[i + 2], 8)
            }
        }
    }
    
    // Wait for the specified texture to load, then use it on a square that fills the viewport.
    
    func awaitAndVerifyTexture(texture: Texture) {
        let exp = expectation(description: "test")
        let _ = DisplayLinkTestRunner(expectation: exp) {
            texture.swap()
            if texture.id == 0 {
                return false
            }
            
            self.startTest()
            
            let vertexShader = BasicVertexShaderPT()
            XCTAssertNotNil(vertexShader)
            
            let fragmentShader = BasicFragmentShaderPT()
            XCTAssertNotNil(fragmentShader)
            
            let program = ShaderProgram<BasicVertexShaderPT, BasicFragmentShaderPT, FlatSquarePT>(vertexShader: vertexShader!, fragmentShader: fragmentShader!)
            XCTAssertNotNil(program)
            XCTAssertNotEqual(program!.id, 0)
            
            let drawable = FlatSquarePT(texture: texture)
            let added = program!.addDrawable(drawable)
            XCTAssertTrue(added)
            
            let scale = GLKMatrix4MakeScale(2, 2, 1)
            drawable.variables.modelViewProjMat.value = scale
            
            program!.draw()
            
            self.finishTest()
            return true
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Verify a texture loaded asynchronously from a CGImage.
    
    func testSetAsyncCGImage() {
        let texture = Texture(sharegroup: EAGLContext.current().sharegroup)
        let imagePath = Bundle.main.path(forResource: "green", ofType: "png")
        XCTAssertNotNil(imagePath)

        let path: CFString = imagePath! as NSString
        let url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, path, CFURLPathStyle.cfurlposixPathStyle, false)
        XCTAssertNotNil(url)
        let source = CGImageSourceCreateWithURL(url!, nil)
        XCTAssertNotNil(source)
        let image = CGImageSourceCreateImageAtIndex(source!, 0, nil)
        XCTAssertNotNil(image)
        
        texture.setAsync(cgImage: image!)
        awaitAndVerifyTexture(texture: texture)
    }
    
    // Verify a texture loaded asynchronously from a .png file.
    
    func testSetAsyncFile() {
        let texture = Texture(sharegroup: EAGLContext.current().sharegroup)
        let imagePath = Bundle.main.path(forResource: "green", ofType: "png")
        XCTAssertNotNil(imagePath)
        
        texture.setAsync(filename: imagePath!)
        awaitAndVerifyTexture(texture: texture)
    }
    
}
