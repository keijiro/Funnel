//
//  SyphonServerDrawingCoreProfile.m
//  Draws frame texture in the core profile mode
//
//  Originally created by Eduardo Roman on 1/26/15.
//  Modified by Keijiro Takahashi
//

#import "SyphonServerDrawingHelper.h"
#import "SyphonProgram.h"
#import <OpenGL/gl3.h>

@implementation SyphonServerDrawingHelper
{
    SyphonProgram* _syphonProgram;
    BOOL _initialized;
    GLuint _vao;
    GLuint _vbo;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _syphonProgram = [[SyphonProgram alloc] init];
        if (_syphonProgram == nil) self = nil;
    }
    return self;
}

- (void)setup
{
    // Create a VAO.
    glGenVertexArrays(1, &_vao);
    glBindVertexArray(_vao);
    
    // Create a VBO with a quad.
    glGenBuffers(1, &_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    
    static const float varray[] = {0, 0, 1, 0, 0, 1, 1, 1};
    glBufferData(GL_ARRAY_BUFFER, 4 * 2 * sizeof(GLfloat), varray, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, 0);
    glEnableVertexAttribArray(0);
    
    _initialized = YES;
}

- (void)drawFrameTexture:(GLuint)texID surfaceSize:(NSSize)surfaceSize discardAlpha:(BOOL)discardAlpha
{
    // Initialize with the GL context if not yet.
    if (!_initialized) [self setup];
    
    // Set up the program.
    _syphonProgram.discardAlpha = discardAlpha;
    [_syphonProgram use];
    
    // Set up the other states.
    glViewport(0, 0, surfaceSize.width, surfaceSize.height);
    glDisable(GL_BLEND);
    glDisable(GL_CULL_FACE);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texID);
    glBindVertexArray(_vao);
    
    // Draw the screen quad.
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
