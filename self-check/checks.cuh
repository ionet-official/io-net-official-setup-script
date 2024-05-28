#pragma once

int get_devices_count();
int get_device_name(int device, char** result);
int device_malloc(int device, void** result);
int device_free(int device, void* ptr);
