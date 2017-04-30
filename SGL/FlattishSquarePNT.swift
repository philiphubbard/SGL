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

// A unit square in the X-Y plane, with an optional "bulge" in the Z direction.  The vertices have 
// positions ("P"), normals ("N"), and texture coordinates ("T"), so the surface can be used with 
// any "PNT" shaders.

public class FlattishSquarePNT: Drawable {
    public let numVerticesX: Int
    public let numVerticesY: Int
    public let maxZ: GLfloat
    public let variables: VariablesPNT
    public var texture: Texture
    
    public init(numVerticesX nx: Int, numVerticesY ny: Int, maxZ mz: GLfloat, texture tx: Texture) {
        numVerticesX = nx
        numVerticesY = ny
        maxZ = mz
        variables = VariablesPNT.initForDrawable()
        texture = tx

        elements = [GLuint]()
        vertices = [VertexPNT]()
        
        FlattishSquarePNT.initVertices(numVerticesX: numVerticesX, numVerticesY: numVerticesY, maxZ: maxZ, vertices: &vertices, elements: &elements)
        
        let verticesSizeBytes = vertices.count * MemoryLayout<VertexPNT>.size
        drawableCore = DrawableCore<VariablesPT>(vertices: vertices, verticesSizeBytes: verticesSizeBytes, elements: elements, primitiveMode: GL_TRIANGLE_STRIP)
    }
    
    public func build<VS: VertexShading, FS: FragmentShading>(vertexShading: VS, fragmentShading: FS, shaderProgram: GLuint) -> Bool where VS.Vars == VariablesPNT {
        return drawableCore.build(shader: vertexShading, drawable: self, shaderProgram: shaderProgram)
    }
    
    public func draw<VS: VertexShading, FS: FragmentShading>(vertexShading: VS, fragmentShading: FS) where VS.Vars == VariablesPNT {
        variables.draw()
        texture.bind()
        drawableCore.draw()
    }
    
    private static func initVertices(numVerticesX: Int, numVerticesY: Int, maxZ: GLfloat, vertices: inout [VertexPNT], elements: inout [GLuint]) {
        let x0: GLfloat = -0.5
        var x: GLfloat
        let deltaX: GLfloat = 1.0 / GLfloat(numVerticesX - 1)
        var y: GLfloat = 0.5
        let deltaY: GLfloat = -1.0 / GLfloat(numVerticesY - 1)
        var z: GLfloat = 0.0
        let s0: Int = 0
        var s: Int
        let deltaS: Int = Int(GLushort.max) / (numVerticesX - 1)
        var t: Int = Int(GLushort.max)
        let deltaT: Int = -Int(GLushort.max) / (numVerticesY - 1)
        var elemVertex: GLuint = 0
        let elemVertexOffset: GLuint = GLuint(numVerticesX)
        let elementRestart: GLuint = UInt32.max
        
        let doZ = (maxZ != 0.0)
        
        for iY in 0..<numVerticesY {
            x = x0;
            s = s0;
            for _ in 0..<numVerticesX {
                if doZ {
                    z = FlattishSquarePNT.z(x: x, y: y, maxZ: maxZ)
                }
                
               var normal = GLKVector3Make(0, 0, 1)
                if doZ {
                    let dx = Float(1.0 / 1000.0)
                    let dy = dx
                    let vx = GLKVector3Make(dx, 0, Float(FlattishSquarePNT.z(x: x + dx, y: y, maxZ: maxZ) - z))
                    let vy = GLKVector3Make(0, dy, Float(FlattishSquarePNT.z(x: x, y: y + dy, maxZ: maxZ) - z))
                    normal = GLKVector3Normalize(GLKVector3CrossProduct(vx, vy))
                }
                
                vertices.append(VertexPNT(px: x, py: y, pz: z, pw: 1.0, nx: normal.x, ny: normal.y, nz: normal.z, s: GLushort(s), t: GLushort(t)))
                
                x += deltaX
                s += deltaS
                
                if iY < numVerticesY - 1 {
                    elements.append(elemVertex)
                    elements.append(elemVertex + elemVertexOffset)
                    elemVertex += 1
                }
            }
            y += deltaY;
            t += deltaT;
            
            if iY < numVerticesY - 1 {
                elements.append(elementRestart)
            }
        }
    }
    
    private static func z(x: GLfloat, y: GLfloat, maxZ: GLfloat) -> GLfloat {
        let zx = sin((x - (-0.5)) / (0.5 - (-0.5)) * Float.pi)
        let zy = sin((y - (-0.5)) / (0.5 - (-0.5)) * Float.pi)
        return maxZ * GLfloat(zx * zy)
    }
    
    private let drawableCore: DrawableCore<VariablesPT>
    
    private struct VertexPNT {
        var px: GLfloat
        var py: GLfloat
        var pz: GLfloat
        var pw: GLfloat
        var nx: GLfloat
        var ny: GLfloat
        var nz: GLfloat
        var s:  GLushort
        var t:  GLushort
    }
    
    private var vertices: [VertexPNT]
    private var elements: [GLuint]
    
}
