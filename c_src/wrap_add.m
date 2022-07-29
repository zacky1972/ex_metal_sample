#import <string.h>
#import <stdio.h>
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "MetalAdder.h"
#import "wrap_add.h"

bool init_metal(const char *metal_src, char *error_message)
{
    @autoreleasepool {
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        if(device == nil) {
            snprintf(error_message, MAXBUFLEN, "Device not found");
            return false;
        }

        NSError* error = nil;

        NSString *src = [NSString stringWithCString:metal_src encoding:NSUTF8StringEncoding];

        MTLCompileOptions* options = [MTLCompileOptions new];
        options.languageVersion = MTLLanguageVersion2_4;

        addLibrary = [device newLibraryWithSource:src options:options error:&error];
        if(addLibrary == nil || error != nil) {
            snprintf(error_message, MAXBUFLEN, "Fail to create new library from source.");
            return false;
        }
    }
    return true;
}

bool add_s32_metal(const int32_t *in1, const int32_t *in2, int32_t *out, uint64_t vec_size, char *error)
{
    @autoreleasepool {
        
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();

        if(device == nil) {
            snprintf(error, MAXBUFLEN, "Device not found");
            return false;
        }

        // Create the custom object used to encapsulate the Metal code.
        // Initializes objects to communicate with the GPU.
        MetalAdder* adder = [[MetalAdder alloc] initWithDevice:device error:error];
        
        if(adder == nil) {
            return false;
        }

        // Create buffers to hold data
        if(![adder prepareData:in1 inB:in2 size:vec_size error:error]) {
             return false;
        }
        
        // Send a command to the GPU to perform the calculation.
        int32_t *result = [adder sendComputeCommand:vec_size error:error];
        if(result == nil) {
            return false;
        }
        memcpy(out, result, vec_size * sizeof(int32_t));
    }
    return true;
}
