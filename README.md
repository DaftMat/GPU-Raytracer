# GPU-Raytracer
GPU Accelerated Path-Tracer.

## Dependencies
In order to compile this project, you'll need CUDA installed on your computer and linked with your visual studio environment. [See this page to know how to do it.](https://medium.com/@aviatorx/c-and-cuda-project-visual-studio-d07c6ad771e3)

The other dependencies are obtained through vcpkg. If don't have it, [see this page to know how to get it.](https://vcpkg.io/en/getting-started.html) Lastly, you need to download the following libraries in vcpkg:
 - GLM
 - lodepng
 
If vcpkg is already installed on your computer, you can install those dependencies by typing:
```txt
$ vcpkg install glm:x64-windows lodepng:x64-windows
$ vcpkg integrate install
```

## Running
This is a visual studio project. The easiest way to run it is to open the project in visual studio, select x64 configuration either as debug or release and simply run the program. Not that running the project this way will generate the `out.png` at the same location of the source codes. If you want the `out.png` file to be at the same place as the executable `GPURaytracerProto.exe` you have to find it in the project files and execute it from here (which will be located in `x64/Debug/` or `x64/Release`). Lastly, if you want to know how much time was spent on rendering, you can profile `GPURaytracerProto.exe` by using the command `nvprof`. Here's an example.
```txt
$ nvprof .\GPURaytracerProto
==8892== Profiling application: .\GPURaytracerProto.exe
==8892== Profiling result:
            Type  Time(%)      Time     Calls       Avg       Min       Max  Name
 GPU activities:  100.00%  34.4761s         1  34.4761s  34.4761s  34.4761s  render(glm::vec<int=3, float, glm::qualifier>*, int, int, int, int, Scene**, Camera**, curandStateXORWOW*)
                    0.00%  146.78us         1  146.78us  146.78us  146.78us  initializeScene(Scene**, Camera**, Shape**, int, int)
                    0.00%  89.149us         1  89.149us  89.149us  89.149us  freeScene(Scene**, Camera**, Shape**)
      API calls:   99.12%  34.4767s         3  11.4922s  125.20us  34.4761s  cudaDeviceSynchronize
                    0.87%  302.49ms         1  302.49ms  302.49ms  302.49ms  cudaMallocManaged
                    0.01%  2.3596ms         5  471.92us  9.4000us  2.0348ms  cudaFree
                    0.00%  1.1762ms         3  392.07us  27.300us  1.1133ms  cudaLaunchKernel
                    0.00%  882.80us         4  220.70us  10.400us  572.80us  cudaMalloc
                    0.00%  16.600us         3  5.5330us     300ns  15.800us  cudaGetLastError
                    0.00%  13.900us       101     137ns     100ns     600ns  cuDeviceGetAttribute
                    0.00%  4.5000us         3  1.5000us     300ns  3.7000us  cuDeviceGetCount
                    0.00%  1.3000us         2     650ns     100ns  1.2000us  cuDeviceGet
                    0.00%     600ns         1     600ns     600ns     600ns  cuDeviceGetName
                    0.00%     500ns         1     500ns     500ns     500ns  cuDeviceGetLuid
                    0.00%     300ns         1     300ns     300ns     300ns  cuDeviceTotalMem
                    0.00%     100ns         1     100ns     100ns     100ns  cuDeviceGetUuid

==8892== Unified Memory profiling result:
Device "NVIDIA GeForce GTX 1070 (0)"
   Count  Avg Size  Min Size  Max Size  Total Size  Total Time  Name
       8  384.00KB  32.000KB  1.0000MB  3.000000MB  11.14000ms  Device To Host
```

## Results
As this program is a pure prototype and has not been designed for being used, its interface is quite poor. If you don't want to bother compiling and running the code but still are interested in the results of it, here's the part you're looking for.

![sky light](https://imgur.com/2EX8Qk1) Sky light sphere - 16k spp, ~25s to render

![spherical light](https://imgur.com/c0PjVEh) Spherical light sphere - 32k spp, ~50s to render

![cornell box D](https://imgur.com/lkYLjAK) Full lambertian Cornell box - 64k spp, ~20mins to render

![cornell box D+S](https://imgur.com/kgKZTHm) Lambertian + specular Cornell box - 16k spp, ~300s to render
