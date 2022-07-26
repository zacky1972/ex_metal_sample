.phony: all clean

PRIV = $(MIX_APP_PATH)/priv
BUILD = $(MIX_APP_PATH)/obj
NIF = $(PRIV)/libnif.so

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

all: $(PRIV) $(BUILD) $(NIF)

$(PRIV) $(BUILD):
	mkdir -p $@

$(BUILD)/%.o: c_src/%.c
	@echo " CC $(notdir $@)"
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

$(NIF): $(C_OBJ)
	@echo " LD $(notdir $@)"
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^

clean:
	$(RM) $(NIF) $(C_OBJ)

