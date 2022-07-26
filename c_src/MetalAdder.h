#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

NSString *libraryFile;

@interface MetalAdder : NSObject 
- (instancetype) initWithDevice: (id<MTLDevice>) device;
- (void) prepareData: (const int32_t*)inA inB: (const int32_t*)inB size: (size_t)vec_size;
- (int32_t*) sendComputeCommand: (size_t)vec_size;
@end

NS_ASSUME_NONNULL_END
