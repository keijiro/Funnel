#import <Foundation/Foundation.h>
#import <Syphon/Syphon.h>

@interface FunnelServerHandler : NSObject
{
    SyphonServer *_syphonServer;
    NSRect _frameTextureRect;
    int _frameTextureName;
}

@property (retain, nonatomic) SyphonServer *syphonServer;
@property (assign) NSRect frameTextureRect;
@property (assign) int frameTextureName;

@end
