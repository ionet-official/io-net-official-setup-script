CUDA_ROOT := /usr/local/cuda-11
export PATH := $(CUDA_ROOT)/bin:$(PATH)
BUILD_DIR := build
MARKER := $(BUILD_DIR)/.marker

all: $(BUILD_DIR)/self-check

$(MARKER):
	mkdir $(BUILD_DIR) -p
	touch $@


$(BUILD_DIR)/checks.cu.o: checks.cu checks.cuh $(MARKER)
	nvcc -arch=sm_61 --device-c -O3 $< -c -o $@

$(BUILD_DIR)/checks.o: $(BUILD_DIR)/checks.cu.o
	nvcc -arch=sm_61 --device-link -o $@ $^

$(BUILD_DIR)/main.o: main.cpp checks.cuh $(MARKER)
	g++ -O3 -march=corei7-avx -mtune=corei7-avx -mno-avx -mno-aes $< -c -o $@

$(BUILD_DIR)/self-check: $(BUILD_DIR)/main.o $(BUILD_DIR)/checks.o $(BUILD_DIR)/checks.cu.o
	g++ $^ -o $@ -L$(CUDA_ROOT)/lib64 -lcudart_static -ldl -lrt -pthread
	strip $@

clean:
	rm -rf $(BUILD_DIR)

run: $(BUILD_DIR)/self-check
	$<

docker: Dockerfile
	docker build . -t self-check-build
	docker run --volume $(CURDIR):/checker --user $(shell id -u) self-check-build make BUILD_DIR=build-docker -C /checker clean all
	docker run -it --volume $(CURDIR):/checker --gpus all --entrypoint /checker/build-docker/self-check brunneis/python:3.9.0-ubuntu

.PHONY: all clean docker run

#.SILENT:
