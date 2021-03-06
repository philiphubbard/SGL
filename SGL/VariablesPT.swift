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

import OpenGLES

// The Attributes and Uniforms for shaders that support positions ("P"), and texture coordintes 
// ("T").

public class VariablesPT: Variables {
    public let position: Attribute4f
    public let texture: Attribute2us
    public let modelViewProjMat: Uniform44f
    
    // To be used by a class/struct conforming to the VertexShading protocol.

    public static func initForShading(positionName: String, textureName: String, modelViewProjMatName: String) -> VariablesPT {
        return VariablesPT(positionName: positionName, textureName: textureName, modelViewProjMatName: modelViewProjMatName)
    }
    
    // To be used by a class/struct conforming to the Drawable protocol.

    public static func initForDrawable() -> VariablesPT {
        return VariablesPT()
    }
    
    public func connect(other: Variables, shaderProgram: GLuint) -> Bool {
        guard let otherPT = other as? VariablesPT else {
            return false
        }
        guard position.connect(other: otherPT.position, shaderProgram: shaderProgram),
            texture.connect(other: otherPT.texture, shaderProgram: shaderProgram),
            modelViewProjMat.connect(other: otherPT.modelViewProjMat, shaderProgram: shaderProgram) else {
            return false
        }
        return true
    }
    
    public func draw() {
        modelViewProjMat.draw()
    }
    
    // Used by initForShading().

    private init(positionName: String, textureName: String, modelViewProjMatName: String) {
        position = Attribute4f(name: positionName)
        texture = Attribute2us(name: textureName)
        modelViewProjMat = Uniform44f(name: modelViewProjMatName)
    }
    
    // Used by initForDrawable().

    private init() {
        let stride = GLsizei(MemoryLayout<GLfloat>.size * 4 + MemoryLayout<GLushort>.size * 2)
        
        let positionStart = UnsafePointer<Int>(bitPattern: 0)
        position = Attribute4f(stride: stride, start: positionStart)
        
        let textureStart = UnsafePointer<Int>(bitPattern: MemoryLayout<GLfloat>.size * 4)
        texture = Attribute2us(stride: stride, start: textureStart)
        
        modelViewProjMat = Uniform44f()
    }
}

