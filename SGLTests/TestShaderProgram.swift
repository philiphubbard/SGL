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

// Tests: ShaderProgram
// Depends on: protocols Drawable, FragmentShading, Variables, VertexShading; class ShadingCore

class TestShaderProgram: XCTestCase {
    
    // Simple variables for testing.
    
    class TestVariablesEmpty: Variables {
        func connect(other: Variables, shaderProgram: GLuint) -> Bool {
            return true
        }
    }
    
    // Simple vertex shader for testing.
    
    let VertexShaderStr = "#version 300 es\n" +
        "in vec4 in_position;\n" +
        "in vec2 in_texCoord;\n" +
        "out vec2 vs_texCoord;\n" +
        "void main()\n" +
        "{\n" +
        "    gl_Position = in_position;\n" +
        "    vs_texCoord = in_texCoord;\n" +
        "}\n"
    
    class TestVertexShader: VertexShading {
        let variables: TestVariablesEmpty
        let id: GLuint
        init?(shaderStr: String) {
            variables = TestVariablesEmpty()
            guard let sc = ShadingCore(shaderType: GLenum(GL_VERTEX_SHADER), shaderStr: shaderStr) else {
                return nil
            }
            shadingCore = sc
            id = sc.id
        }
        let shadingCore: ShadingCore?
    }
    
    // Simple fragment shader code that will generate a link error.
    
    let BadFragmentShaderStr = "#version 300 es\n" +
        "in highp vec2 vs_texCoord;\n" +
        "out highp vec4 fs_color;\n" +
        "// Missing main(): will compile, but will not link.\n"
    
    // Simple fragment shader that will not generate and error.
    
    let GoodFragmentShaderStr = "#version 300 es\n" +
        "in highp vec2 vs_texCoord;\n" +
        "out highp vec4 fs_color;\n" +
        "void main()\n" +
        "{\n" +
        "    fs_color = vec4(vs_texCoord.s, vs_texCoord.t, 0, 1);\n" +
        "}\n";
    
    // Simple fragment shader for testing, which can use either fragment shader code.
    
    class TestFragmentShader: FragmentShading {
        let id: GLuint
        init?(shaderStr: String) {
            guard let sc = ShadingCore(shaderType: GLenum(GL_FRAGMENT_SHADER), shaderStr: shaderStr) else {
                return nil
            }
            shadingCore = sc
            id = sc.id
        }
        let shadingCore: ShadingCore?
    }
    
    // Simple drawable that indicates whether it was built and drawn.
    
    class TestDrawable: Drawable {
        var built: Bool
        var drawn: Bool
        
        let variables: TestVariablesEmpty
        init() {
            built = false
            drawn = false
            variables = TestVariablesEmpty()
        }
        func build<VS: VertexShading, FS: FragmentShading>(vertexShading: VS, fragmentShading: FS, shaderProgram: GLuint) -> Bool where VS.Vars == TestVariablesEmpty {
            built = true
            return true
        }
        func draw<VS: VertexShading, FS: FragmentShading>(vertexShading: VS, fragmentShading: FS) where VS.Vars == TestVariablesEmpty {
            drawn = true
        }
    }
    
    // Verify that the program is nil if the shaders generate a link error.
    
    func testShaderProgramBad() {
        let vertexShader = TestVertexShader(shaderStr: VertexShaderStr)
        XCTAssertNotNil(vertexShader)
        
        let fragmentShader = TestFragmentShader(shaderStr: BadFragmentShaderStr)
        XCTAssertNotNil(fragmentShader)
        
        print("Begin expected error messages\n")
        let program = ShaderProgram<TestVertexShader, TestFragmentShader, TestDrawable>(vertexShader: vertexShader!, fragmentShader: fragmentShader!)
        print("End expected error messages")
        XCTAssertNil(program)
    }
    
    // Verify that the program has as proper identifier if there is no link error.
    
    func testShaderProgramGood() {
        let vertexShader = TestVertexShader(shaderStr: VertexShaderStr)
        XCTAssertNotNil(vertexShader)
        
        let fragmentShader = TestFragmentShader(shaderStr: GoodFragmentShaderStr)
        XCTAssertNotNil(fragmentShader)
        
        let program = ShaderProgram<TestVertexShader, TestFragmentShader, TestDrawable>(vertexShader: vertexShader!, fragmentShader: fragmentShader!)
        XCTAssertNotNil(program)
        XCTAssertNotEqual(program!.id, 0)
    }
    
    // Verify that drawables added to a program are built and drawn, but no longer drawn after
    // being removed.

    func testShaderProgramDrawable() {
        let vertexShader = TestVertexShader(shaderStr: VertexShaderStr)
        XCTAssertNotNil(vertexShader)
        
        let fragmentShader = TestFragmentShader(shaderStr: GoodFragmentShaderStr)
        XCTAssertNotNil(fragmentShader)
        
        let program = ShaderProgram<TestVertexShader, TestFragmentShader, TestDrawable>(vertexShader: vertexShader!, fragmentShader: fragmentShader!)
        XCTAssertNotNil(program)
        XCTAssertNotEqual(program!.id, 0)
        
        let drawable1 = TestDrawable()
        let drawable2 = TestDrawable()
        let drawable3 = TestDrawable()
        
        let added1 = program!.addDrawable(drawable1)
        XCTAssertTrue(added1)
        XCTAssertTrue(drawable1.built)
        
        let added2 = program!.addDrawable(drawable2)
        XCTAssertTrue(added2)
        XCTAssertTrue(drawable2.built)
        
        XCTAssertFalse(drawable3.built)
        
        program!.draw()
        
        XCTAssertTrue(drawable1.drawn)
        XCTAssertTrue(drawable2.drawn)
        XCTAssertFalse(drawable3.drawn)
        
        drawable1.drawn = false
        drawable2.drawn = false
        
        program!.removeAllDrawables()
        
        program!.draw()
        
        XCTAssertFalse(drawable1.drawn)
        XCTAssertFalse(drawable2.drawn)
        XCTAssertFalse(drawable3.drawn)
    }
    
}
