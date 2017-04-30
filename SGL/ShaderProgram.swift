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

// A program using a two shaders that conform to VertexShading and FragmentShading.  This class is 
// a generic so a "where clause" can ensure that the Variables subclasses for the shaders match.
// The program draws instances conforming to Drawable that have been added to it.

public class ShaderProgram<VS: VertexShading, FS: FragmentShading, D: Drawable> where VS.Vars == D.Vars {
    public private(set) var id: GLuint = 0
    public private(set) var vertexShader: VS!
    public private(set) var fragmentShader: FS!
    
    public init?(vertexShader: VS, fragmentShader: FS) {
        self.vertexShader = vertexShader
        self.fragmentShader = fragmentShader
        guard build() else {
            return nil
        }
    }
    
    public func addDrawable(_ drawable: D) -> Bool {
        guard drawable.build(vertexShading: vertexShader, fragmentShading: fragmentShader, shaderProgram: id) else {
            return false
        }
        drawables.append(drawable)
        return true
    }
    
    public func removeAllDrawables() {
        drawables = []
    }
    
    public func draw() {
        glUseProgram(id)
        
        vertexShader.preDraw()
        fragmentShader.preDraw()
        
        for drawable in drawables {
            drawable.draw(vertexShading: vertexShader, fragmentShading: fragmentShader)
        }
        
        vertexShader.postDraw()
        fragmentShader.postDraw()
    }
    
    private func build() -> Bool {
        glEnable(GLenum(GL_PRIMITIVE_RESTART_FIXED_INDEX))
        
        id = glCreateProgram()
        guard id != 0 else {
            print("glCreateProgram() failed")
            return false
        }
        
        glAttachShader(id, vertexShader.id)
        glAttachShader(id, fragmentShader.id)
        
        glLinkProgram(id)
        
        var linkStatus: GLint = GL_NO_ERROR
        glGetProgramiv(id, GLenum(GL_LINK_STATUS), &linkStatus);
        guard linkStatus == GL_TRUE else {
            let MaxErrorSize: GLsizei = 1024
            var errorBuffer = [CChar](repeating: 0, count: Int(MaxErrorSize))
            var errorSize: GLsizei = 0
            glGetProgramInfoLog(id, MaxErrorSize, &errorSize, &errorBuffer);
            let errorString = String(utf8String: errorBuffer)!
            print("glLinkProgram() failed: \(errorString)")
            return false
        }
        
        guard vertexShader.postLink(shaderProgram: id),
            fragmentShader.postLink(shaderProgram: id) else {
            return false
        }
        
        return true
    }
    
    private var drawables: [D] = []
}
