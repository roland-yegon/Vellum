CC = gcc
CPPFLAGS = -Iinclude -MMD -MP
CFLAGS = -Wall -Wextra -Wpedantic -std=c23
LDFLAGS =
LDLIBS =

BUILD ?= debug

ifeq ($(BUILD),release)
    CPPFLAGS += -DNDEBUG
    CFLAGS += -O2
else
    CFLAGS += -g -O0 -fsanitize=address,undefined
    LDFLAGS += -fsanitize=address,undefined
endif

V ?= 0

ifeq ($(V),1)
    Q =
    ECHO = @true
else
    Q = @
    ECHO = @echo
endif

SRC_DIR = src
BUILD_DIR = build/$(BUILD)
OBJ_DIR = $(BUILD_DIR)/obj
BIN_DIR = $(BUILD_DIR)/bin

SRC_FILES = $(wildcard $(SRC_DIR)/*.c)
OBJ_FILES = $(SRC_FILES:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
DEP_FILES = $(OBJ_FILES:.o=.d)
TARGET = $(BIN_DIR)/vellum

all: $(TARGET)

$(TARGET): $(OBJ_FILES) | $(BIN_DIR)
	$(ECHO) "  LD      $@"
	$(Q)$(CC) $(OBJ_FILES) -o $@ $(LDFLAGS) $(LDLIBS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(ECHO) "  CC      $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(OBJ_DIR) $(BIN_DIR):
	$(Q)mkdir -p $@

clean:
	@echo "Cleaning up the build artifacts"
	rm -rf build

run: $(TARGET)
	./$(TARGET) $(ARGS)

format:
	clang-format -i $(SRC_FILES) $(wildcard include/*.h)

.PHONY: all clean run format

-include $(DEP_FILES)
