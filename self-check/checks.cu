#include "checks.cuh"
#include <stdio.h>

#define CUDA_ERROR_CHECK(err, msg) {    \
    if ((err) != cudaSuccess) {         \
        fprintf(stderr, "%s: cuda error=%d - %s\n", (msg), (int)(err), cudaGetErrorString(err));  \
        return -1;                      \
    }                                   \
}

int get_devices_count() {
    int result;
    auto err = cudaGetDeviceCount(&result);
    CUDA_ERROR_CHECK(err, "Cannot get device count");
    return result;
}

int get_device_name(int device, char** result) {
    if (result == nullptr) return -2;
    cudaDeviceProp prop;
    auto err = cudaGetDeviceProperties(&prop, device);
    CUDA_ERROR_CHECK(err, "Cannot get device properties");
    *result = prop.name;
    return 0;
}

int device_malloc(int device, void** result) {
    if (result == nullptr) return -2;
    auto err = cudaSetDevice(device);
    CUDA_ERROR_CHECK(err, "Cannot set active device");
    void* mem = nullptr;
    err = cudaMalloc(&mem, 1024);
    CUDA_ERROR_CHECK(err, "Cannot allocate memory");
    *result = mem;
    return 0;
}

int device_free(int device, void* ptr) {
    if (ptr == nullptr) return -2;
    auto err = cudaSetDevice(device);
    CUDA_ERROR_CHECK(err, "Cannot set active device");
    err = cudaFree(ptr);
    CUDA_ERROR_CHECK(err, "Cannot free memory");
    return 0;
}
