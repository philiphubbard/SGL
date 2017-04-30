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
import GLKit

// A unit square in the X-Y plane.  The vertices have positions ("P") and texture coordinates ("T"), 
// so the square can be used with any "PT" shaders.

public class FlatSquarePT: Drawable {
    public let variables: VariablesPT
    public var texture: Texture
    
    public init(texture tx: Texture) {
        variables = VariablesPT.initForDrawable()
        texture = tx
        let verticesSizeBytes = vertices.count * MemoryLayout<VertexPT>.size
        drawableCore = DrawableCore<VariablesPT>(vertices: vertices, verticesSizeBytes: verticesSizeBytes, elements: elements, primitiveMode: GL_TRIANGLE_STRIP)
    }
    
    public func build<VS: VertexShading, FS: FragmentShading>(vertexShading: VS, fragmentShading: FS, shaderProgram: GLuint) -> Bool where VS.Vars == VariablesPT {
        return drawableCore.build(shader: vertexShading, drawable: self, shaderProgram: shaderProgram)
    }
    
    public func draw<VS: VertexShading, FS: FragmentShading>(vertexShading: VS, fragmentShading: FS) where VS.Vars == VariablesPT {
        variables.draw()
        texture.bind()
        drawableCore.draw()
    }
    
    private let drawableCore: DrawableCore<VariablesPT>
    
    private struct VertexPT {
        var x: GLfloat
        var y: GLfloat
        var z: GLfloat
        var w: GLfloat
        var s: GLushort
        var t: GLushort
    }
    
    private let vertices: [VertexPT] =
        [VertexPT(x: -0.5, y:  0.5, z:  0, w: 1.0, s:      0, t: 0xffff),
         VertexPT(x: -0.5, y: -0.5, z:  0, w: 1.0, s:      0, t:      0),
         VertexPT(x:  0.5, y:  0.5, z:  0, w: 1.0, s: 0xffff, t: 0xffff),
         VertexPT(x:  0.5, y: -0.5, z:  0, w: 1.0, s: 0xffff, t:      0)]
    
    private let elements: [GLuint] = [0, 1, 2, 3]
}
