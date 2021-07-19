#import "BMDSwitcher.h"

@implementation BMDSwitcher
{
}

+ (unsigned int)connect {
    IBMDSwitcherDiscovery* discovery = CreateBMDSwitcherDiscoveryInstance();
    IBMDSwitcher* switcher;
    BMDSwitcherConnectToFailure connectToFailReason;
    discovery->ConnectTo(CFSTR("192.168.10.240"), &switcher, &connectToFailReason);
    discovery->Release();
    return connectToFailReason;
}
@end
