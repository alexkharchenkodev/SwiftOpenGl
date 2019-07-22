//
//  TriangleMask.swift
//  OpenGL_Test
//

import GLKit

class TriangleMask:BaseModel{
    
    var imgWidth: GLsizei = 1600
    var imgHeight: GLsizei = 900
    
    let rectangle: [Vertex] = [
        //x, y, z,  r, g, b, a,  u, v
        Vertex( 0.25, -0.75, 0, 1.0, 0.0, 0.0, 1.0, 1, 0),
        Vertex(-0.75,  0.25, 0, 1.0, 0.0, 0.0, 1.0, 0, 1),
        Vertex( 0.25,  0.25, 0, 1.0, 0.0, 0.0, 1.0, 1, 1)
    ]
    let indexList: [GLubyte] = [
        0, 1, 2
    ]
    
//    init(shader: Base) {
//        super.init(name: "MaskedTriangle", shader: shader as! ComplexShader, vertices: rectangle, indices: indexList)
//    }
    
    init(shader: Base = Base(vertexShader: "SimpleVertex.glsl", fragmentShader: "TriangleFragment.glsl")) {
        super.init(name: "MaskedTriangle", shader: shader, vertices: rectangle, indices: indexList)
        self.position = GLKVector3Make(700, 700, 0)
        self.scaleX = 500
        self.scaleY = 500
    }
    
    convenience init (shader: Base = Base(vertexShader: "SimpleVertex.glsl", fragmentShader: "TriangleFragment.glsl"),
                      width: GLsizei, height: GLsizei){
        self.init(shader: shader)
        self.imgHeight = height
        self.imgWidth = width
        self.shader.projectionMatrix = GLKMatrix4MakeOrtho(0, Float(width), 0, Float(height), 0, 1)
        self.shader.color = GLKVector4Make(1.0, 0.0, 0.0, 1.0)
    }
}
