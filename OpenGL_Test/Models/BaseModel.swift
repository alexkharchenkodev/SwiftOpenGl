//
//  BaseModel.swift
//  OpenGL_Test
//

import GLKit

class BaseModel {
    var shader: Base!
    var name: String!
    var vertices: [Vertex]!
    var vertexCount: GLuint!
    var indices: [GLubyte]!
    var indexCount: GLuint!
    
    var vao: GLuint = 0
    var vertexBuffer: GLuint = 0
    var indexBuffer: GLuint = 0
    
    // ModelView Transformation
    var position: GLKVector3 = GLKVector3Make(0.0, 0.0, 0.0)
    var rotationX : Float = 0.0
    var rotationY : Float = 0.0
    var rotationZ : Float = 0.0
    var scaleX : Float = 1.0
    var scaleY : Float = 1.0
    var scaleZ : Float = 1.0
    
    init(name: String, shader: Base, vertices: [Vertex], indices: [GLubyte]) {
        self.name = name
        self.shader = shader
        self.vertices = vertices
        self.vertexCount = GLuint(vertices.count)
        self.indices = indices
        self.indexCount = GLuint(indices.count)
        
        startSettingUpVAO()
        setupVertexBuffer(for: vertices, buffer: &vertexBuffer, type: GLenum(GL_ARRAY_BUFFER))
        setupVertexBuffer(for: indices, buffer: &indexBuffer, type: GLenum(GL_ELEMENT_ARRAY_BUFFER))
        setupAttributes()
        finishSettingUpVAO()
    }
    
    func setupVertexBuffer<Element>(for arr:[Element], buffer: inout GLuint, type:  GLenum) {
        //generate buffer object names: (number of names, array to store generated buffers)
        glGenBuffers(GLsizei(1), &buffer)
        //bind a named buffer object: (target, name of the buffer object)
        glBindBuffer(type, buffer)
        
        //number of vertices to draw
        let count = arr.count
        //size of each vertex
        let size =  MemoryLayout<Element>.size
        
        //create and initialize a buffer object's data store
        //(target, size of the store in bytes, data to copy, expected usage)
        glBufferData(type, count * size, arr, GLenum(GL_STATIC_DRAW))
    }
    
    func startSettingUpVAO(){
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)
    }
    
    func finishSettingUpVAO(){
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
    }
    
    func setupAttributes(){
        glEnable(GLenum(GL_BLEND))
        
        //enable generic vertex attribute array: (index of the vertex attribute)
        glEnableVertexAttribArray(VertexAttributes.position.rawValue)
        
        //Define an array of generic vertex attribute data: (index, size, type, normalized, stride, pointer)
        glVertexAttribPointer(VertexAttributes.position.rawValue, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(0))
        
        glEnableVertexAttribArray(VertexAttributes.color.rawValue)
        glVertexAttribPointer(VertexAttributes.color.rawValue, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(3 * MemoryLayout<GLfloat>.size))
        
        glEnableVertexAttribArray(VertexAttributes.texCoord.rawValue)
        glVertexAttribPointer(VertexAttributes.texCoord.rawValue, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET((3+4) * MemoryLayout<GLfloat>.size)) // x, y, z | r, g, b, a | u, v :: offset is (3+4)*sizeof(GLfloat)
    }
    
    
    func renderWithParentModelViewMatrix(_ parentModelViewMatrix: GLKMatrix4 = GLKMatrix4Identity) {
        let modelViewMatrix : GLKMatrix4 = GLKMatrix4Multiply(parentModelViewMatrix, generateModelMatrix())
        shader.modelViewMatrix = modelViewMatrix
        shader.timef = position.x / 100
        shader.bindTime(time: position.x / 100)
        shader.prepareToDraw()
        glBindVertexArrayOES(vao)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glBindVertexArrayOES(0)
    }
    
    func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
        return UnsafeRawPointer(bitPattern: n)
    }
    
    func generateModelMatrix() -> GLKMatrix4 {
        var modelMatrix : GLKMatrix4 = GLKMatrix4Identity
        modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, self.position.z)
        modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationX, 1, 0, 0)
        modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationY, 0, 1, 0)
        modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationZ, 0, 0, 1)
        modelMatrix = GLKMatrix4Scale(modelMatrix, self.scaleX, self.scaleY, self.scaleZ)
        return modelMatrix
    }
}

