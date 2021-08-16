#import "BMDSwitcher.h"

// Helper function for comparing IIDs in the COM model
static inline bool operator==(const REFIID &iid1, const REFIID &iid2) {
    return CFEqual(&iid1, &iid2);
}

// C++ class that implements IBMDSwitcherInputCallback COM class
// Calls a passed callback
class InputMonitor : public IBMDSwitcherInputCallback {
public:
    // Constructor for InputMonitor class
    InputMonitor(IBMDSwitcherInput *input, void(^callback)(InputStatus *))
            : mInput(input), mRefCount(1), mCallback(callback) {
        mInput->AddRef();
        mInput->AddCallback(this);
    }

protected:
    // Destructure for InputMonitor class
    ~InputMonitor() {
        mInput->RemoveCallback(this);
        mInput->Release();
    }

public:
    // QueryInterface, AddRef, Release implement the IUnknown interface

    // Implements casting for this class (for inheritance)
    HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, LPVOID *ppv) {
        if (!ppv)
            return E_POINTER;

        // Cast to this class
        if (iid == IID_IBMDSwitcherInputCallback) {
            *ppv = static_cast<IBMDSwitcherInputCallback *>(this);
            AddRef();
            return S_OK;
        }

        // Cast to parent interface
        if (CFEqual(&iid, IUnknownUUID)) {
            *ppv = static_cast<IUnknown *>(this);
            AddRef();
            return S_OK;
        }

        *ppv = NULL;
        return E_NOINTERFACE;
    }

    ULONG STDMETHODCALLTYPE AddRef(void) {
        return static_cast<ULONG>(::OSAtomicIncrement32(&mRefCount));
    }

    ULONG STDMETHODCALLTYPE Release(void) {
        int newCount = ::OSAtomicDecrement32(&mRefCount);
        if (newCount == 0)
            delete this;
        return static_cast<ULONG>(newCount);
    }

    HRESULT Notify(BMDSwitcherInputEventType eventType) {
        if (eventType == bmdSwitcherInputEventTypeIsProgramTalliedChanged || eventType == bmdSwitcherInputEventTypeIsPreviewTalliedChanged) {
            // Storage for tally and id info
            BMDSwitcherInputId inputId = NULL;
            bool preview;
            bool program;

            // Get tally info and id
            mInput->GetInputId(&inputId);
            mInput->IsPreviewTallied(&preview);
            mInput->IsProgramTallied(&program);

            // Create a new InputStatus object and pass it to the provided callback
            InputStatus *status = [[InputStatus alloc] init];
            status.inputId = inputId;
            status.isPreview = preview;
            status.isProgram = program;

            dispatch_sync(dispatch_get_main_queue(), ^{
                mCallback(status);
            });
        }

        return S_OK;
    }

    IBMDSwitcherInput *input() {
        return mInput;
    }

private:
    IBMDSwitcherInput *mInput;
    int mRefCount;

    void (^mCallback)(InputStatus *);
};

@implementation InputStatus

@end

@implementation BMDSwitcher {
    IBMDSwitcher *mSwitcher;
}

- (unsigned int)connect:(NSString *)addr {
    HRESULT result;

    IBMDSwitcherDiscovery *discovery = CreateBMDSwitcherDiscoveryInstance();
    BMDSwitcherConnectToFailure connectToFailReason;
    result = discovery->ConnectTo((__bridge CFStringRef) addr, &mSwitcher, &connectToFailReason);
    discovery->Release();
    if (result == S_OK) {
        connectToFailReason = 0;
    }

    return connectToFailReason;
}

- (void)getInputs:(void (^)(InputStatus *))callback {
    HRESULT result;
    IBMDSwitcherInputIterator *inputIterator;

    // Make sure that a switcher object has been obtained
    if (mSwitcher == NULL) {
        return;
    }

    // Get input iterator
    result = mSwitcher->CreateIterator(IID_IBMDSwitcherInputIterator, (void **) &inputIterator);

    // For each input get status and id
    if SUCCEEDED(result) {
        IBMDSwitcherInput *input;

        // Iterate though all inputs
        while (S_OK == inputIterator->Next(&input)) {
            // Create input monitor
            InputMonitor *inputMonitor = new InputMonitor(input, callback);

            // Release input for next iteration
            input->Release();
        }

        // Release input iterator
        inputIterator->Release();
        inputIterator = NULL;
    }
}

@end


