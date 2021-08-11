#import "BMDSwitcher.h"


@implementation InputStatus

@end

@implementation BMDSwitcher {
    IBMDSwitcher *switcher;
}

- (unsigned int)connect:(NSString *)addr {
    HRESULT result;

    IBMDSwitcherDiscovery *discovery = CreateBMDSwitcherDiscoveryInstance();
    BMDSwitcherConnectToFailure connectToFailReason;
    result = discovery->ConnectTo((__bridge CFStringRef) addr, &switcher, &connectToFailReason);
    discovery->Release();
    if (result != S_OK) {
        connectToFailReason = 0;
    }

    return connectToFailReason;
}

- (NSArray<InputStatus *> *)getInputs {
    HRESULT result;
    IBMDSwitcherInputIterator *inputIterator;

    // Make sure that a switcher object has been obtained
    if (switcher == NULL) {
        return NULL;
    }

    // Storage for status objects
    NSMutableArray<InputStatus *> *statuses = [NSMutableArray array];

    // Get input iterator
    result = switcher->CreateIterator(IID_IBMDSwitcherInputIterator, (void **) &inputIterator);

    // For each input get status and id
    if SUCCEEDED(result) {
        IBMDSwitcherInput *input = NULL;

        // Iterate though all inputs
        while (S_OK == inputIterator->Next(&input)) {
            // Storage for tally and id info
            BMDSwitcherInputId inputId;
            bool preview;
            bool program;

            // Get tally info and id
            input->GetInputId(&inputId);
            input->IsPreviewTallied(&preview);
            input->IsProgramTallied(&program);
            // Release input for next iteration
            input->Release();

            // Create status object if all needed values are provided
            if (inputId != NULL || preview != NULL || program != NULL) {
                InputStatus *status = [[InputStatus alloc] init];
                status.inputId = inputId;
                status.isPreview = preview;
                status.isProgram = program;
                [statuses addObject:status];
            }
        }

        // Release input iterator
        inputIterator->Release();
        inputIterator = NULL;
    }
    return statuses;
}

@end
