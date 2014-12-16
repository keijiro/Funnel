#import "FunnelServerHandler.h"

@implementation FunnelServerHandler

@synthesize syphonServer = _syphonServer;
@synthesize serverName = _serverName;
@synthesize frameTextureName = _frameTextureName;
@synthesize frameTextureRect = _frameTextureRect;
@synthesize useSRGBBuffer = _useSRGBBuffer;
@synthesize discardAlphaChannel = _discardAlphaChannel;

-(void)dealloc
{
    [_syphonServer release];
    [_serverName release];
    [super dealloc];
}

-(NSDictionary *)serverOptions
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:_useSRGBBuffer], SyphonServerOptionUseSRGBBuffer,
            [NSNumber numberWithBool:_discardAlphaChannel], SyphonServerOptionDiscardAlphaChannel,
            nil];
}

@end
