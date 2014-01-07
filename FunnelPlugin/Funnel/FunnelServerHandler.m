#import "FunnelServerHandler.h"

@implementation FunnelServerHandler

@synthesize syphonServer = _syphonServer;
@synthesize serverName = _serverName;
@synthesize frameTextureName = _frameTextureName;
@synthesize frameTextureRect = _frameTextureRect;

-(void)dealloc
{
    [_syphonServer release];
    [_serverName release];
    [super dealloc];
}

@end
