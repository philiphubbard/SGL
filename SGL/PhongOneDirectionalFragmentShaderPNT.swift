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

// A fragment shader that implements the Phong shading model, with one directional light source.
// This shader expects that the vertex shader that produces positions ("P"), normals ("N"), and 
// texture coordinates ("T").

// A subclass of Variables containing the parameters of the shader as OpenGL uniforms.

public class VariablesPhongOneDirectionalPNT: Variables {
    public let ambientColor: Uniform3f
    public let lightColor: Uniform3f
    public let lightDirection: Uniform3f
    public let halfVector: Uniform3f
    public let shininess: Uniform1f
    public let strength: Uniform1f
    
    public func connect(other: Variables, shaderProgram: GLuint) -> Bool {
        guard let otherPhong = other as? VariablesPhongOneDirectionalPNT else {
            return false
        }
        guard ambientColor.connect(other: otherPhong.ambientColor, shaderProgram: shaderProgram),
            lightColor.connect(other: otherPhong.lightColor, shaderProgram: shaderProgram),
            lightDirection.connect(other: otherPhong.lightDirection, shaderProgram: shaderProgram),
            halfVector.connect(other: otherPhong.halfVector, shaderProgram: shaderProgram),
            shininess.connect(other: otherPhong.shininess, shaderProgram: shaderProgram),
            strength.connect(other: otherPhong.strength, shaderProgram: shaderProgram) else {
            return false
        }
        return true
    }
    
    public func draw() {
        ambientColor.draw()
        lightColor.draw()
        lightDirection.draw()
        halfVector.draw()
        shininess.draw()
        strength.draw()
    }
    
    fileprivate init(ambientColorName: String, lightColorName: String, lightDirectionName: String, halfVectorName: String, shininessName: String, strengthName: String) {
        ambientColor = Uniform3f(name: ambientColorName)
        lightColor = Uniform3f(name: lightColorName)
        lightDirection = Uniform3f(name: lightDirectionName)
        halfVector = Uniform3f(name: halfVectorName)
        shininess = Uniform1f(name: shininessName)
        strength = Uniform1f(name: strengthName)
    }
}

// The shader.

public class PhongOneDirectionalFragmentShaderPNT: FragmentShading {
    public var id: GLuint {
        get {
            return shadingCore.id
        }
    }
    public let variables: VariablesPhongOneDirectionalPNT
    
    public init?() {
        guard let core = ShadingCore(shaderType: GLenum(GL_FRAGMENT_SHADER), shaderStr: fragmentShaderStr) else {
            return nil
        }
        shadingCore = core
        variables = VariablesPhongOneDirectionalPNT(ambientColorName: "ambient", lightColorName: "lightColor", lightDirectionName: "lightDirection", halfVectorName: "halfVector", shininessName: "shininess", strengthName: "strength")
        
        // Usable default values.
        
        variables.ambientColor.value = GLKVector3Make(0.3, 0.3, 0.3)
        variables.lightColor.value = GLKVector3Make(0.6, 0.6, 0.6)
        variables.lightDirection.value = GLKVector3Normalize(GLKVector3Make(1.0, 2.0, 2.0))
        variables.shininess.value = 5.0
        variables.strength.value = 1.0
    }
    
    public func postLink(shaderProgram: GLuint) -> Bool {
        
        // Connect the variables to themselves to establish the OpenGL uniforms.
        
        return variables.connect(other: variables, shaderProgram: shaderProgram)
    }
    
    public func preDraw() {
        let half = GLKVector3Add(GLKVector3Make(0, 0, 1), variables.lightDirection.value)
        variables.halfVector.value = GLKVector3Normalize(half)
        
        variables.draw()
    }
    
    private let shadingCore: ShadingCore
    private let fragmentShaderStr = "#version 300 es\n" +
        "uniform sampler2D tex;\n" +
        "uniform highp vec3 ambient;\n" +
        "uniform highp vec3 lightColor;\n" +
        "uniform highp vec3 lightDirection;\n" +
        "uniform highp vec3 halfVector;\n" +
        "uniform highp float shininess;\n" +
        "uniform highp float strength;\n" +
        "in highp vec2 vs_texCoord;\n" +
        "in highp vec3 vs_normal;\n" +
        "out highp vec4 fs_color;\n" +
        "void main()\n" +
        "{\n" +
        "    highp float diffuse = max(0.0, dot(vs_normal, lightDirection));\n" +
        "    highp float specular = max(0.0, dot(vs_normal, halfVector));\n" +
        "    if (diffuse == 0.0)\n" +
        "        specular = 0.0;\n" +
        "    else\n" +
        "        specular = pow(specular, shininess);\n" +
        "    highp vec3 scattered = ambient + lightColor * diffuse;\n" +
        "    highp vec3 reflected = lightColor * specular * strength;\n" +
        "    highp vec4 color1 = texture(tex, vs_texCoord);\n" +
        "    highp vec3 color2 = min(color1.rgb * scattered + reflected, vec3(1.0));\n" +
        "    fs_color = vec4(color2, color1.a);\n" +
        "}\n"
}
