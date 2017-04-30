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

// A simple fragment shader that outputs color based only on an input texture, to be used with a
// vertex shader that produces positions ("P") and texture coordinates ("T").

public class BasicFragmentShaderPT: FragmentShading {
    public var id: GLuint {
        get {
            return shadingCore.id
        }
    }
    
    public init?() {
        guard let core = ShadingCore(shaderType: GLenum(GL_FRAGMENT_SHADER), shaderStr: fragmentShaderStr) else {
            return nil
        }
        shadingCore = core
    }
    
    private let shadingCore: ShadingCore
    private let fragmentShaderStr = "#version 300 es\n" +
        "uniform sampler2D tex;\n" +
        "in highp vec2 vs_texCoord;\n" +
        "out highp vec4 fs_color;\n" +
        "void main()\n" +
        "{\n" +
        "    fs_color = texture(tex, vs_texCoord);\n" +
        "}\n";
}
