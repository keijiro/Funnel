//
//  SyphonProgram.m
//  Provides a program object used in the core profile mode
//
//  Originally created by Eduardo Roman on 1/26/15.
//  Modified by Keijiro Takahashi
//

#import <Foundation/Foundation.h>
#import <OpenGL/gltypes.h>

@interface SyphonProgram : NSObject

@property (readonly) GLint program;
@property (assign) BOOL discardAlpha;

-(void)use;

@end
