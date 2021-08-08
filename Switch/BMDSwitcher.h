#import "BMDSwitcherAPI.h"

#import <Cocoa/Cocoa.h>

@interface InputStatus : NSObject

@property(nonatomic, readwrite) int64_t inputId;
@property(nonatomic, readwrite) bool isProgram;
@property(nonatomic, readwrite) bool isPreview;

@end

@interface BMDSwitcher : NSObject
- (unsigned int)connect: (NSString *)addr;
- (NSArray<InputStatus*>*)getInputs;
@end
