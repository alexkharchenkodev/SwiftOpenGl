//
//  ViewController.swift
//  OpenGL_Test
//

import UIKit
import GLKit
import Photos

class ViewController: UIViewController {
    
    @IBOutlet var rotationGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var gestureRecognizer: UIPanGestureRecognizer!

    @IBOutlet weak var glkView: GLKView!
    @IBOutlet weak var btnMode: UIButton!
    
    var model:Model!
    var oglQueue:DispatchQueue!
    var imagePicker: UIImagePickerController!
    var glTextureLoader:GLKTextureLoader!
    var glShareGroup:EAGLSharegroup!
    typealias drawCall = () -> Void
    var drawCalls:[drawCall]!
    
    var picture:ObjectModel!
    var shader :ComplexShader!
    var maskFBO: FBO!
    
    var lastTranslation: CGPoint = CGPoint(x: 0, y: 0)
    var lastRotation: Float = 0.0
    var lastScaleX: Float = 1.0
    var lastScaleY: Float = 1.0
    
    var square: BaseModel!
  //  var triangle: BaseModel!
    var maskObjects:[BaseModel]!
    var selectedObject: BaseModel!
    
    var playMode: PlayMode = .stop
    
    private var time : Float = 0
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = Model()
        oglQueue = DispatchQueue.global(qos: .background)
        imagePicker = UIImagePickerController()
        configurateImagePicker()
        configureGlkitView()
        setupShader()
        scheduledTimerWithTimeInterval()
        drawCalls = []
        gestureRecognizer.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: Selector(("updateCounting")), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        if (playMode == .play) {
            time += 0.1
            UserDefaults.standard.set(time, forKey: "time")
            drawCalls.append {
                self.picture.renderWithParentModelViewMatrix()
            }
            glkView.setNeedsDisplay()
        }
    }
    
    func configureGlkitView(){
        glkView.delegate = self
        glkView.context = EAGLContext(api: .openGLES3) ?? EAGLContext(api: .openGLES2)!
        EAGLContext.setCurrent(glkView.context)
        glkView.drawableColorFormat = .RGBA8888
        
        glTextureLoader = GLKTextureLoader(sharegroup: glkView.context.sharegroup)
        glkView.enableSetNeedsDisplay = true
        drawCalls = []
    }
    
    func configurateImagePicker(){
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
    }
    
    func setupShader() {
        self.shader = ComplexShader(vertexShader: "ComplexVertex.glsl", fragmentShader: "ComplexFragment.glsl")
        shader.projectionMatrix = GLKMatrix4MakeOrtho(0, Float(glkView.bounds.width), 0, Float(glkView.bounds.height), 0, 1)
    }
    
    func fillWithColor(r: GLclampf, g: GLclampf, b: GLclampf, a: GLclampf){
        glClearColor(r, g, b, a)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    func renderTexture(from image: CGImage){
        do{
            let info = try GLKTextureLoader.texture(with: image, options: [GLKTextureLoaderOriginBottomLeft: true])
            picture.loadTexture(name: info.name)
            picture.mask = maskFBO.texture
            
            drawCalls.append {
                self.picture.renderWithParentModelViewMatrix()
            }
            glkView.setNeedsDisplay()
        }
        catch{
            print(error)
        }
    }
}

//MARK: buttons actions
extension ViewController {
    @IBAction func saveBtnPressed(_ sender: Any) {
        if let _ = model.image{
            var canvasFrameBuffer: GLuint = 0
            var canvasRenderBuffer: GLuint = 0
            
            glGenFramebuffers(1, &canvasFrameBuffer)
            glBindFramebuffer(GLenum(GL_FRAMEBUFFER), canvasFrameBuffer)
            glGenRenderbuffers(1, &canvasRenderBuffer)
            glBindRenderbuffer(GLenum(GL_RENDERBUFFER), canvasRenderBuffer)
            
            glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_RGBA8), maskFBO.imgWidth, maskFBO.imgHeight)
            glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER),GLenum(GL_COLOR_ATTACHMENT0) , GLenum(GL_RENDERBUFFER), canvasRenderBuffer)
            glViewport(0, 0, maskFBO.imgWidth, maskFBO.imgHeight)
            fillWithColor(r: 0, g: 0, b: 0, a: 1)
            let oldProjection = picture.shader.projectionMatrix
            let oldScaleX = picture.scaleX
            let oldScaleY = picture.scaleY
            let oldPosition = picture.position
            picture.shader.projectionMatrix = GLKMatrix4MakeOrtho(0, Float(maskFBO.imgWidth), 0, Float(maskFBO.imgHeight), 0, 1)
            picture.scaleX = Float(maskFBO.imgWidth)
            picture.scaleY = Float(maskFBO.imgHeight)
            picture.position = GLKVector3Make(0, 0, 0)
            picture.renderWithParentModelViewMatrix()
            
            
            
            let x = 0
            let y = 0
            let dataLength = Int(maskFBO.imgWidth) * Int(maskFBO.imgHeight) * 4
            let pixels: UnsafeMutableRawPointer = malloc(dataLength * MemoryLayout<GLubyte>.size)

            
            glPixelStorei(GLenum(GL_PACK_ALIGNMENT), 4)
            glReadPixels(GLint(x), GLint(y), maskFBO.imgWidth, maskFBO.imgHeight, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), pixels)
            let pixelData: UnsafePointer = (UnsafeRawPointer(pixels)?.assumingMemoryBound(to: UInt8.self))!
            let cfdata: CFData = CFDataCreate(kCFAllocatorDefault, pixelData, dataLength * MemoryLayout<GLubyte>.size)
            let provider: CGDataProvider! = CGDataProvider(data: cfdata)
            let colorspace: CGColorSpace  = CGColorSpaceCreateDeviceRGB()
            
            let iref: CGImage? = CGImage(width: Int(maskFBO.imgWidth), height: Int(maskFBO.imgHeight), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: Int(maskFBO.imgWidth)*4, space: colorspace, bitmapInfo: CGBitmapInfo.byteOrder32Big, provider: provider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
            UIGraphicsBeginImageContext(CGSize(width: CGFloat(maskFBO.imgWidth), height: CGFloat(maskFBO.imgHeight)))
            
            let cgcontext: CGContext? = UIGraphicsGetCurrentContext()
            cgcontext!.setBlendMode(CGBlendMode.copy)
            cgcontext!.draw(iref!, in: CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(maskFBO.imgWidth), height: CGFloat(maskFBO.imgHeight)))
            let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            Model.save(image: image)
            
            glBindRenderbuffer(GLenum(GL_RENDERBUFFER), 0)
            glBindFramebuffer(GLenum(GL_FRAMEBUFFER), GLuint(maskFBO.oldFbo))
            glDeleteRenderbuffers(1, &canvasRenderBuffer)
            glDeleteFramebuffers(1, &canvasFrameBuffer)
            
            picture.shader.projectionMatrix = oldProjection
            picture.scaleX = oldScaleX
            picture.scaleY = oldScaleY
            picture.position = oldPosition
        }
    }
    
    
    @IBAction func modeBtnPressed(_ sender: Any) {
        if let _ = model.image{
            if (playMode == .stop) {
                playMode = .play
                time = 0.0
                btnMode.setImage(UIImage(named: "stop"), for: .normal)
            } else {
                playMode = .stop
                btnMode.setImage(UIImage(named: "play"), for: .normal)
            }
//            model.switchMode()
//            shader.mode = model.mode.rawValue
        }
    }
    
    @IBAction func openBtnPressed(_ sender: Any) {
        model.loadImage()
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            checkPermission()
            if PHPhotoLibrary.authorizationStatus() == .authorized {
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    func checkPermission() {
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
            case .authorized: print("Access is granted by user")
        case .notDetermined: PHPhotoLibrary.requestAuthorization({(newStatus) in
            print("status is \(newStatus)")
            if newStatus == PHAuthorizationStatus.authorized {
                print("success")
            }
        })
        case .restricted:
            print("User do not have access to photo album.")
        case .denied:
            print("User has denied the permission.")
        }
    }
}

extension ViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            var maxTextureSize: GLint = 0
            glGetIntegerv(GLenum(GL_MAX_TEXTURE_SIZE), &maxTextureSize)
            var scaledImage: UIImage = img
            if maxTextureSize < GLint(max(img.size.width, img.size.height)){
                scaledImage = UIImage.resizedImageWithinRect(img, rectSize: CGSize(width: Int(maxTextureSize), height: Int(maxTextureSize)))
            }
            
            model.image = scaledImage
            if let image = model.image{
                let windowScale = Float(min((glkView.bounds.width / image.size.width), (glkView.bounds.height / image.size.height)))
                picture = Square(shader: shader)
                picture.scaleX = Float(image.size.width) * windowScale
                picture.scaleY = Float(image.size.height) * windowScale
                picture.position = GLKVector3Make(0, (Float(glkView.bounds.height) - Float(image.size.height) * windowScale) / 2.0,0)
                shader.mode = model.mode.rawValue
                
                maskFBO = FBO(width: GLsizei(image.size.width), height: GLsizei(image.size.height))
                square = SquareMask(width: maskFBO.imgWidth, height: maskFBO.imgHeight)
                selectedObject = square
                maskObjects = [square]
                maskFBO.drawToFramebuffer(objects: maskObjects)
            }
        }
        self.dismiss(animated: true, completion: { self.renderTexture(from: (self.model.image?.cgImage)!)})
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ViewController:GLKViewDelegate{
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        fillWithColor(r: 0.0, g: 0.0, b: 0.0, a: 1.0)
        let lastCall = drawCalls.popLast()
        if let call = lastCall{
            call()
        }
    }

}

extension ViewController : UIGestureRecognizerDelegate{
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            if gestureRecognizer.state == .began {
                lastTranslation = CGPoint.zero
            }
            
            if let img = model.image{
                let windowScale = Float(min((glkView.bounds.width / img.size.width), (glkView.bounds.height / img.size.height)))
                    let translation = gestureRecognizer.translation(in: self.glkView)
                    print("translation \(translation)")
                    let newPosition = GLKVector3Make(selectedObject.position.x + Float(translation.x - lastTranslation.x) / windowScale,
                                                     selectedObject.position.y - Float(translation.y - lastTranslation.y) / windowScale,
                                                     0)
                    lastTranslation.x = translation.x
                    lastTranslation.y = translation.y
                    
                    selectedObject.position = newPosition
                    maskFBO.drawToFramebuffer(objects: maskObjects)
                    picture.mask = maskFBO.texture
                    
                    drawCalls.append {
                        self.picture.renderWithParentModelViewMatrix()
                    }
                    glkView.setNeedsDisplay()
            }
        }
    }
    
    @IBAction func handleRotationGesture(_ sender: UIRotationGestureRecognizer) {
        if sender.state == .began{
            lastRotation = 0.0
        }
        if sender.state == .changed {
            if let _ = model.image {
                selectedObject.rotationZ = selectedObject.rotationZ - (Float(sender.rotation) - lastRotation)
                maskFBO.drawToFramebuffer(objects: maskObjects)
                lastRotation = Float(sender.rotation)
            }
            
            picture.mask = maskFBO.texture
            drawCalls.append {
                self.picture.renderWithParentModelViewMatrix()
            }
            glkView.setNeedsDisplay()
        }
    }
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            lastScaleX = selectedObject.scaleX
            lastScaleY = selectedObject.scaleY
        }
        if sender.state == .changed {
            if let _ = model.image {
                print(sender.scale)
                selectedObject.scaleX = lastScaleX * Float(sender.scale)
                selectedObject.scaleY = lastScaleY * Float(sender.scale)
                maskFBO.drawToFramebuffer(objects: maskObjects)
                
                
            }

            picture.mask = maskFBO.texture
            drawCalls.append {
                self.picture.renderWithParentModelViewMatrix()
            }
            glkView.setNeedsDisplay()
        }
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let img = model.image{
                let windowScale = Float(min((glkView.bounds.width / img.size.width), (glkView.bounds.height / img.size.height)))
                let imgOrigin = CGPoint(x: 0.0, y: (glkView.bounds.height - img.size.height * CGFloat(windowScale)) / 2.0)
                
                
                
                var location = sender.location(in: glkView)
                location.y = glkView.bounds.height - location.y
                print("Tap location \(location)")
                
                
                
                for object in maskObjects{
                    //imageOrigin + base position (so, moving up from the origin)
                    let rectOriginY = imgOrigin.y +  CGFloat(object.position.y * windowScale)
                    let rectOriginX = CGFloat(object.position.x * windowScale) - CGFloat(object.scaleX / 2.0 * windowScale)
                    let rect = CGRect(x: rectOriginX, y: rectOriginY,
                                      width: CGFloat(object.scaleX * windowScale), height: CGFloat(object.scaleY * windowScale))
                    
                    print(rect)
                    if locationInRectangle(location: location, rectangle: rect){
                        selectedObject = object
                        return
                    }
                }
            }
        }
    }

    
    func locationInRectangle(location: CGPoint, rectangle: CGRect) -> Bool{
        var check = rectangle.origin.x - 10 <= location.x
        check = check && rectangle.origin.y + 10 >= location.y
        check = check && rectangle.width + rectangle.origin.x + 10 >= location.x
        check = check &&  rectangle.origin.y - rectangle.height - 10 <= location.y
        return check
    }
}

