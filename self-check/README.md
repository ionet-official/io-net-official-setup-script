# IO Net CUDA Self-Check Binary

This is intentionally released in source form for transparency.

To run the check, get the binary from the Releases and run it on the Linux **host** (if your worker is Linux-based) or it WSL2 used to run our Launcher (if Windows-based).

It should perform simple CUDA checks and report the results.

## Example of good output

```
    Reported 1 CUDA devices
    Device #0: name=NVIDIA GeForce RTX 3080: memory alloc test pass
    all cards look ok
```

## Example of output when some issues are found
```
    Cannot get device count: cuda error=35 - CUDA driver version is insufficient for CUDA runtime version
```
