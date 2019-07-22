//
//  ShaderRoutines.swift
//  OpenGL_Test
//

import GLKit
import Foundation

class Base {
    var programHandle : GLuint = 0
    var modelViewMatrixUniform : Int32 = 0
    var projectionMatrixUniform : Int32 = 0
    var colorUniform: Int32 = 0
    var time : GLuint = 2
    var timef : Float = 0.1
    
    var modelViewMatrix : GLKMatrix4 = GLKMatrix4Identity
    var projectionMatrix : GLKMatrix4 = GLKMatrix4Identity
    var color: GLKVector4 = GLKVector4Make(0.0, 0.0, 1.0, 1.0)
    
    init(vertexShader: String, fragmentShader: String){
        self.compile(vertexShader: vertexShader, fragmentShader: fragmentShader)
    }
    
    func prepareToDraw(){
        glUseProgram(self.programHandle)
        glUniformMatrix4fv(self.projectionMatrixUniform, 1, GLboolean(GL_FALSE), self.projectionMatrix.array)
        glUniformMatrix4fv(self.modelViewMatrixUniform, 1, GLboolean(GL_FALSE), self.modelViewMatrix.array)
     //   glUniform1f(GLint(self.time), timef)
       // glUniform4fv(self.colorUniform, 1, self.color.array)
    }
    
    func bindTime(time: Float) {
        
    }

    //function to generate shader name
    func compileShader(_ shaderName: String, shaderType: GLenum) -> GLuint{
        let path = Bundle.main.path(forResource: shaderName, ofType: nil) ?? ""
        
        
        let shaderString = try? NSString.init(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
        let shaderHandle = glCreateShader(shaderType)
        
        if let shaderString = shaderString{
            
            var shaderStringLength: GLint = GLint(shaderString.length)
            var shaderCString = shaderString.utf8String
            glShaderSource(shaderHandle, GLsizei(1), &shaderCString, &shaderStringLength)
            glCompileShader(shaderHandle)
            var compileStatus: GLint = 0
            
            glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileStatus)
            
            if compileStatus == GL_FALSE{
                var infoLength: GLsizei = 0
                let bufferLength: GLsizei = 1024
                glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
                
                let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
                var actualLength : GLsizei = 0
                
                glGetShaderInfoLog(shaderHandle, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
                NSLog(String(validatingUTF8: info)!)
            }
        }
        
        return shaderHandle
    }
    
    
    func attachShaders(vertexShader: String, fragmentShader: String){
        let vertexShaderName = self.compileShader(vertexShader, shaderType: GLenum(GL_VERTEX_SHADER))
        let fragmentShaderName = self.compileShader(fragmentShader, shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        self.programHandle = glCreateProgram()
        glAttachShader(self.programHandle, vertexShaderName)
        glAttachShader(self.programHandle, fragmentShaderName)
    }
    
    func link(){
        var linkStatus : GLint = 0
        glGetProgramiv(self.programHandle, GLenum(GL_LINK_STATUS), &linkStatus)
        if linkStatus == GL_FALSE {
            var infoLength : GLsizei = 0
            let bufferLength : GLsizei = 1024
            glGetProgramiv(self.programHandle, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
            
            let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
            var actualLength : GLsizei = 0
            
            glGetProgramInfoLog(self.programHandle, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
            NSLog(String(validatingUTF8: info)!)
            exit(1)
        }
    }
    
    func compile(vertexShader: String, fragmentShader: String){
        
        attachShaders(vertexShader: vertexShader, fragmentShader: fragmentShader)
        glBindAttribLocation(self.programHandle, VertexAttributes.position.rawValue, "position")
        glBindAttribLocation(self.programHandle, VertexAttributes.texCoord.rawValue, "uv")
        glLinkProgram(self.programHandle)
        
        self.modelViewMatrixUniform = glGetUniformLocation(self.programHandle, "u_modelViewMatrix")
        self.projectionMatrixUniform = glGetUniformLocation(self.programHandle, "u_projectionMatrix")
        //self.colorUniform = glGetUniformLocation(self.programHandle, "u_Color")
        link()
    }
}

