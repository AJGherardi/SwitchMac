#import "BMDSwitcher.h"

@implementation InputStatus

@end

@implementation BMDSwitcher {
    IBMDSwitcher *switcher;
}

- (unsigned int)connect:(NSString *)addr {
    IBMDSwitcherDiscovery *discovery = CreateBMDSwitcherDiscoveryInstance();
    BMDSwitcherConnectToFailure connectToFailReason;
    discovery->ConnectTo((__bridge CFStringRef) addr, &switcher, &connectToFailReason);
    discovery->Release();
    return connectToFailReason;
}

- (NSArray<InputStatus *> *)getInputs {
    HRESULT result;
    IBMDSwitcherInputIterator *inputIterator = NULL;

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
            BMDSwitcherInputId *inputId = NULL;
            bool *preview = NULL;
            bool *program = NULL;

            // Get tally info and id
            input->IsPreviewTallied(preview);
            input->IsProgramTallied(program);
            input->GetInputId(inputId);

            // Release input for next iteration
            input->Release();

            // Create status object
            InputStatus *status = [[InputStatus alloc] init];
            status.inputId = *inputId;
            status.isPreview = *preview;
            status.isProgram = *program;
            [statuses addObject:status];
        }

        // Release input iterator
        inputIterator->Release();
        inputIterator = NULL;
    }
    return statuses;
}

@end
