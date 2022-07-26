#include <stdbool.h>
#include <stdint.h>
#include <erl_nif.h>

#ifdef METAL
#include "wrap_add.h"
#endif

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

    for(ErlNifUInt64 i = 0; i < vec_size; i++) {
        out[i] = in1[i] + in2[i];
    }

    return enif_make_binary(env, &out_data);
}

static ErlNifFunc nif_funcs [] =
{
    {"add_s32_nif", 4, add_s32_nif}
};

ERL_NIF_INIT(Elixir.ExMetalSample, nif_funcs, NULL, NULL, NULL, NULL)
