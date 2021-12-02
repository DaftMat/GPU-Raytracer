#pragma once

#include <cuda.h>
#include <cuda_runtime_api.h>
#include <curand_kernel.h>

#define CPU_GPU __host__ __device__
#define CPU_ONLY __host__
#define GPU_ONLY __device__
#define KERNEL __global__

#define GLM_FORCE_CUDA
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtx/transform.hpp>
#include <glm/gtc/type_ptr.hpp>