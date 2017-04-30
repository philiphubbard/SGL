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

// A vertex shader that produces positions ("P"), normals ("N") and texture coordinates ("T") given
// inputs including a model-view-projection matrix and a corresponding normal matrix.

public class BasicVertexShaderPNT: VertexShading {
    public var id: GLuint {
        get {
            return shadingCore.id
        }
    }
    public let variables: VariablesPNT
    
    public init?() {
        guard let core = ShadingCore(shaderType: GLenum(GL_VERTEX_SHADER), shaderStr: vertexShaderStr) else {
            return nil
        }
        shadingCore = core
        variables = VariablesPNT.initForShading(positionName: "in_position", normalName: "in_normal", textureName: "in_texCoord", modelViewProjMatName: "modelViewProjMatrix", normalMatName: "normalMatrix")
    }
    
    private let shadingCore: ShadingCore
    private let vertexShaderStr = "#version 300 es\n" +
        "uniform mat4 modelViewProjMatrix;\n" +
        "uniform mat3 normalMatrix;\n" +
        "in vec4 in_position;\n" +
        "in vec3 in_normal;\n" +
        "in vec2 in_texCoord;\n" +
        "out vec3 vs_normal;\n" +
        "out vec2 vs_texCoord;\n" +
        "void main()\n" +
        "{\n" +
        "    gl_Position = modelViewProjMatrix * in_position;\n" +
        "    vs_normal = normalize(normalMatrix * in_normal);\n" +
        "    vs_texCoord = in_texCoord;\n" +
        "}\n"
}
