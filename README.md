SGL: Simpler OpenGLES in Swift
==============================

By Philip M. Hubbard, 2017

Overview
--------

The SGL framework provides Swift code that simplifies the set up and use of OpenGLES.  It factors out code for common operations, like building a shader program with error reporting or passing vertex data to the attributes of a shader, with an architecture that favors protocols and composition over inheritance.  When possible it supports static type checking, so for example, a compilation error will occur on an attempt to use a vertex shader that expects normals with geometry that does not provide them.  SGL implements various shaders, such as fragment shaders for several lighting models, and makes it straightforward for applications like [FacetiousIOS](http://github.com/philiphubbard/FacetiousIOS) to concisely define its own shaders, like a vertex shader that builds a height map from a video texture.

Implementation
--------------

An important but error-prone step in using OpenGLES is setting up the shaders’ vertex attributes and uniforms.  SGL simplifies this step through the `Attribute` and `Uniform` classes and the `Variables` protocol.  For a vertex attribute, there are OpenGLES calls that connect a declaration in the GLSL shader code with per-vertex data for the geometry; a uniform is similar in that there is a declaration in the shader and an OpenGLES call to make it accessible for data.  In SGL, each vertex attribute or uniform is represented by a pair of `Attribute` or `Uniform` instances: one for the code implementing the shader, and one for the code providing the data.  There is a `connect` method that can be called for each pair to make the appropriate OpenGLES calls, to allow the data to be transferred to the shader.

The arguments to the OpenGLES calls made by `connect` are specific to the type of data for the attribute or uniform.  So there are subclasses of `Attribute` and `Uniform` like `Attribute4f`, `Attribute2us`, `Uniform44f` and `Uniform1f` that specify the arguments for a vector of four floats, a vector of two unsigned shorts, a four-by-four matrix of floats and a single float, respectively.  (These subclasses are the only examples of inheritance in SGL.)

Shaders define specific groups of vertex attributes and uniforms, and the `Variables` protocol is the basis of SGL's management of corresponding `Attribute` and `Uniform` instances.  The `VariablesPNT` class, for example, has an `Attribute4f` for positions ("P"), an `Attribute3f` for normals ("N") and a `Attribute2us` for texture coordinates ("T"), plus a `Uniform44f` for the model-view-projection matrix and a `Uniform33f` for the normal matrix.  To conform to the `Variables` protocol, it defines the `connect` method to connect these `Attribute` and `Uniform` instances to those from another `VariablesPNT` instance.

The protocols for vertex shaders and geometry, `VertexShading` and `Drawable` respectively, each have an associated type that conforms to `Variables`.  Operations involving shaders and geometry are generics with type parameters conforming to these protocols, and with "where" clauses enforcing that the associated types match.  This pattern provides static type checking.  An example is the generic `build` method requirement of the `Drawable` protocol.  The `FlattishSquarePNT` class conforms to `Drawable` and has a `build` method, and the "where" clause requires that the `VertexShading`-conforming argument has `VariablesPNT` to match those of `FlattishSquarePNT`.  The `build` method thus can call `connect` on the two `VariablesPNT` instances.  This `build` method is called by another generic method, `addDrawable` on the `ShaderProgram` class, which is initialized with instances of classes conforming to `VertexShading` and `FragmentShading`.  Again, a "where" clause enforces that `addDrawable` can be called only with geometry that matches the shaders.

Each instance of `FlattishSquarePNT` has an instance of the `DrawableCore` class, and it factors out most of the work of the `build` method.  This use of composition can be repeated in other geometry classes that conform to the `Drawable` protocol.  In a similar way, the `ShadingCore` class factors out the work of compiling a shader and reporting any compilation errors, and is used by all the classes that conform to the `VertexShading` and `FragmentShading` protocols.

SGL provides two `FragmentShading`-conforming classes with `VariablesPNT` associated types.  The `PhongOneDirectionalFragmentShaderPNT` class implements the Phong specular lighting model for one directional light source.  The `SphericalHarmonicsFragmentShaderPNT` class implements the Ramamoorthi and Hanrahan algorithm for diffuse shading using spherical harmonics.

The `Texture` class uses `GLKTextureLoader` to asynchronously load textures from either a `CGImage` or a file.  It supports double buffering of texture identifiers, and a `swap` method makes the asynchronously loaded texture available for binding when it is ready.

Testing
-------

The unit tests for SGL are based on the XCTest framework and run in Xcode in the standard way.  Currently, the tests have about 85% code coverage.

Many of the tests involve setting up SGL constructs to render a recognizable pattern of pixels, as detected with `glReadPixels`.  The tests run as part of a host app, SGLTestsHostApp.  Its storyboard creates a `GLKViewController` to initialize the OpenGLES context and drive the rendering loop.  To integrate a test into the asynchronous rendering loop in a predictable way, a test uses the `DisplayLinkTestRunner` class.  The test creates an instance of this class, and passes the actual test code to the instance as a closure.  The instance sets up a `CADisplayLink` callback to execute the closure as part of the next scheduled frame.  When the closure is finished the `DisplayLinkTestRunner` instance calls `fulfill` on a `XCTestExpectation` instance, provided by the test.  Doing so returns control to the test, which has been sleeping in a `waitForExpectations` call, so the test can finish.

Building
--------

SGL is a framework to facilitate reuse.  The simplest way to use it as part of an app is to add its project file to an Xcode workspace that includes the app project.  Some of the steps in getting a custom framework to work with an app on a device are subtle, but the following steps work:

1. Close the SGL project if it is open in Xcode.
2. Open the workspace.
3. In the Project Navigator panel on the left side of Xcode, right-click and choose "Add Files to <workspace name>..."
4. In the dialog, from the "SGL" folder choose "SGL.xcodeproj" and press "Add".
5. Select the app project in the Project Navigator, and in the "General" tab’s "Linked Frameworks and Libraries", press the "+" button.
6. In the dialog, from the "Workspace" folder choose "SGL.framework" and press "Add".
7. In the "Build Phase" tab, press the "+" button (top left) and choose "New Copy Files Phase."  This phase will install the framework when the app is installed on a device.
8. In the "Copy Files" area, change the "Destination" to "Frameworks".
9. Drag into this "Copy Files" area the "SGL.framework" file from the "Products" folder for SGL in the Project Navigator.  Note that it is important to *drag* the framework from the "Products" folder: the alternative---pressing the "+" button in the "Copy Files" area and choosing any of the "SGL.framework" items listed---will appear to work but will fail at run time.
10. In the dialog that appears after dragging, use the default settings (i.e., only "Create folder references" is checked) and press "Finish".

SGL depends on the GLKit and OpenGLES frameworks.  The specific version of Xcode used to develop SGL was 8.3.
