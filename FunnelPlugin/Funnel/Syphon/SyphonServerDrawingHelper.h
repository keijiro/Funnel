#import <Foundation/Foundation.h>
#import <OpenGL/gltypes.h>

@interface SyphonServerDrawingHelper : NSObject

- (void)drawFrameTexture:(GLuint)texID surfaceSize:(NSSize)surfaceSize discardAlpha:(BOOL)discardAlpha;

@end
