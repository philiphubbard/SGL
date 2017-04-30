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

// A component that factors out the core OpenGL calls for setting up and drawing geometry with
// vertex data specified by a Variables subclass.  The set up involves connecting to the Variables 
// subclass associated with a vertex shader, and is performed by a generic function with a "where
// clause" that ensures the subclasses match.

public class DrawableCore<A: Variables> {
    
    // An example value for primitiveMode is GL_TRIANGLE_STRIP.
    
    public init(vertices: UnsafeRawPointer, verticesSizeBytes: GLsizeiptr, elements: [GLuint], primitiveMode: GLint) {
        self.vertices = vertices
        self.verticesSizeBytes = verticesSizeBytes
        self.elements = elements
        self.primitiveMode = primitiveMode
    }
    
    public func build<S: VertexShading, D: Drawable>(shader: S, drawable: D, shaderProgram: GLuint) -> Bool where S.Vars == D.Vars {
        var vertexBuffer: GLuint = 0
        glGenBuffers(1, &vertexBuffer)
        guard vertexBuffer != 0 else {
            print("glGenBuffers failed for vertex buffer")
            return false
        }
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), verticesSizeBytes, vertices, GLenum(GL_STATIC_DRAW))
        
        glGenVertexArrays(1, &vertexArrayObject)
        guard vertexArrayObject != 0 else {
            print("glGenVertexArrays failed")
            return false
        }
        glBindVertexArray(vertexArrayObject)
        
        guard drawable.variables.connect(other: shader.variables, shaderProgram: shaderProgram) else {
            return false
        }
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
        
        glGenBuffers(1, &elementBuffer);
        guard elementBuffer != 0 else {
            print("glGenBuffers() failed for element buffer")
            return false
        }
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), elementBuffer);
        let elementsSize: GLsizeiptr = elements.count * MemoryLayout<GLuint>.size
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), elementsSize, elements, GLenum(GL_STATIC_DRAW))
        
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0);
        
        return true
    }
    
    public func draw() {
        glBindVertexArray(vertexArrayObject)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), elementBuffer)
        glDrawElements(GLenum(primitiveMode), GLsizei(elements.count), GLenum(GL_UNSIGNED_INT), nil)
    }
    
    private let vertices: UnsafeRawPointer
    private let verticesSizeBytes: GLsizeiptr
    private let elements: [GLuint]
    private let primitiveMode: GLint
    
    private var vertexArrayObject: GLuint = 0
    private var elementBuffer: GLuint = 0
}
