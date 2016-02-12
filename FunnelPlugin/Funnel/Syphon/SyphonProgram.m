//
//  SyphonProgram.m
//  Provides a program object used in the core profile mode
//
//  Originally created by Eduardo Roman on 1/26/15.
//  Modified by Keijiro Takahashi
//

#import "SyphonProgram.h"
#import <OpenGL/gl3.h>

#pragma mark Utility macros

#define SHADER_STRING(text) @"#version 150\n"#text

#pragma mark
#pragma mark Shader code

NSString *const vertexShaderString = SHADER_STRING(
    in vec2 position;
    out vec2 texcoord;

    void main(void)
    {
        texcoord = position;
        gl_Position = vec4(2 * position.x - 1, 1 - 2 * position.y, 1, 1);
    }
);

// Fragment shader code
NSString *const fragmentShaderString = SHADER_STRING(
    uniform sampler2D color;
    uniform float alpha;

    in vec2 texcoord;
    out vec4 frag_color;

    void main(void)
    {
        vec2 uv = vec2(texcoord.x, 1 - texcoord.y);
        vec4 col = texture(color, uv);
        col.a = mix(col.a, 1, alpha); // discards alpha when alpha == 1
        frag_color = col;
    }
);

// Initialize a shader with a given source.
static GLint InitShader(GLenum type, NSString* source)
{
    GLint shader = glCreateShader(type);
    const char* raw_source = [source cStringUsingEncoding:NSUTF8StringEncoding];
    
    glShaderSource(shader, 1, &raw_source, NULL);
    glCompileShader(shader);
    
    GLint res;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &res);
    if (res == GL_TRUE) return shader;
    
    // show error message
    GLchar info_raw[1024];
    glGetShaderInfoLog(shader, sizeof(info_raw), NULL, info_raw);
    NSString* info = [NSString stringWithCString:info_raw encoding:NSUTF8StringEncoding];
    NSLog(@"Shader compilation error: %@", info);
    return 0;
}

// Validate a program
static BOOL ValidateProgram(GLint program)
{
    glValidateProgram(program);
    
    GLint res;
    glGetProgramiv(program, GL_VALIDATE_STATUS, &res);
    if (res == GL_TRUE) return YES;
    
    // show error message
    GLchar info_raw[1024];
    glGetProgramInfoLog(program, sizeof(info_raw), NULL, info_raw);
    NSString* info = [NSString stringWithCString:info_raw encoding:NSUTF8StringEncoding];
    NSLog(@"Program validation error: %@", info);
    return 0;
}

#pragma mark
#pragma mark Class Implementation

@implementation SyphonProgram {
    BOOL _initialized;
    GLint _vertexShader;
    GLint _fragmentShader;
    GLint _program;
    BOOL _discardAlpha;
    GLuint _colorLocation;
    GLuint _alphaLocation;
}

@synthesize program = _program;
@synthesize discardAlpha = _discardAlpha;

- (void)setup
{
    _vertexShader = InitShader(GL_VERTEX_SHADER, vertexShaderString);
    _fragmentShader = InitShader(GL_FRAGMENT_SHADER, fragmentShaderString);
    
    _program = glCreateProgram();
    glAttachShader(_program, _vertexShader);
    glAttachShader(_program, _fragmentShader);
    glLinkProgram(_program);
    
    if (ValidateProgram(_program))
    {
        glBindFragDataLocation(_program, 0, "o_frag_color");
        _colorLocation = glGetUniformLocation(_program, "color");
        _alphaLocation = glGetUniformLocation(_program, "alpha");
    }
    
    _initialized = YES;
}

- (void)use
{
    if (!_initialized) [self setup];
    
    glUseProgram(_program);
    glUniform1i(_colorLocation, 0);
    glUniform1f(_alphaLocation, _discardAlpha ? 1 : 0);
}

@end
