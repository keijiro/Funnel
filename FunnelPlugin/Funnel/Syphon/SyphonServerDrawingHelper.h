#import <Foundation/Foundation.h>

@interface SyphonServerDrawingHelper : NSObject

- (void)drawFrameTexture:(GLuint)texID surfaceSize:(NSSize)surfaceSize inContex:(CGLContextObj)context discardAlpha:(BOOL)discardAlpha;

@end
