#import "FunnelServerHandler.h"

@implementation FunnelServerHandler

@synthesize syphonServer = _syphonServer;
@synthesize frameTextureName = _frameTextureName;
@synthesize frameTextureRect = _frameTextureRect;

-(void)dealloc
{
    [_syphonServer release];
    [super dealloc];
}

@end
