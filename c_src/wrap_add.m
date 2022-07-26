#import <Foundation/Foundation.h>
#import "wrap_add.h"

bool add_s32_metal(const int32_t *in1, const int32_t *in2, int32_t *out, uint64_t vec_size)
{
    for(int i = 0; i < vec_size; i++) {
        out[i] = 0;
    }
    return true;
}
