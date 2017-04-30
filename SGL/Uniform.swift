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

// Classes to simplify the set up and use of GLSL uniforms.  A uniform in GLSL shader code is
// associated with two instances of an Uniform subclass.  One comes from the class/struct
// conforming to a shader protocol, VertexShading or FragmentShading, and it specifies the 
// uniform's name.  The other comes from the code that will set the value of the uniform.  A 
// "connect" operation with the two Unfiorm subclass instances calls the OpenGL functions to set up
// the uniform.

public class Uniform {
    public let name: String
    public private(set) var index: GLint = -1
    
    // To be used by a class/struct conforming to the VertexShading or FragmentShading protocols.

    public init(name: String) {
        self.name = name
    }
    
    // To be used by the code providing the uniform's value.

    public init() {
        self.name = ""
    }
    
    public func connect(other: Uniform, shaderProgram: GLuint) -> Bool {
        let shaderUniform = (name != "") ? self : other
        let geometryUniform = (name != "") ? other : self
        
        guard shaderUniform.name != "" else {
            print("Uniform.connect(): neither attribute has a name")
            return false
        }
        
        geometryUniform.index = glGetUniformLocation(shaderProgram, shaderUniform.name)
        
        guard geometryUniform.index != -1 else {
            print("glGetUniformLocation() failed for \(shaderUniform.name)")
            return false
        }
        return true
    }
}

// To make the element of GLKit matrices available as arrays of floats.

extension GLKMatrix4 {
    var array: [Float] {
        return (0..<16).map { i in
            self[i]
        }
    }
}

extension GLKMatrix3 {
    var array: [Float] {
        return (0..<9).map { i in
            self[i]
        }
    }
}

// A subclass for a four-by-four matrix of floats.

public class Uniform44f: Uniform {
    public var value: GLKMatrix4 = GLKMatrix4Identity
    
    public func draw() {
        guard index != GL_INVALID_VALUE else {
            print("Warning: Uniform44f.draw() name \"\(name)\" skipping invalid index")
            return
        }
        
        glUniformMatrix4fv(index, 1, GLboolean(GL_FALSE), value.array)
    }
}

// A subclass for a three-by-three matrix of floats.

public class Uniform33f: Uniform {
    public var value: GLKMatrix3 = GLKMatrix3Identity
    
    public func draw() {
        guard index != GL_INVALID_VALUE else {
            print("Warning: Uniform33f.draw() name \"\(name)\" skipping invalid index")
            return
        }
        
        glUniformMatrix3fv(index, 1, GLboolean(GL_FALSE), value.array)
    }
}

// A subclass for a three-element vector of floats.

public class Uniform3f: Uniform {
    public var value: GLKVector3 = GLKVector3(v: (0, 0, 0))
    
    public func draw() {
        guard index != GL_INVALID_VALUE else {
            print("Warning: Uniform3f.draw() name \"\(name)\" skipping invalid index")
            return
        }
        
        glUniform3f(index, value.x, value.y, value.z)
    }
}

// A subclass for a single float.

public class Uniform1f: Uniform {
    public var value: GLfloat = 0
    
    public func draw() {
        guard index != GL_INVALID_VALUE else {
            print("Warning: Uniform1f.draw() name \"\(name)\" skipping invalid index")
            return
        }
        
        glUniform1f(index, value)
    }
}
