#import <Foundation/Foundation.h>
#import <Syphon/Syphon.h>

@interface FunnelServerHandler : NSObject
{
    SyphonServer *_syphonServer;
    NSString *_serverName;
    NSRect _frameTextureRect;
    int _frameTextureName;
    BOOL _useSRGBBuffer;
}

@property (retain, nonatomic) SyphonServer *syphonServer;
@property (copy, nonatomic) NSString *serverName;
@property (assign) NSRect frameTextureRect;
@property (assign) int frameTextureName;
@property (assign) BOOL useSRGBBuffer;

@end
