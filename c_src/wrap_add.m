#import <string.h>
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "MetalAdder.h"
#import "wrap_add.h"

bool init_metal(const char *default_library_path)
{
    libraryFile = [NSString stringWithCString:default_library_path encoding:NSUTF8StringEncoding];
    return true;
}

bool add_s32_metal(const int32_t *in1, const int32_t *in2, int32_t *out, uint64_t vec_size)
{
    @autoreleasepool {
        
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();

        // Create the custom object used to encapsulate the Metal code.
        // Initializes objects to communicate with the GPU.
        MetalAdder* adder = [[MetalAdder alloc] initWithDevice:device];
        
        if(adder == nil) {
            return false;
        }

        // Create buffers to hold data
        [adder prepareData:in1 inB:in2 size:vec_size];
        
        // Send a command to the GPU to perform the calculation.
        int32_t *result = [adder sendComputeCommand:vec_size];
        memcpy(out, result, vec_size * sizeof(int32_t));
    }
    return true;
}
