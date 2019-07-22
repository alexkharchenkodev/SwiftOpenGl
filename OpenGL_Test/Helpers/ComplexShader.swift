//
//  BaseEffect.swift
//  OpenGL_Test
//

import GLKit
import Foundation

class ComplexShader: Base{
    var textureUniform : Int32 = 0
    var maskUniform : Int32 = 0
    var modeUniform: Int32 = 0
    
    var texture: GLuint = 0
    var mask : GLuint = 0
    var mode : GLint = 1
    var speed : GLuint = 3
    var strength : GLuint = 4
    
    override func prepareToDraw(){
        glUseProgram(self.programHandle)
        glUniformMatrix4fv(self.projectionMatrixUniform, 1, GLboolean(GL_FALSE), self.projectionMatrix.array)
        glUniformMatrix4fv(self.modelViewMatrixUniform, 1, GLboolean(GL_FALSE), self.modelViewMatrix.array)
        
        
        glActiveTexture(GLenum(GL_TEXTURE1))
        glBindTexture(GLenum(GL_TEXTURE_2D), self.texture)
        glUniform1i(self.textureUniform, 1)
        
//        glActiveTexture(GLenum(GL_TEXTURE0))
//        glBindTexture(GLenum(GL_TEXTURE_2D), self.mask)
//        glUniform1i(self.maskUniform, 0)
//
//        glUniform1i(self.modeUniform, self.mode)
        
        glUniform1f(GLint(self.speed), 10)
        glUniform2f(GLint(self.strength), 0.1, 0.8);
        print(self.timef)
        glUniform1f(GLint(self.time), UserDefaults.standard.float(forKey: "time"))
    }
    
    override func bindTime(time: Float) {
        print(time)
        glUniform1f(GLint(self.time), time)
    }
    
    override func compile(vertexShader: String, fragmentShader: String){
        
        attachShaders(vertexShader: vertexShader, fragmentShader: fragmentShader)
        glBindAttribLocation(self.programHandle, VertexAttributes.position.rawValue, "position")
        //glBindAttribLocation(self.programHandle, VertexAttributes.color.rawValue, "a_color")
        glBindAttribLocation(self.programHandle, VertexAttributes.texCoord.rawValue, "uv")
        
        glLinkProgram(self.programHandle)
        self.modelViewMatrixUniform = glGetUniformLocation(self.programHandle, "u_modelViewMatrix")
        self.projectionMatrixUniform = glGetUniformLocation(self.programHandle, "u_projectionMatrix")
        self.textureUniform = glGetUniformLocation(self.programHandle, "u_Texture")
       // self.maskUniform = glGetUniformLocation(self.programHandle, "u_Mask")
       // self.modeUniform = glGetUniformLocation(self.programHandle, "u_Mode")
        self.time = GLuint(glGetUniformLocation(self.programHandle, "time"))
        self.speed = GLuint(glGetUniformLocation(self.programHandle, "speed"))
        self.strength = GLuint(glGetUniformLocation(self.programHandle, "strength"))
        link()
    }
}
