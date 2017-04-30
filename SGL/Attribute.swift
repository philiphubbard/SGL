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

// Classes to simplify the set up and use of GLSL vertex attributes.  An attribute in GLSL shader
// code is associated with two instances of an Attribute subclass.  One comes from the class/struct
// conforming to the VertexShading protocol, and it specifies the attribute's name.  The other comes
// from the class/struct conforming to the Drawable protocol, and it specifies the start and stride
// of the vertex attribute data.  Both agree on the size and type of the attribute.  A "connect"
// operation with the two Attribute subclass instances calls the OpenGL functions that set up the 
// named attribute to use the specified data.

// The base class.

public class Attribute {
    public let name: String
    public let size: GLint
    public let type: GLenum
    public let normalized: GLboolean
    public let stride: GLsizei
    public let start: UnsafePointer<Int>?
    
    public func connect(other: Attribute, shaderProgram: GLuint) -> Bool {
        guard (name != "") != (other.name != "") else {
            print("Attribute.connect() expects one initialized with a name and one initialized with a stride and start.")
            return false
        }
        let shaderAttribute = (name != "") ? self : other
        let geometryAttribute = (name != "") ? other : self
        
        guard shaderAttribute.size == geometryAttribute.size else {
            print("Attribute.connect() name \"\(name)\" mismatching sizes")
            return false
        }
        guard shaderAttribute.type == geometryAttribute.type else {
            print("Attribute.connect() name \"\(name)\" mismatching types")
            return false
        }
        
        let index: GLint = glGetAttribLocation(shaderProgram, shaderAttribute.name)
        guard index != -1 else {
            print("glGetAttribLocation() failed for \(name)")
            return false
        }
        
        glEnableVertexAttribArray(GLuint(index))
        glVertexAttribPointer(GLuint(index), geometryAttribute.size, geometryAttribute.type, geometryAttribute.normalized, geometryAttribute.stride, geometryAttribute.start)
        
        return true
    }
    
    fileprivate init(name: String, size: GLint, type: GLenum, normalized: GLboolean) {
        self.name = name
        
        self.size = size
        self.type = type
        self.normalized = normalized
        
        self.stride = 0
        self.start = UnsafePointer<Int>(bitPattern: 0)
    }
    
    fileprivate init(stride: GLsizei, start: UnsafePointer<Int>?, size: GLint, type: GLenum, normalized: GLboolean) {
        self.stride = stride
        self.start = start
        
        self.size = size
        self.type = type
        self.normalized = normalized
        
        self.name = ""
    }
}

// A subclass for a four-element vector of floats.

public class Attribute4f: Attribute {
    
    // To be used by a class/struct conforming to the VertexShading protocol.
    
    public init(name: String) {
        super.init(name: name, size: 4, type: GLenum(GL_FLOAT), normalized: GLboolean(GL_FALSE))
    }
    
    // To be used by a class/struct conforming to the Drawable protocol.
    
    public init(stride: GLsizei, start: UnsafePointer<Int>?) {
        super.init(stride: stride, start: start, size: 4, type: GLenum(GL_FLOAT), normalized: GLboolean(GL_FALSE))
    }
}

// A subclass for a three-element vector of floats.

public class Attribute3f: Attribute {
    
    // To be used by a class/struct conforming to the VertexShading protocol.
    
    public init(name: String) {
        super.init(name: name, size: 3, type: GLenum(GL_FLOAT), normalized: GLboolean(GL_FALSE))
    }
    
    // To be used by a class/struct conforming to the Drawable protocol.
    
    public init(stride: GLsizei, start: UnsafePointer<Int>?) {
        super.init(stride: stride, start: start, size: 3, type: GLenum(GL_FLOAT), normalized: GLboolean(GL_FALSE))
    }
}

// A subclass for a two-element vector of unsigned shorts.

public class Attribute2us: Attribute {
    
    // To be used by a class/struct conforming to the VertexShading protocol.
    
    public init(name: String) {
        super.init(name: name, size: 2, type: GLenum(GL_UNSIGNED_SHORT), normalized: GLboolean(GL_TRUE))
    }
    
    // To be used by a class/struct conforming to the Drawable protocol.
    
    public init(stride: GLsizei, start: UnsafePointer<Int>?) {
        super.init(stride: stride, start: start, size: 2, type: GLenum(GL_UNSIGNED_SHORT), normalized: GLboolean(GL_TRUE))
    }
}
