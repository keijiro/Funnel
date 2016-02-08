#import <Foundation/Foundation.h>
#import "Syphon/Syphon.h"

@interface FunnelServerHandler : NSObject
{
    SyphonServer *_syphonServer;
    NSString *_serverName;
    NSRect _frameTextureRect;
    int _frameTextureName;
    BOOL _useSRGBBuffer;
    BOOL _discardAlphaChannel;
}

@property (retain, nonatomic) SyphonServer *syphonServer;
@property (copy, nonatomic) NSString *serverName;
@property (copy, nonatomic) NSDictionary *serverOptions;
@property (assign) NSRect frameTextureRect;
@property (assign) int frameTextureName;
@property (assign) BOOL useSRGBBuffer;
@property (assign) BOOL discardAlphaChannel;

@end
