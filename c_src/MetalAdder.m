#import <stdio.h>
#import "MetalAdder.h"
#import "wrap_add.h"

@implementation MetalAdder
{
    id<MTLDevice> _mDevice;

    // The compute pipeline generated from the compute kernel in the .metal shader file.
    id<MTLComputePipelineState> _mAddFunctionPSO;

    // The command queue used to pass commands to the device.
    id<MTLCommandQueue> _mCommandQueue;

    // Buffers to hold data.
    id<MTLBuffer> _mBufferA;
    id<MTLBuffer> _mBufferB;
    id<MTLBuffer> _mBufferResult;

}

- (instancetype) initWithDevice: (id<MTLDevice>) device error:(char*)error_message
{
    self = [super init];
    if (self)
    {
        _mDevice = device;

        NSError* error = nil;

        if (libraryFile == nil)
        {
            snprintf(error_message, MAXBUFLEN, "libraryFile must be not nil");
            return nil;
        }

        id <MTLLibrary> defaultLibrary = [_mDevice newLibraryWithURL:[NSURL fileURLWithPath:libraryFile] error: &error];
        if (defaultLibrary == nil)
        {
            snprintf(error_message, MAXBUFLEN, "Failed to find the default library:%s", [libraryFile UTF8String]);
            return nil;
        }

        id<MTLFunction> addFunction = [defaultLibrary newFunctionWithName:@"add_arrays"];
        if (addFunction == nil)
        {
            snprintf(error_message, MAXBUFLEN, "Failed to find the adder function.");
            return nil;
        }

        // Create a compute pipeline state object.
        _mAddFunctionPSO = [_mDevice newComputePipelineStateWithFunction: addFunction error:&error];
        if (_mAddFunctionPSO == nil)
        {
            //  If the Metal API validation is enabled, you can find out more information about what
            //  went wrong.  (Metal API validation is enabled by default when a debug build is run
            //  from Xcode)
            snprintf(error_message, MAXBUFLEN, "Failed to created pipeline state object, error: %s", [[error description] UTF8String]);
            return nil;
        }

        _mCommandQueue = [_mDevice newCommandQueue];
        if (_mCommandQueue == nil)
        {
            snprintf(error_message, MAXBUFLEN, "Failed to find the command queue.");
            return nil;
        }
    }

    return self;
}

- (void) prepareData: (const int32_t *)inA inB: (const int32_t *)inB size: (size_t)vec_size error: error_message
{
    // Allocate three buffers to hold our initial data and the result.
    size_t bufferSize = sizeof(int32_t) * vec_size;
    _mBufferA = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferB = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferResult = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];

    if(_mBufferA == nil || _mBufferB == nil || _mBufferResult == nil) {
        snprintf(error_message, MAXBUFLEN, "Failed to create data buffer.");
    }

    [self generateData:_mBufferA in:inA size: vec_size error:error_message];
    [self generateData:_mBufferB in:inB size: vec_size error:error_message];
}

- (int32_t*) sendComputeCommand: (size_t)vec_size error: (char*)error_message
{
    // Create a command buffer to hold commands.
    id<MTLCommandBuffer> commandBuffer = [_mCommandQueue commandBuffer];
    if(commandBuffer != nil) {
        snprintf(error_message, MAXBUFLEN, "Failed to create command buffer.");
    }

    // Start a compute pass.
    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    if(computeEncoder != nil) {
        snprintf(error_message, MAXBUFLEN, "Failed to create compute encoder.");
    }

    [self encodeAddCommand:computeEncoder size: vec_size error:error_message];

    // End the compute pass.
    [computeEncoder endEncoding];

    // Execute the command.
    [commandBuffer commit];

    // Normally, you want to do other work in your app while the GPU is running,
    // but in this example, the code simply blocks until the calculation is complete.
    [commandBuffer waitUntilCompleted];

    return _mBufferResult.contents;
}

- (void)encodeAddCommand:(id<MTLComputeCommandEncoder>)computeEncoder size: (size_t)vec_size error: (char*) error_message 
{
    // Encode the pipeline state object and its parameters.
    [computeEncoder setComputePipelineState:_mAddFunctionPSO];
    [computeEncoder setBuffer:_mBufferA offset:0 atIndex:0];
    [computeEncoder setBuffer:_mBufferB offset:0 atIndex:1];
    [computeEncoder setBuffer:_mBufferResult offset:0 atIndex:2];

    MTLSize gridSize = MTLSizeMake(vec_size, 1, 1);

    // Calculate a threadgroup size.
    NSUInteger threadGroupSize = _mAddFunctionPSO.maxTotalThreadsPerThreadgroup;
    if (threadGroupSize > vec_size)
    {
        threadGroupSize = vec_size;
    }
    MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);

    // Encode the compute command.
    [computeEncoder dispatchThreads:gridSize
              threadsPerThreadgroup:threadgroupSize];
}

- (void) generateData: (id<MTLBuffer>) buffer in: (const int32_t *) in size:(size_t)vec_size error:(char*)error_message
{
    int32_t* dataPtr = buffer.contents;

    for (size_t index = 0; index < vec_size; index++)
    {
        dataPtr[index] = in[index];
    }
}
@end
