//
//  PlanarReflectionRenderer.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/24.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "PlanarReflectionRenderer.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES3/gl.h>
#include <vector>
#include <iostream>
#include "Shader.h"
#include "TextureHelper.h"
#import "matrixUtil.h"

@interface PlanarReflectionRenderer ()

@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLuint depthBuffer;

@property (nonatomic, assign) GLuint cubeVAOId;
@property (nonatomic, assign) GLuint cubeVBOId;

@property (nonatomic, assign) GLuint planeVAOId;
@property (nonatomic, assign) GLuint planeVBOId;

@property (nonatomic, assign) GLuint cubeTextureId;

@property (nonatomic, assign) Shader *planeShader;
@property (nonatomic, assign) Shader *shader;

@property (nonatomic, assign) GLint backingWidth;
@property (nonatomic, assign) GLint backingHeight;

@end

@implementation PlanarReflectionRenderer

- (void)initGLResource
{
    [super initGLResource];
    
    //构造帧缓冲区
    glGenFramebuffers(1, &_defaultFramebuffer);
    //构造渲染缓冲区
    glGenRenderbuffers(1, &_colorRenderbuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    //将_colorRenderbuffer渲染缓冲区关联到_defaultFramebuffer帧缓冲区的GL_COLOR_ATTACHMENT0上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
    
    //深度缓冲区+模板缓冲区
    glGenRenderbuffers(1, &_depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
    
    //构造顶点数据
    GLfloat cubeVertices[] = {
        -0.5f, -0.5f, 0.5f, 0.0f, 0.0f,    // A
        0.5f, -0.5f, 0.5f, 1.0f, 0.0f,    // B
        0.5f, 0.5f, 0.5f,1.0f, 1.0f,    // C
        0.5f, 0.5f, 0.5f,1.0f, 1.0f,    // C
        -0.5f, 0.5f, 0.5f,0.0f, 1.0f,    // D
        -0.5f, -0.5f, 0.5f,0.0f, 0.0f,    // A
        
        
        -0.5f, -0.5f, -0.5f,0.0f, 0.0f,    // E
        -0.5f, 0.5f, -0.5f,0.0, 1.0f,   // H
        0.5f, 0.5f, -0.5f,1.0f, 1.0f,    // G
        0.5f, 0.5f, -0.5f,1.0f, 1.0f,    // G
        0.5f, -0.5f, -0.5f,1.0f, 0.0f,    // F
        -0.5f, -0.5f, -0.5f,0.0f, 0.0f,    // E
        
        -0.5f, 0.5f, 0.5f,0.0f, 1.0f,    // D
        -0.5f, 0.5f, -0.5f,1.0, 1.0f,   // H
        -0.5f, -0.5f, -0.5f,1.0f, 0.0f,    // E
        -0.5f, -0.5f, -0.5f,1.0f, 0.0f,    // E
        -0.5f, -0.5f, 0.5f,0.0f, 0.0f,    // A
        -0.5f, 0.5f, 0.5f,0.0f, 1.0f,    // D
        
        0.5f, -0.5f, -0.5f,1.0f, 0.0f,    // F
        0.5f, 0.5f, -0.5f,1.0f, 1.0f,    // G
        0.5f, 0.5f, 0.5f,0.0f, 1.0f,    // C
        0.5f, 0.5f, 0.5f,0.0f, 1.0f,    // C
        0.5f, -0.5f, 0.5f, 0.0f, 0.0f,    // B
        0.5f, -0.5f, -0.5f,1.0f, 0.0f,    // F
        
        0.5f, 0.5f, -0.5f,1.0f, 1.0f,    // G
        -0.5f, 0.5f, -0.5f,0.0, 1.0f,   // H
        -0.5f, 0.5f, 0.5f,0.0f, 0.0f,    // D
        -0.5f, 0.5f, 0.5f,0.0f, 0.0f,    // D
        0.5f, 0.5f, 0.5f,1.0f, 0.0f,    // C
        0.5f, 0.5f, -0.5f,1.0f, 1.0f,    // G
        
        -0.5f, -0.5f, 0.5f,0.0f, 0.0f,    // A
        -0.5f, -0.5f, -0.5f, 0.0f, 1.0f,// E
        0.5f, -0.5f, -0.5f,1.0f, 1.0f,    // F
        0.5f, -0.5f, -0.5f,1.0f, 1.0f,    // F
        0.5f, -0.5f, 0.5f,1.0f, 0.0f,    // B
        -0.5f, -0.5f, 0.5f,0.0f, 0.0f,    // A
    };
    
    GLfloat planeVertices[] = {
        5.0f, -0.5f, 5.0f, 2.0f, 0.0f,   // A
        5.0f, -0.5f, -5.0f, 2.0f, 2.0f,  // D
        -5.0f, -0.5f, -5.0f, 0.0f, 2.0f, // C
        
        -5.0f, -0.5f, -5.0f, 0.0f, 2.0f, // C
        -5.0f, -0.5f, 5.0f, 0.0f, 0.0f,  // B
        5.0f, -0.5f, 5.0f, 2.0f, 0.0f,   // A
    };
    
    //生成VAO/VBO对象
    GLuint cubeVAOId, cubeVBOId;
    //创建VAO对象
    glGenVertexArrays(1, &cubeVAOId);
    glBindVertexArray(cubeVAOId);
    //创建VBO对象
    glGenBuffers(1, &cubeVBOId);
    glBindBuffer(GL_ARRAY_BUFFER, cubeVBOId);
    //为VBO对象填充数据，将数据由CPU提交至GPU
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), cubeVertices, GL_STATIC_DRAW);
    //设置顶点数据解析方式，告知GPU如何解析顶点数据以将数据传递给顶点着色器
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid *)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    //解绑VAO/VBO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    _cubeVAOId = cubeVAOId;
    _cubeVBOId = cubeVBOId;
    
    //平面
    GLuint planeVAOId, planeVBOId;
    glGenVertexArrays(1, &planeVAOId);
    glBindVertexArray(planeVAOId);
    glGenBuffers(1, &planeVBOId);
    glBindBuffer(GL_ARRAY_BUFFER, planeVBOId);
    glBufferData(GL_ARRAY_BUFFER, sizeof(planeVertices), planeVertices, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLvoid *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GL_FLOAT), (GLvoid*)(3 * sizeof(GL_FLOAT)));
    glEnableVertexAttribArray(1);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    _planeVAOId = planeVAOId;
    _planeVBOId = planeVBOId;
    
    NSString *cubeTexturePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/resources/textures/marble.jpg"];
    _cubeTextureId = TextureHelper::load2DTexture(cubeTexturePath.UTF8String);
    
    NSString *planeVertexPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/stencilTesting/planarReflection/shaders/singleColor.vert"];
    NSString *planeFragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/stencilTesting/planarReflection/shaders/singleColor.frag"];
    _planeShader = new Shader(planeVertexPath.UTF8String, planeFragPath.UTF8String);
    
    NSString *vertexPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/stencilTesting/planarReflection/shaders/stencilTest.vert"];
    NSString *fragPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"resource/OpenGLES/LearningFootprints/stencilTesting/planarReflection/shaders/stencilTest.frag"];
    _shader = new Shader(vertexPath.UTF8String, fragPath.UTF8String);
    
    //单纯地开启GL_DEPTH_TEST并没有起效果的原因是 - 没有分配深度缓冲区
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glEnable(GL_STENCIL_TEST);
}

- (void)render
{
    [super render];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    glClearColor(0.18f, 0.04f, 0.14f, 1.0f);
    glClearStencil(0);
    glClearDepthf(1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    GLfloat model[16];
    GLfloat view[16];
    GLfloat projection[16];
    
    mtxLoadIdentity(model);
    mtxLoadIdentity(view);
    mtxLoadIdentity(projection);
    
    GLfloat eyePos[3] = {0.0f, 0.0f, 4.0f};
    GLfloat target[3] = {0.0f, 0.0f, 0.0f};
    GLfloat viewUp[3] = {0.0f, 1.0f, 0.0f};
    mtxLoadLookAt(view, eyePos, target, viewUp);
    
    mtxLoadPerspective(projection, 60.0f, (float)_backingWidth / (float)_backingHeight, 1.0f, 100.0f);
    
    //为画plane做准备
    _planeShader->use();
    glUniformMatrix4fv(glGetUniformLocation(_planeShader->_programId, "model"), 1, GL_FALSE, model);
    glUniformMatrix4fv(glGetUniformLocation(_planeShader->_programId, "view"), 1, GL_FALSE, view);
    glUniformMatrix4fv(glGetUniformLocation(_planeShader->_programId, "projection"), 1, GL_FALSE, projection);
    
    //根据plane绘制到stencil
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
    glDepthMask(GL_FALSE);
    glStencilMask(0xFF);
    glStencilFunc(GL_ALWAYS, 1, 0xFF);
    glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
    glBindVertexArray(_planeVAOId);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    //为画反射物做准备
    _shader->use();
    glUniformMatrix4fv(glGetUniformLocation(_shader->_programId, "view"), 1, GL_FALSE, view);
    glUniformMatrix4fv(glGetUniformLocation(_shader->_programId, "projection"), 1, GL_FALSE, projection);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _cubeTextureId);
    mtxTranslateMatrix(model, 0.0f, 0.5f, 0.0f);
    mtxScaleMatrix(model, 1.0f, -1.0f, 1.0f);
    mtxTranslateMatrix(model, 0.0f, -0.5f, 0.0f);
    mtxTranslateMatrix(model, -0.7f, 0.0f, -1.0f);
    glUniformMatrix4fv(glGetUniformLocation(_shader->_programId, "model"), 1, GL_FALSE, model);
    
    //画第一个反射物
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glDepthMask(GL_TRUE);
    glStencilMask(0x00);
    glStencilFunc(GL_EQUAL, 1, 0xFF);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    glBindVertexArray(_cubeVAOId);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    //画第二个反射物体
    mtxLoadIdentity(model);
    mtxTranslateMatrix(model, 0.0f, 0.5f, 0.0f);
    mtxScaleMatrix(model, 1.0f, -1.0f, 1.0f);
    mtxTranslateMatrix(model, 0.0f, -0.5f, 0.0f);
    mtxTranslateMatrix(model, 0.7f, 0.0f, 0.0f);
    glUniformMatrix4fv(glGetUniformLocation(_shader->_programId, "model"), 1, GL_FALSE, model);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    //画plane
    _planeShader->use();
    glBindVertexArray(_planeVAOId);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_STENCIL_TEST);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glDisable(GL_BLEND);
    
    //为画cube做准备
    _shader->use();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _cubeTextureId);
    mtxLoadIdentity(model);
    mtxTranslateMatrix(model, -0.7f, 0.0f, -1.0f);
    glUniformMatrix4fv(glGetUniformLocation(_shader->_programId, "model"), 1, GL_FALSE, model);
    
    //画第一个cube
    glBindVertexArray(_cubeVAOId);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    mtxLoadIdentity(model);
    mtxTranslateMatrix(model, 0.7f, 0.0f, 0.0f);
    glUniformMatrix4fv(glGetUniformLocation(_shader->_programId, "model"), 1, GL_FALSE, model);
    //画第二个cube
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    
    
    
    glUseProgram(0);
    glBindVertexArray(0);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    //将渲染结果呈现出来
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL)resizeFromLayer:(id)layer
{
    [super resizeFromLayer:layer];
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    //设置layer为_colorRenderbuffer对应的缓冲区，渲染命令将会改变layer的图层存储
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    //深度缓冲区
    glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, _backingWidth, _backingHeight);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    return YES;
}

- (void)dealloc
{
    [EAGLContext setCurrentContext:self.context];
    
    glFlush();
    glFinish();
    
    if (_shader) {
        delete _shader;
        _shader = NULL;
    }
    
    if (_planeShader) {
        delete _planeShader;
        _planeShader = NULL;
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    if (_cubeTextureId) {
        glDeleteTextures(1, &_cubeTextureId);
        _cubeTextureId = 0;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    if (_planeVBOId) {
        glDeleteBuffers(1, &_planeVBOId);
        _planeVBOId = 0;
    }
    
    glBindVertexArray(0);
    if (_planeVAOId) {
        glDeleteVertexArrays(1, &_planeVAOId);
        _planeVAOId = 0;
    }
    
    if (_cubeVBOId) {
        glDeleteBuffers(1, &_cubeVBOId);
        _cubeVBOId = 0;
    }
    
    if (_cubeVAOId) {
        glDeleteVertexArrays(1, &_cubeVAOId);
        _cubeVAOId = 0;
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    if (_depthBuffer) {
        glDeleteRenderbuffers(1, &_depthBuffer);
        _depthBuffer = 0;
    }
    
    if (_colorRenderbuffer) {
        glDeleteRenderbuffers(1, &_colorRenderbuffer);
        _colorRenderbuffer = 0;
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    if (_defaultFramebuffer) {
        glDeleteFramebuffers(1, &_defaultFramebuffer);
        _defaultFramebuffer = 0;
    }
}

@end