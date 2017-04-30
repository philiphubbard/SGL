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

// Tests: Attribute, Attribute4f, Attribute3f, Attribute2us, Uniform, Uniform1f, Uniform3f, 
// Uniform33f, Uniform44f
// Depends on: protocols Drawable, FragmentShading, Variables, VertexShading; 
// classes DisplayLinkTestRunner, DrawableCore, ShaderProgram, ShadingCore

// Some protocols to allow common test code to be factored out into generics.

protocol TestPosition {
    init(x: Float, y: Float)
}

protocol TestUniformVariables: Variables {
    func draw()
}

class TestVariables: XCTestCase {
    
    // For testing Attribute4f.
    
    class TestVariablesP4f: Variables {
        let position: Attribute4f
        
        // For a shader.
        
        init(positionName: String) {
            position = Attribute4f(name: positionName)
        }
        
        // For a drawable.
        
        init() {
            let stride = GLsizei(MemoryLayout<GLfloat>.size * 4)
            
            let positionStart = UnsafePointer<Int>(bitPattern: 0)
            position = Attribute4f(stride: stride, start: positionStart)
        }
        
        func connect(other: Variables, shaderProgram: GLuint) -> Bool {
            guard let otherP4f = other as? TestVariablesP4f else {
                return false
            }
            guard position.connect(other: otherP4f.position, shaderProgram: shaderProgram) else {
                return false
            }
            return true
        }
    }
    
    struct P4f: TestPosition {
        init(x: Float, y: Float) {
            self.x = GLfloat(x)
            self.y = GLfloat(y)
        }
        var x: GLfloat
        var y: GLfloat
        var z: GLfloat = 0
        var w: GLfloat = 1
    }
    
    // For testing Attribute3f.
    
    class TestVariablesP3f: Variables {
        let position: Attribute3f
        
        // For a shader.
        
        init(positionName: String) {
            position = Attribute3f(name: positionName)
        }
        
        // For a drawable.
        
        init() {
            let stride = GLsizei(MemoryLayout<GLfloat>.size * 3)
            
            let positionStart = UnsafePointer<Int>(bitPattern: 0)
            position = Attribute3f(stride: stride, start: positionStart)
        }
        
        func connect(other: Variables, shaderProgram: GLuint) -> Bool {
            guard let otherP3f = other as? TestVariablesP3f else {
                return false
            }
            guard position.connect(other: otherP3f.position, shaderProgram: shaderProgram) else {
                return false
            }
            return true
        }
    }
    
    struct P3f: TestPosition {
        init(x: Float, y: Float) {
            self.x = GLfloat(x)
            self.y = GLfloat(y)
        }
        var x: GLfloat
        var y: GLfloat
        var z: GLfloat = 0
    }
    
    // For testing Attribute2us.
    
    class TestVariablesP2us: Variables {
        let position: Attribute2us
        
        // For a shader.
        
        init(positionName: String) {
            position = Attribute2us(name: positionName)
        }
        
        // For a drawable.
        
        init() {
            let stride = GLsizei(MemoryLayout<GLushort>.size * 2)
            
            let positionStart = UnsafePointer<Int>(bitPattern: 0)
            position = Attribute2us(stride: stride, start: positionStart)
        }
        
        func connect(other: Variables, shaderProgram: GLuint) -> Bool {
            guard let otherP2us = other as? TestVariablesP2us else {
                return false
            }
            guard position.connect(other: otherP2us.position, shaderProgram: shaderProgram) else {
                return false
            }
            return true
        }
    }
    
    struct P2us: TestPosition {
        static var scale: Float = 2;
        static var offset: Float = -1;
        
        init(x: Float, y: Float) {
            let max = Float(GLushort.max)
            self.x = GLushort((x - P2us.offset) / P2us.scale * max)
            self.y = GLushort((y - P2us.offset) / P2us.scale * max)
        }
        
        var x: GLushort
        var y: GLushort
    }
    
    // For testing Uniform1f.
    
    class TestVariablesUniform1f: TestUniformVariables {
        let uniform: Uniform1f
        
        init(name: String) {
            uniform = Uniform1f(name: name)
            uniform.value = 1
        }
        
        func connect(other: Variables, shaderProgram: GLuint) -> Bool {
            guard let otherUnform1f = other as? TestVariablesUniform1f else {
                return false
            }
            guard uniform.connect(other: otherUnform1f.uniform, shaderProgram: shaderProgram) else {
                return false
            }
            return true
        }
        
        func draw() {
            uniform.draw()
        }
    }
    
    // For testing Uniform3f.
    
    class TestVariablesUniform3f: TestUniformVariables {
        let uniform: Uniform3f
        
        init(name: String) {
            uniform = Uniform3f(name: name)
            uniform.value = GLKVector3Make(1, 0, 0)
        }
        
        func connect(other: Variables, shaderProgram: GLuint) -> Bool {
            guard let otherUnform3f = other as? TestVariablesUniform3f else {
                return false
            }
            guard uniform.connect(other: otherUnform3f.uniform, shaderProgram: shaderProgram) else {
                return false
            }
            return true
        }
        
        func draw() {
            uniform.draw()
        }
    }
    
    // For testing Uniform33f.
    
    class TestVariablesUniform33f: TestUniformVariables {
        let uniform: Uniform33f
        
        init(name: String) {
            uniform = Uniform33f(name: name)
            uniform.value = GLKMatrix3Make(1, 1, 1, 1, 1, 1, 1, 1, 1)
        }
        
        func connect(other: Variables, shaderProgram: GLuint) -> Bool {
            guard let otherUnform33f = other as? TestVariablesUniform33f else {
                return false
            }
            guard uniform.connect(other: otherUnform33f.uniform, shaderProgram: shaderProgram) else {
                return false
            }
            return true
        }
        
        func draw() {
            uniform.draw()
        }
    }
    
    // For testing Uniform44f.
    
    class TestVariablesUniform44f: TestUniformVariables {
        let uniform: Uniform44f
        
        init(name: String) {
            uniform = Uniform44f(name: name)
            uniform.value = GLKMatrix4Make(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
        }
        
        func connect(other: Variables, shaderProgram: GLuint) -> Bool {
            guard let otherUnform44f = other as? TestVariablesUniform44f else {
                return false
            }
            guard uniform.connect(other: otherUnform44f.uniform, shaderProgram: shaderProgram) else {
                return false
            }
            return true
        }
        
        func draw() {
            uniform.draw()
        }
    }
    
    // General testing code.
    
    let ViewportWidth = 2
    let ViewportHeight = 2
    
    class TestVertexShader<V: Variables>: VertexShading {
        let variables: V
        let id: GLuint
        
        // The vertex shader code is configurable with the type of the input position, to support
        // testing of different Attribute subclasses for that input.  The scale and offset are
        // needed when the type is unsigned short (which cannot represent negative value).
        
        init?(variables vars: V, positionType: String, scale: Float = 1, offset: Float = 0) {
            variables = vars
            
            let shaderStr = "#version 300 es\n" +
                "in " + positionType + " in_position;\n" +
                "void main()\n" +
                "{\n" +
                "    float x = in_position.x * \(scale) + \(offset);\n" +
                "    float y = in_position.y * \(scale) + \(offset);\n" +
                "    gl_Position = vec4(x, y, 0, 1);\n" +
                "}\n"
            guard let sc = ShadingCore(shaderType: GLenum(GL_VERTEX_SHADER), shaderStr: shaderStr) else {
                return nil
            }

            shadingCore = sc
            id = sc.id
        }
        let shadingCore: ShadingCore?
    }
    
    // The fragment shader for testing Attriburte subclasses renders green pixels.
    
    class TestFragmentShader: FragmentShading {
        let id: GLuint
        init?() {
            let shaderStr = "#version 300 es\n" +
                "out highp vec4 fs_color;\n" +
                "void main()\n" +
                "{\n" +
                "    fs_color = vec4(0, 1, 0, 1);\n" +
                "}\n";
            guard let sc = ShadingCore(shaderType: GLenum(GL_FRAGMENT_SHADER), shaderStr: shaderStr) else {
                return nil
            }
            
            shadingCore = sc
            id = sc.id
        }
        let shadingCore: ShadingCore?
    }
    
    // The fragment shader for testing Uniform subclasses renders a color based on the uniform's
    // value.
    
    class TestUniformFragmentShader<V: TestUniformVariables>: FragmentShading {
        let variables: V
        let id: GLuint
        
        // The fragment shader code is configurable with the type of the uniform, and the specific
        // expression for bulding a color from the uniform's value.
        
        init?(variables vars: V, uniformDeclaration: String, colorFromUniform: String) {
            variables = vars
            let shaderStr = "#version 300 es\n" +
                "out highp vec4 fs_color;\n" +
                "\(uniformDeclaration);\n" +
                "void main()\n" +
                "{\n" +
                "    fs_color = \(colorFromUniform);\n" +
                "}\n";
            guard let sc = ShadingCore(shaderType: GLenum(GL_FRAGMENT_SHADER), shaderStr: shaderStr) else {
                return nil
            }
            
            shadingCore = sc
            id = sc.id
        }

        func postLink(shaderProgram: GLuint) -> Bool {
            
            // Connect the variables to themselves to establish the OpenGL uniforms.
            
            return variables.connect(other: variables, shaderProgram: shaderProgram)
        }

        func preDraw() {
            variables.draw()
        }

        let shadingCore: ShadingCore?
    }

    class TestDrawable<P: TestPosition, V: Variables>: Drawable {
        let variables: V
        init(variables vars: V) {
            variables = vars
            let verticesSizeBytes = vertices.count * MemoryLayout<P>.size
            drawableCore = DrawableCore<V>(vertices: vertices, verticesSizeBytes: verticesSizeBytes, elements: elements, primitiveMode: GL_TRIANGLES)
        }
        func build<VS: VertexShading, FS: FragmentShading>(vertexShading: VS, fragmentShading: FS, shaderProgram: GLuint) -> Bool where VS.Vars == V {
            return drawableCore.build(shader: vertexShading, drawable: self, shaderProgram: shaderProgram)
        }
        func draw<VS: VertexShading, FS: FragmentShading>(vertexShading: VS, fragmentShading: FS) where VS.Vars == V {
            drawableCore.draw()
        }
        
        // A triangle that will have pixels drawn where y < x.
        
        let vertices: [P] = [
            P(x: -1, y: -1),
            P(x:  1, y: -1),
            P(x:  1, y:  1)
        ]
        
        let elements: [GLuint] = [0, 1, 2]
        let drawableCore: DrawableCore<V>
    }
    
    // Start a test by clearing to a red color.
    
    func startTest() {
        glViewport(0, 0, GLsizei(ViewportWidth), GLsizei(ViewportHeight))
        glClearColor(1.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    // End a test by reading the pixels and verifying that the triangle has been drawn.
    
    func finishTest() {
        var result = Array<UInt8>(repeating: 0, count: ViewportWidth * ViewportHeight * 4)
        glReadPixels(0, 0, GLsizei(ViewportWidth), GLsizei(ViewportHeight), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), &result)
        
        for y in 0..<ViewportHeight {
            for x in 0..<ViewportWidth {
                let i = (y * ViewportWidth + x) * 4
                if y > x {
                    
                    // Pixels not corresponding to the triangle should be the default red.
                    
                    XCTAssertEqual(result[i],     255)
                    XCTAssertEqual(result[i + 1], 0)
                    XCTAssertEqual(result[i + 2], 0)
                } else {
                    
                    // Pixels corresponding to the triangle should be green.
                    
                    XCTAssertEqual(result[i],     0)
                    XCTAssertEqual(result[i + 1], 255)
                    XCTAssertEqual(result[i + 2], 0)
                }
            }
        }
    }
    
    // Tests for attributes.
    
    // Verify error conditions when connecting attributes.
    
    func testAttributeErrors() {
        print("Begin expected error messages\n")

        // It is an error if neither of the attributes being connected has a start and stride.
        
        let a1a = Attribute4f(name: "a1")
        let a1b = Attribute4f(name: "a1")
        XCTAssertFalse(a1a.connect(other: a1b, shaderProgram: 1))
        
        // It is an error if neither of the attributes being connected has a name.
        
        let a2aStart = UnsafePointer<Int>(bitPattern: 0)
        let a2a = Attribute4f(stride: 1, start: a2aStart)
        let a2bStart = UnsafePointer<Int>(bitPattern: 0)
        let a2b = Attribute4f(stride: 1, start: a2bStart)
        XCTAssertFalse(a2a.connect(other: a2b, shaderProgram: 1))

        // It is an error to connect two attributes of different types.
        
        let a3a = Attribute4f(name: "a3")
        let a3bStart = UnsafePointer<Int>(bitPattern: 0)
        let a3b = Attribute3f(stride: 1, start: a3bStart)
        XCTAssertFalse(a3a.connect(other: a3b, shaderProgram: 1))
        
        print("End expected error messages")
    }
    
    // Verify that an Attribute4f specifies vertex positions that render successfully.
    
    func testAttribute4f() {
        let exp = expectation(description: "test")
        let _ = DisplayLinkTestRunner(expectation: exp) {
            self.startTest()
            
            let vertexShader = TestVertexShader<TestVariablesP4f>(variables: TestVariablesP4f(positionName: "in_position"),positionType: "vec4")
            XCTAssertNotNil(vertexShader)
            
            let fragmentShader = TestFragmentShader()
            XCTAssertNotNil(fragmentShader)
            
            let program = ShaderProgram<TestVertexShader<TestVariablesP4f>, TestFragmentShader, TestDrawable<P4f, TestVariablesP4f>>(vertexShader: vertexShader!, fragmentShader: fragmentShader!)
            XCTAssertNotNil(program)
            XCTAssertNotEqual(program!.id, 0)
            
            let drawable = TestDrawable<P4f, TestVariablesP4f>(variables: TestVariablesP4f())
            let added = program!.addDrawable(drawable)
            XCTAssertTrue(added)
            
            program!.draw()
            
            self.finishTest()
            return true
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Verify that an Attribute3f specifies vertex positions that render successfully.
    
    func testAttribute3f() {
        let exp = expectation(description: "test")
        let _ = DisplayLinkTestRunner(expectation: exp) {
            self.startTest()
            
            let vertexShader = TestVertexShader<TestVariablesP3f>(variables: TestVariablesP3f(positionName: "in_position"),positionType: "vec3")
            XCTAssertNotNil(vertexShader)
            
            let fragmentShader = TestFragmentShader()
            XCTAssertNotNil(fragmentShader)
            
            let program = ShaderProgram<TestVertexShader<TestVariablesP3f>, TestFragmentShader, TestDrawable<P3f, TestVariablesP3f>>(vertexShader: vertexShader!, fragmentShader: fragmentShader!)
            XCTAssertNotNil(program)
            XCTAssertNotEqual(program!.id, 0)
            
            let drawable = TestDrawable<P3f, TestVariablesP3f>(variables: TestVariablesP3f())
            let added = program!.addDrawable(drawable)
            XCTAssertTrue(added)
            
            program!.draw()
            
            self.finishTest()
            return true
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Verify that an Attribute2us specifies vertex positions that render successfully.

    func testAttribute2us() {
        let exp = expectation(description: "test")
        let _ = DisplayLinkTestRunner(expectation: exp) {
            self.startTest()
            
            let vertexShader = TestVertexShader<TestVariablesP2us>(variables: TestVariablesP2us(positionName: "in_position"),positionType: "vec2", scale: P2us.scale, offset: P2us.offset)
            XCTAssertNotNil(vertexShader)
            
            let fragmentShader = TestFragmentShader()
            XCTAssertNotNil(fragmentShader)
            
            let program = ShaderProgram<TestVertexShader<TestVariablesP2us>, TestFragmentShader, TestDrawable<P2us, TestVariablesP2us>>(vertexShader: vertexShader!, fragmentShader: fragmentShader!)
            XCTAssertNotNil(program)
            XCTAssertNotEqual(program!.id, 0)
            
            let drawable = TestDrawable<P2us, TestVariablesP2us>(variables: TestVariablesP2us())
            let added = program!.addDrawable(drawable)
            XCTAssertTrue(added)
            
            program!.draw()
            
            self.finishTest()
            return true
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Tests for uniforms.
    
    // Verify that a Uniform1f specifies a component of a color that renders successfully.

    func testUniform1f() {
        let exp = expectation(description: "test")
        let _ = DisplayLinkTestRunner(expectation: exp) {
            self.startTest()
            
            let vertexShader = TestVertexShader<TestVariablesP4f>(variables: TestVariablesP4f(positionName: "in_position"),positionType: "vec4")
            XCTAssertNotNil(vertexShader)
            
            let uniformDeclaration = "uniform highp float color"
            let colorFromUniform = "vec4(0, color, 0, 1)"
            let fragmentShader = TestUniformFragmentShader(variables: TestVariablesUniform1f(name: "color"), uniformDeclaration: uniformDeclaration, colorFromUniform: colorFromUniform)
            XCTAssertNotNil(fragmentShader)
            
            let program = ShaderProgram<TestVertexShader<TestVariablesP4f>, TestUniformFragmentShader<TestVariablesUniform1f>, TestDrawable<P4f, TestVariablesP4f>>(vertexShader: vertexShader!, fragmentShader: fragmentShader!)
            XCTAssertNotNil(program)
            XCTAssertNotEqual(program!.id, 0)
            
            let drawable = TestDrawable<P4f, TestVariablesP4f>(variables: TestVariablesP4f())
            let added = program!.addDrawable(drawable)
            XCTAssertTrue(added)
            
            program!.draw()
            
            self.finishTest()
            return true
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Verify that a Uniform3f specifies a color that renders successfully.

    func testUniform3f() {
        let exp = expectation(description: "test")
        let _ = DisplayLinkTestRunner(expectation: exp) {
            self.startTest()
            
            let vertexShader = TestVertexShader<TestVariablesP4f>(variables: TestVariablesP4f(positionName: "in_position"),positionType: "vec4")
            XCTAssertNotNil(vertexShader)
            
            let uniformDeclaration = "uniform highp vec3 color"
            let colorFromUniform = "vec4(0, color.x, 0, 1)"
            let fragmentShader = TestUniformFragmentShader(variables: TestVariablesUniform3f(name: "color"), uniformDeclaration: uniformDeclaration, colorFromUniform: colorFromUniform)
            XCTAssertNotNil(fragmentShader)
            
            let program = ShaderProgram<TestVertexShader<TestVariablesP4f>, TestUniformFragmentShader<TestVariablesUniform3f>, TestDrawable<P4f, TestVariablesP4f>>(vertexShader: vertexShader!, fragmentShader: fragmentShader!)
            XCTAssertNotNil(program)
            XCTAssertNotEqual(program!.id, 0)
            
            let drawable = TestDrawable<P4f, TestVariablesP4f>(variables: TestVariablesP4f())
            let added = program!.addDrawable(drawable)
            XCTAssertTrue(added)
            
            program!.draw()
            
            self.finishTest()
            return true
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Verify that a color taken from some elements of a Uniform33f renders successfully.

    func testUniform33f() {
        let exp = expectation(description: "test")
        let _ = DisplayLinkTestRunner(expectation: exp) {
            self.startTest()
            
            let vertexShader = TestVertexShader<TestVariablesP4f>(variables: TestVariablesP4f(positionName: "in_position"),positionType: "vec4")
            XCTAssertNotNil(vertexShader)
            
            let uniformDeclaration = "uniform highp mat3 color"
            let colorFromUniform = "vec4(0, color[0][1], 0, 1)"
            let fragmentShader = TestUniformFragmentShader(variables: TestVariablesUniform33f(name: "color"), uniformDeclaration: uniformDeclaration, colorFromUniform: colorFromUniform)
            XCTAssertNotNil(fragmentShader)
            
            let program = ShaderProgram<TestVertexShader<TestVariablesP4f>, TestUniformFragmentShader<TestVariablesUniform33f>, TestDrawable<P4f, TestVariablesP4f>>(vertexShader: vertexShader!, fragmentShader: fragmentShader!)
            XCTAssertNotNil(program)
            XCTAssertNotEqual(program!.id, 0)
            
            let drawable = TestDrawable<P4f, TestVariablesP4f>(variables: TestVariablesP4f())
            let added = program!.addDrawable(drawable)
            XCTAssertTrue(added)
            
            program!.draw()
            
            self.finishTest()
            return true
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Verify that a color taken from some elements of a Uniform44f renders successfully.

    func testUniform44f() {
        let exp = expectation(description: "test")
        let _ = DisplayLinkTestRunner(expectation: exp) {
            self.startTest()
            
            let vertexShader = TestVertexShader<TestVariablesP4f>(variables: TestVariablesP4f(positionName: "in_position"),positionType: "vec4")
            XCTAssertNotNil(vertexShader)
            
            let uniformDeclaration = "uniform highp mat4 color"
            let colorFromUniform = "vec4(0, color[0][1], 0, 1)"
            let fragmentShader = TestUniformFragmentShader(variables: TestVariablesUniform44f(name: "color"), uniformDeclaration: uniformDeclaration, colorFromUniform: colorFromUniform)
            XCTAssertNotNil(fragmentShader)
            
            let program = ShaderProgram<TestVertexShader<TestVariablesP4f>, TestUniformFragmentShader<TestVariablesUniform44f>, TestDrawable<P4f, TestVariablesP4f>>(vertexShader: vertexShader!, fragmentShader: fragmentShader!)
            XCTAssertNotNil(program)
            XCTAssertNotEqual(program!.id, 0)
            
            let drawable = TestDrawable<P4f, TestVariablesP4f>(variables: TestVariablesP4f())
            let added = program!.addDrawable(drawable)
            XCTAssertTrue(added)
            
            program!.draw()
            
            self.finishTest()
            return true
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
