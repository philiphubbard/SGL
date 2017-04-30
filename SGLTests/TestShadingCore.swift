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
@testable import SGL

// Tests: ShadingCore
// Depends on: no other SGl code

class TestShadingCore: XCTestCase {

    // Verify that a vertex shader with no errors gets a proper identifier.
    
    func testGoodVertex() {
        let goodVertexShaderStr = "#version 300 es\n" +
            "in vec4 in_position;\n" +
            "void main()\n" +
            "{\n" +
            "    gl_Position = in_position;\n" +
            "}\n"
        let goodVertexShaderCore = ShadingCore(shaderType: GLenum(GL_VERTEX_SHADER), shaderStr: goodVertexShaderStr);
        XCTAssertNotNil(goodVertexShaderCore)
        XCTAssertNotEqual(goodVertexShaderCore!.id, 0)
    }
    
    // Verify that a vertex shader with errors is nil.
    
    func testBadVertex() {
        print("Begin expected error messages\n")
        let badVertexShaderStr = "#version 300 es\n" +
            "// The 'in_position' declaration is missing a type.\n" +
            "in in_position;\n" +
            "void main()\n" +
            "{\n" +
            "    gl_Position = in_position;\n" +
            "}\n"
        let badVertexShaderCore = ShadingCore(shaderType: GLenum(GL_VERTEX_SHADER), shaderStr: badVertexShaderStr);
        print("End expected error messages")
        XCTAssertNil(badVertexShaderCore)
    }
    
    // Verify that a fragment shader with no errors gets a proper identifier.

    func testGoodFragment() {
        let goodFragmentShaderStr = "#version 300 es\n" +
            "out highp vec4 fs_color;\n" +
            "void main()\n" +
            "{\n" +
            "    fs_color = vec4(0, 1, 0, 1);\n" +
            "}\n";
        let goodFragmentShaderCore = ShadingCore(shaderType: GLenum(GL_FRAGMENT_SHADER), shaderStr: goodFragmentShaderStr);
        XCTAssertNotNil(goodFragmentShaderCore)
        XCTAssertNotEqual(goodFragmentShaderCore!.id, 0)
    }
    
    // Verify that a fragment shader with errors is nil.

    func testBadFragment() {
        print("Begin expected error messages\n")
        let badFragmentShaderStr = "#version 300 es\n" +
            "out highp vec4 fs_color;\n" +
            "void main()\n" +
            "{\n" +
            "    // The vec4 has only three arguments.\n" +
            "    fs_color = vec4(0, 1, 0);\n" +
            "}\n";
        let badFragmentShaderCore = ShadingCore(shaderType: GLenum(GL_FRAGMENT_SHADER), shaderStr: badFragmentShaderStr);
        print("End expected error messages")
        XCTAssertNil(badFragmentShaderCore)
    }
    
}
