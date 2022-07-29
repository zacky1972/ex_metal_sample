#ifndef WRAP_ADD_H
#define WRAP_ADD_H

#include <stdbool.h>
#include <stdint.h>

#define MAXBUFLEN 1024

bool init_metal(const char *metal_src, char *error);

bool add_s32_metal(const int32_t *in1, const int32_t *in2, int32_t *out, uint64_t vec_size, char *error);

#endif // WRAP_ADD_H
