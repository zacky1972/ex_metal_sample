#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <erl_nif.h>

#ifdef METAL
#include "wrap_add.h"

#define MAXBUFLEN 1024
#endif

static ERL_NIF_TERM init_metal_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if(__builtin_expect(argc != 1, false)) {
        return enif_make_badarg(env);
    }
    bool ret = true;
#ifdef METAL
    char default_metallib[MAXBUFLEN];
    if(__builtin_expect(!enif_get_string(env, argv[0], default_metallib, MAXBUFLEN, ERL_NIF_LATIN1), false)) {
        return enif_make_badarg(env);
    }
    ret = init_metal(default_metallib);
#endif
    if(ret) {
        return enif_make_atom(env, "ok");
    } else {
        return enif_make_atom(env, "error");
    }
}

static ERL_NIF_TERM add_s32_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if(__builtin_expect(argc != 4, false)) {
        return enif_make_badarg(env);
    }

    ErlNifUInt64 vec_size;
    if(__builtin_expect(!enif_get_uint64(env, argv[0], &vec_size), false)) {
        return enif_make_badarg(env);
    }

    ERL_NIF_TERM binary1_term = argv[2];
    ErlNifBinary in_data_1;
    if(__builtin_expect(!enif_inspect_binary(env, binary1_term, &in_data_1), false)) {
        return enif_make_badarg(env);
    }
    int32_t *in1 = (int32_t *)in_data_1.data;

    ERL_NIF_TERM binary2_term = argv[3];
    ErlNifBinary in_data_2;
    if(__builtin_expect(!enif_inspect_binary(env, binary2_term, &in_data_2), false)) {
        return enif_make_badarg(env);
    }
    int32_t *in2 = (int32_t *)in_data_2.data;

    ErlNifBinary out_data;
    if(__builtin_expect(!enif_alloc_binary(vec_size * sizeof(int32_t), &out_data), false)) {
        return enif_make_badarg(env);
    }
    int32_t *out = (int32_t *)out_data.data;

#ifdef METAL
    if(__builtin_expect(!add_s32_metal(in1, in2, out, vec_size), false)) {
        return enif_raise_exception(env, enif_make_atom(env, "Metal Error"));
    }
#else
    for(ErlNifUInt64 i = 0; i < vec_size; i++) {
        out[i] = in1[i] + in2[i];
    }
#endif

    return enif_make_binary(env, &out_data);
}

static ErlNifFunc nif_funcs [] =
{
    {"init_metal_nif", 1, init_metal_nif},
    {"add_s32_nif", 4, add_s32_nif}
};

ERL_NIF_INIT(Elixir.ExMetalSample, nif_funcs, NULL, NULL, NULL, NULL)
