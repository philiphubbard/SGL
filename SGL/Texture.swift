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

// A class for a texture that can be set with data synchronously, or loaded asynchronously with 
// GLKTextureLoader.  The "swap" operation will update the "id" when asynchronous loading is
// complete.

public class Texture {
    public private(set) var id: GLuint
    public private(set) var unit: GLint
    
    public init(sharegroup: EAGLSharegroup, unit: GLint = GL_TEXTURE0) {
        self.unit = unit
        id = 0
        
        textureLoader = GLKTextureLoader(sharegroup: sharegroup)
        textureLoaderQueue = DispatchQueue(label: "com.philiphubbard.Sgl.Texture.textureLoader")
        
        idBackQueue = DispatchQueue(label: "com.philiphubbard.Sgl.Texture.idBack")
    }
    
    public func setAsync(cgImage: CGImage) {
        let options = [GLKTextureLoaderOriginBottomLeft : NSNumber(value: true)]
        textureLoader.texture(with: cgImage, options: options, queue: textureLoaderQueue) {info, error in
            guard error == nil else {
                print("GLKTextureLoader error: \(error!)")
                return
            }
            guard let info = info else {
                return
            }
            
            // Retain a reference to the image, to avoid a crash in GLKTextureLoader.
            
            let _ = cgImage
            
            self.idBackQueue.sync {
                self.idBack = info.name
            }
        }
    }

    public func setAsync(filename: String) {
        let options = [GLKTextureLoaderOriginBottomLeft : NSNumber(value: true)]
        textureLoader.texture(withContentsOfFile: filename, options: options, queue: textureLoaderQueue) {info, error in
            guard error == nil else {
                print("GLKTextureLoader error: \(error!)")
                return
            }
            guard let info = info else {
                return
            }
            
            self.idBackQueue.sync {
                self.idBack = info.name
            }
        }
    }
    
    public func swap() {
        var idNew: GLuint = 0
        self.idBackQueue.sync {
            idNew = self.idBack
            self.idBack = 0
        }
        if idNew != 0 {
            glDeleteTextures(1, [id])
            id = idNew
        }
    }
    
    // An example value for format is GL_RGB or GL_RGBA.

    public func set(data: [GLubyte], width: GLsizei, height: GLsizei, format: GLint) -> Bool {
        glGenTextures(1, &id);
        guard id != 0 else {
            print("glGenTextures() failed")
            return false
        }
        glBindTexture(GLenum(GL_TEXTURE_2D), id)
        
        // TODO: Replace with glTexStorage2D() and glTexSubImage2D(), if the former becomes available.
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_BASE_LEVEL), 0)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAX_LEVEL), 0)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, format, width, height, 0, GLenum(format), GLenum(GL_UNSIGNED_BYTE), data)
        
        return true
    }

    public func bind() {
        glActiveTexture(GLenum(unit))
        glBindTexture(GLenum(GL_TEXTURE_2D), id)
    }
    
    private let textureLoader: GLKTextureLoader
    private let textureLoaderQueue: DispatchQueue
    
    private var idBack: GLuint = 0
    private let idBackQueue: DispatchQueue
}
