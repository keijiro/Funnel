#import <Foundation/Foundation.h>
#import <Syphon/Syphon.h>

@interface FunnelServerHandler : NSObject
{
    SyphonServer *_syphonServer;
    NSString *_serverName;
    NSRect _frameTextureRect;
    int _frameTextureName;
}

@property (retain, nonatomic) SyphonServer *syphonServer;
@property (copy, nonatomic) NSString *serverName;
@property (assign) NSRect frameTextureRect;
@property (assign) int frameTextureName;

@end
