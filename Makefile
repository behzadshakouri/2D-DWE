CXX ?= g++
CPPFLAGS ?= -Isrc
CXXFLAGS ?= -O3 -std=c++17 -Wall -Wextra -Wpedantic -fopenmp
LDFLAGS ?= -fopenmp

TARGET := bin/2D-DWE
SOURCES := src/scheme_inertial.cpp src/main.cpp
BUILD_MODE := core

ifeq ($(WITH_GDAL),1)
BUILD_MODE := gdal
CPPFLAGS += -DDWE_WITH_GDAL $(shell gdal-config --cflags)
SOURCES += src/io_gdal.cpp
LDLIBS += $(shell gdal-config --libs)
endif

OBJECTS := $(patsubst src/%.cpp,build/obj/$(BUILD_MODE)/%.o,$(SOURCES))
DEPFILES := $(OBJECTS:.o=.d)

.PHONY: all clean test test-build-modes test-ea FORCE

all: $(TARGET)

$(TARGET): $(OBJECTS) FORCE
	@mkdir -p $(@D)
	$(CXX) $(LDFLAGS) $(OBJECTS) $(LDLIBS) -o $@

build/obj/$(BUILD_MODE)/%.o: src/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -c $< -o $@

test: $(TARGET)
	bash tests/verify.sh $(TARGET)

test-build-modes:
	bash tests/verify_build_modes.sh

test-ea: $(TARGET)
	bash tests/verify_ea_test4.sh $(TARGET)

clean:
	rm -rf build bin

FORCE:

-include $(DEPFILES)
