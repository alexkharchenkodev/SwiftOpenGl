//
//  FBO.swift
//  OpenGL_Test
//

import GLKit

class FBO{
    //FBO & texture
    var framebuffer: GLuint = 0
    var texture: GLuint = 0
    var oldFbo: GLint = 0
    var oldTexture: GLint = 0
    var imgWidth: GLsizei = 1600
    var imgHeight: GLsizei = 900
    
    
    init(width: GLsizei, height: GLsizei){
        self.imgWidth = width
        self.imgHeight = height
        
        //remembring old fbo & old texture
        glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &oldFbo)
        glGetIntegerv(GLenum(GL_TEXTURE_BINDING_2D), &oldTexture)
        
        //creating framebuffer and binding it
        glGenFramebuffers(1, &framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
        
        glGenTextures(1, &texture)
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, width, height, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), nil)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), texture, 0)
        
        
        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        if(status != GL_FRAMEBUFFER_COMPLETE) {
            print("failed to make complete framebuffer object \(status)")
        }
        
        glBindTexture(GLenum(GL_TEXTURE_2D), GLuint(oldTexture))
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), GLuint(oldFbo))
    }
    
    private func bindBuffer(){
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), GLuint(framebuffer))
        glBindTexture(GLenum(GL_TEXTURE_2D), GLuint(texture))
    }
    
    private func bindOldBuffer(){
        glBindTexture(GLenum(GL_TEXTURE_2D), GLuint(oldTexture))
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), GLuint(oldFbo))
    }
    
    private func fillWithColor(r: GLclampf, g: GLclampf, b: GLclampf, a: GLclampf){
        glClearColor(r, g, b, a)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    func drawToFramebuffer(objects: [BaseModel]){
        bindBuffer()
        fillWithColor(r: 1, g: 1, b: 1, a: 1)
        glViewport(0, 0, imgWidth, imgHeight)
        for object in objects{
            object.renderWithParentModelViewMatrix()
        }
        bindOldBuffer()
    }
}


