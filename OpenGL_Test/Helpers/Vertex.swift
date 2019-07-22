//
//  Vertex.swift
//  OpenGL_Test
//

import GLKit

enum VertexAttributes : GLuint {
    case position = 0
    case color = 1
    case texCoord = 2
}

struct Vertex {
    var x : GLfloat
    var y : GLfloat
    var z : GLfloat
    
    var r : GLfloat
    var g : GLfloat
    var b : GLfloat
    var a : GLfloat
    
    var u : GLfloat
    var v : GLfloat
    
    
    init(_ x : GLfloat = 0.0, _ y : GLfloat = 0.0, _ z : GLfloat = 0.0, _ r : GLfloat = 1.0, _ g : GLfloat = 1.0, _ b : GLfloat = 1.0, _ a : GLfloat = 1.0, _ u : GLfloat = 0.0, _ v : GLfloat = 0.0) {
        self.x = x
        self.y = y
        self.z = z
        
        self.r = r
        self.g = g
        self.b = b
        self.a = a
        
        self.u = u
        self.v = v
    }
}
