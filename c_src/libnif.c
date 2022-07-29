#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <erl_nif.h>

#include <stdio.h>

#ifdef METAL
#include "wrap_add.h"
#endif

static ERL_NIF_TERM init_metal_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if(__builtin_expect(argc != 1, false)) {
        return enif_make_badarg(env);
    }
#ifdef METAL
    bool ret = true;
    const char *metal_error = "Metal Error: ";
    char error[MAXBUFLEN];
    memset(error, 0, MAXBUFLEN);

    unsigned len;
    if(__builtin_expect(!enif_get_list_length(env, argv[0], &len), false)) {
        return enif_make_badarg(env);
    }
    char *metal_src = enif_alloc(len);
    if(__builtin_expect(metal_src == NULL, false)) {
        return enif_make_badarg(env);
    }
    if(__builtin_expect(!enif_get_string(env, argv[0], metal_src, len, ERL_NIF_LATIN1), false)) {
        return enif_make_badarg(env);
    }
    ret = init_metal(metal_src, error);
    enif_free(metal_src);
    if(ret) {
        return enif_make_atom(env, "ok");
    } else {
        char ret_error[MAXBUFLEN + strlen(metal_error)];
        memset(ret_error, 0, MAXBUFLEN + strlen(metal_error));
        snprintf(ret_error, MAXBUFLEN + strlen(metal_error), "%s%s", metal_error, error);
        return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_string(env, ret_error, ERL_NIF_LATIN1));
    }
#else
    return enif_make_atom(env, "ok");
#endif
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
    const char *metal_error = "Metal Error: ";
    char error[MAXBUFLEN];
    memset(error, 0, MAXBUFLEN);

    if(__builtin_expect(!add_s32_metal(in1, in2, out, vec_size, error), false)) {
        size_t len = MAXBUFLEN + strlen(metal_error);
        char ret_error[len];
        memset(ret_error, 0, len);
        snprintf(ret_error, len, "%s%s", metal_error, error);
        return enif_raise_exception(env, enif_make_string(env, ret_error, ERL_NIF_LATIN1));
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
