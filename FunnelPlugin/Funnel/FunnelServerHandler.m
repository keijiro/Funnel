#import "FunnelServerHandler.h"

@implementation FunnelServerHandler

@synthesize syphonServer = _syphonServer;
@synthesize serverName = _serverName;
@synthesize frameTextureName = _frameTextureName;
@synthesize frameTextureRect = _frameTextureRect;
@synthesize useSRGBBuffer = _useSRGBBuffer;

-(void)dealloc
{
    [_syphonServer release];
    [_serverName release];
    [super dealloc];
}

@end
