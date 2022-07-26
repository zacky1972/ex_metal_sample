.phony: all clean

PRIV = $(MIX_APP_PATH)/priv
BUILD = $(MIX_APP_PATH)/obj
NIF = $(PRIV)/libnif.so
MLIB = $(PRIV)/default.metallib

ifeq ($(shell uname -s),Darwin)
CFLAGS += -DMETAL
endif

ifeq ($(CROSSCOMPILE),)
ifeq ($(shell uname -s),Linux)
LDFLAGS += -fPIC -shared
CFLAGS += -fPIC
else # macOS
LDFLAGS += -undefined dynamic_lookup -dynamiclib
endif
else
LDFLAGS += -fPIC -shared
CFLAGS += -fPIC
endif

ifeq ($(ERL_EI_INCLUDE_DIR),)
ERLANG_PATH = $(shell elixir --eval ':code.root_dir |> to_string() |> IO.puts')
ifeq ($(ERLANG_PATH),)
$(error Could not find the Elixir installation. Check to see that 'elixir')
endif
ERL_EI_INCLUDE_DIR = $(ERLANG_PATH)/usr/include
ERL_EI_LIB_DIR = $(ERLANG_PATH)/usr/lib
endif

ERL_CFLAGS ?= -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR)

CFLAGS += -std=c11 -O3 -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-missing-field-initializers

C_SRC = c_src/libnif.c
C_OBJ = $(C_SRC:c_src/%.c=$(BUILD)/%.o)
OC_SRC = c_src/wrap_add.m c_src/MetalAdder.m
OC_OBJ = $(OC_SRC:c_src/%.m=$(BUILD)/%.o)
MTL_SRC = c_src/add.metal
MTL_OBJ = $(MTL_SRC:c_src/%.metal=$(BUILD)/%.air)

ifeq ($(shell uname -s),Darwin)
all: $(PRIV) $(BUILD) $(NIF) $(MLIB)
else
all: $(PRIV) $(BUILD) $(NIF)
endif

$(PRIV) $(BUILD):
	mkdir -p $@

$(BUILD)/%.o: c_src/%.c
	@echo " CC $(notdir $@)"
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

ifeq ($(shell uname -s),Darwin)
$(BUILD)/%.o: c_src/%.m
	@echo " CLANG $(notdir $@)"
	xcrun clang -c $(OBJC_FLAGS) $(CFLAGS) -o $@ $<

$(BUILD)/%.air: c_src/%.metal
	@echo " metal $(notdir $@)"
	xcrun -sdk macosx metal -c $< -o $@

$(MLIB): $(MTL_OBJ)
	@echo " metallib $(notdir $@)"
	xcrun -sdk macosx metallib $< -o $@
endif

ifeq ($(shell uname -s),Darwin)
$(NIF): $(C_OBJ) $(OC_OBJ)
	@echo " LD $(notdir $@)"
	xcrun clang -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^
else
$(NIF): $(C_OBJ)
	@echo " LD $(notdir $@)"
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^
endif

clean:
	$(RM) $(NIF) $(C_OBJ) $(OC_OBJ) $(MTL_OBJ) $(MLIB)

