#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

id<MTLLibrary> addLibrary;

@interface MetalAdder : NSObject 
- (instancetype) initWithDevice: (id<MTLDevice>) device error:(char*)error;
- (bool) prepareData: (const int32_t*)inA inB: (const int32_t*)inB size: (size_t)vec_size error:(char*)error;
- (int32_t*) sendComputeCommand: (size_t)vec_size error:(char*)error;
@end

NS_ASSUME_NONNULL_END
