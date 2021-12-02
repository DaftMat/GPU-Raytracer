#include <iostream>

#include "utils.cuh"

#include "camera.cuh"
#include "ray.cuh"
#include "scene.cuh"
#include "sphere.cuh"
#include "triangle.cuh"


#define checkCudaErrors(val) check_cuda( (val), #val, __FILE__, __LINE__)
void check_cuda(cudaError_t result, char const* const func, const char* const file, int const line) {
	if (result) {
		std::cerr << "CUDA Error: " << static_cast<unsigned int>(result) << " at " << file << ":" << line << " '" << func << "'" << std::endl;
		cudaDeviceReset();
		exit(99);
	}
}

GPU_ONLY glm::vec3 filmic(glm::vec3 l) { return l / (l + 0.155f) * 1.019f; }

GPU_ONLY glm::vec3 transformSample(glm::vec3 n, glm::vec3 s) {
	glm::vec3 worldUp{ 0.f, 0.f, 1.f };
	if (glm::abs(n.z) >= 1.f - glm::epsilon<float>())
		worldUp = glm::vec3{ 1.f, 0.f, 0.f };
	glm::vec3 t = glm::normalize(glm::cross(worldUp, n));
	glm::vec3 b = glm::normalize(glm::cross(t, n));
	return glm::normalize(s.x * t + s.y * b + s.z * n);
}

GPU_ONLY glm::vec2 uniformDiskSample(curandState* local_rand_state) {
	float u = curand_uniform(local_rand_state) * 0.999f;
	float v = curand_uniform(local_rand_state) * 0.999f;
	float r = glm::sqrt(u);
	float theta = v * (2.f * glm::pi<float>());
	return r * glm::vec2{ glm::cos(theta), glm::sin(theta) };
}

GPU_ONLY glm::vec3 cosineHemisphereSample(glm::vec3 n, curandState* local_rand_state) {
	glm::vec2 xy = uniformDiskSample(local_rand_state);
	float z = glm::sqrt(glm::max(0.f, 1.f - xy.x * xy.x - xy.y * xy.y));
	return transformSample(n, glm::vec3{ xy.x, xy.y, z });
}

GPU_ONLY glm::vec3 uniformHemisphereSample(glm::vec3 n, curandState* local_rand_state) {
	float u = curand_uniform(local_rand_state) * 0.999f;
	float v = curand_uniform(local_rand_state) * 0.999f;
	float r = glm::sqrt(glm::max(0.f, 1.f - u * u));
	float phi = 2.f * glm::pi<float>() * v;
	
	glm::vec3 ls{ r * glm::cos(phi), r * glm::sin(phi), u };
	return transformSample(n, ls);
}

GPU_ONLY glm::vec3 li(const Ray& ray, Scene** scene, int bounces, curandState* local_rand_state) {
	Ray curRay = ray;
	glm::vec3 curRadiance{ 1.f };
	glm::vec3 finalColor{ 0.f };
	float curFactor = 1.f;
	float prr = 1.f;
	glm::vec3 throughput{ 1.f };
	while (true) {
		if (bounces-- <= 0)
			prr = glm::min(glm::max(throughput.r, glm::max(throughput.g, throughput.b)), 0.99f);

		if (curand_uniform(local_rand_state) * 0.999f >= prr)
			return finalColor;

		Fragment frag;
		if (!(*scene)->intersect(curRay, frag))
			return finalColor + (*scene)->skyColor(ray.direction()) * curRadiance;

		glm::vec3 wi{ 0.f };
		glm::vec3 radiance{ 1.f };
		if (frag.reflective())
			wi = glm::reflect(-frag.wo(), frag.normal());
		else {
			wi = cosineHemisphereSample(frag.normal(), local_rand_state);
			float cosTheta = glm::max(glm::dot(frag.normal(), wi), 0.f);
			float pdf = cosTheta / glm::pi<float>();
			radiance = cosTheta * (frag.radiance() / glm::pi<float>()) / pdf;
		}

		finalColor += curRadiance * frag.emission(); // to change before updating the curRadiance => I = R0 * E1 + R0 * R1 * E2...
		curRay = Ray{ frag.position() + 0.01f * frag.normal(), wi };
		curRadiance *= curFactor * radiance / prr;
		curFactor *= 0.5f;
	}
	return finalColor;
}

KERNEL void initializeScene(Scene** scene, Camera** camera, Shape** shapes, int nx, int ny) {
	if (threadIdx.x == 0 && blockIdx.x == 0) {
		//light
		*(shapes + 0) = new Triangle{ glm::vec3{ -5.f, 19.9f, 5.f }, glm::vec3{ -5.f, 19.9f, -5.f }, glm::vec3{ 5.f, 19.9f, -5.f }, glm::vec3{ 1.f }, glm::vec3{ 15.f } };
		*(shapes + 1) = new Triangle{ glm::vec3{ -5.f, 19.9f, 5.f }, glm::vec3{ 5.f, 19.9f, -5.f }, glm::vec3{ 5.f, 19.9f, 5.f }, glm::vec3{ 1.f }, glm::vec3{ 15.f } };

		//roof
		*(shapes + 2) = new Triangle{ glm::vec3{ -20.f, 20.f, 20.f }, glm::vec3{ -20.f, 20.f, -20.f }, glm::vec3{ 20.f, 20.f, -20.f }, glm::vec3{ 0.8f } };
		*(shapes + 3) = new Triangle{ glm::vec3{ -20.f, 20.f, 20.f }, glm::vec3{ 20.f, 20.f, 20.f }, glm::vec3{ 20.f, 20.f, -20.f }, glm::vec3{ 0.8f } };

		//ground
		*(shapes + 4) = new Triangle{ glm::vec3{ -20.f, -20.f, 20.f }, glm::vec3{ -20.f, -20.f, -20.f }, glm::vec3{ 20.f, -20.f, -20.f }, glm::vec3{ 0.8f } };
		*(shapes + 5) = new Triangle{ glm::vec3{ -20.f, -20.f, 20.f }, glm::vec3{ 20.f, -20.f, 20.f }, glm::vec3{ 20.f, -20.f, -20.f }, glm::vec3{ 0.8f } };

		//back wall
		*(shapes + 6) = new Triangle{ glm::vec3{ -20.f, 20.f, 20.f }, glm::vec3{ 20.f, 20.f, 20.f }, glm::vec3{ 20.f, -20.f, 20.f }, glm::vec3{ 0.8f } };
		*(shapes + 7) = new Triangle{ glm::vec3{ -20.f, 20.f, 20.f }, glm::vec3{ 20.f, -20.f, 20.f }, glm::vec3{ -20.f, -20.f, 20.f }, glm::vec3{ 0.8f } };

		//red wall
		*(shapes + 8) = new Triangle{ glm::vec3{ -20.f, 20.f, -20.f }, glm::vec3{ -20.f, 20.f, 20.f }, glm::vec3{ -20.f, -20.f, 20.f }, glm::vec3{ 0.8f, 0.1f, 0.1f } };
		*(shapes + 9) = new Triangle{ glm::vec3{ -20.f, 20.f, -20.f }, glm::vec3{ -20.f, -20.f, 20.f }, glm::vec3{ -20.f, -20.f, -20.f }, glm::vec3{ 0.8f, 0.1f, 0.1f } };

		//green wall
		*(shapes + 10) = new Triangle{ glm::vec3{ 20.f, 20.f, -20.f }, glm::vec3{ 20.f, 20.f, 20.f }, glm::vec3{ 20.f, -20.f, 20.f }, glm::vec3{ 0.1f, 0.8f, 0.1f } };
		*(shapes + 11) = new Triangle{ glm::vec3{ 20.f, 20.f, -20.f }, glm::vec3{ 20.f, -20.f, 20.f }, glm::vec3{ 20.f, -20.f, -20.f }, glm::vec3{ 0.1f, 0.8f, 0.1f } };

		//spheres
		*(shapes + 12) = new Sphere{ glm::vec3{ 7.5f, -13.8f, -7.f }, 6.f, glm::vec3{ 1.f } };
		*(shapes + 13) = new Sphere{ glm::vec3{ -3.5f, -10.8f, 6.f }, 9.f, glm::vec3{ 0.8f }, glm::vec3{ 0.f }, true };

		*scene = new Scene{ shapes, 14 };
		*camera = new Camera{ nx, ny, glm::vec3{ 0.f, 0.f, -40.f } };
	}
}

KERNEL void freeScene(Scene** scene, Camera** camera, Shape** shapes) {
	for (int i = 0; i < 14; ++i)
		delete* (shapes + i);
	delete *scene;
	delete *camera;
}

KERNEL void render(glm::vec3* fb, int nx, int ny, int spp, int maxBounces, Scene** scene, Camera** camera, curandState* rand_state) {
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	int j = threadIdx.y + blockIdx.y * blockDim.y;
	if (i >= nx || j >= ny) return;
	int px = j * nx + i;
	curandState local_rand_state = rand_state[px];
	curand_init(1984, px, 0, &local_rand_state);

	glm::vec3 color{ 0.f };
	for (int _ = 0; _ < spp; ++_) {
		auto u = static_cast<float>(i) + curand_uniform(&local_rand_state);
		auto v = static_cast<float>(j) + curand_uniform(&local_rand_state);
		Ray ray = (*camera)->castRay(u, v);
		color += li(ray, scene, maxBounces, &local_rand_state);
	}
	rand_state[px] = local_rand_state;
	color /= static_cast<float>(spp);
	fb[px] = glm::sqrt(glm::pow(filmic(color), glm::vec3{ 2.2f }));
}

int main() {
	int nx = 512, ny = 512;
	int spp = 1024;
	int maxBounces = 4;

	int numpx = nx * ny;

	glm::vec3* fb;
	Shape** dshapes;
	Scene** dscene;
	Camera** dcamera;
	curandState* drand_state;

	checkCudaErrors(cudaMallocManaged((void**)&fb, numpx * sizeof(glm::vec3)));
	checkCudaErrors(cudaMalloc((void**)&dshapes, 14 * sizeof(Shape *)));
	checkCudaErrors(cudaMalloc((void**)&dscene, sizeof(Scene *)));
	checkCudaErrors(cudaMalloc((void**)&dcamera, sizeof(Camera *)));
	checkCudaErrors(cudaMalloc((void**)&drand_state, numpx * sizeof(curandState)));

	initializeScene<<<1, 1>>>(dscene, dcamera, dshapes, nx, ny);
	checkCudaErrors(cudaGetLastError());
	checkCudaErrors(cudaDeviceSynchronize());

	int tx = 8, ty = 8;
	dim3 blocks(nx / tx + 1, ny / ty + 1);
	dim3 threads(tx, ty);
	render<<<blocks, threads>>>(fb, nx, ny, spp, maxBounces, dscene, dcamera, drand_state);
	checkCudaErrors(cudaGetLastError());
	checkCudaErrors(cudaDeviceSynchronize());

	freeScene<<<1, 1>>>(dscene, dcamera, dshapes);
	checkCudaErrors(cudaGetLastError());
	checkCudaErrors(cudaDeviceSynchronize());

	std::cout << "Image rendered 100%. Writing to file." << std::endl;

	output(fb, nx, ny, "out.png");

	checkCudaErrors(cudaFree(fb));
	checkCudaErrors(cudaFree(dscene));
	checkCudaErrors(cudaFree(dcamera));
	checkCudaErrors(cudaFree(dshapes));
	checkCudaErrors(cudaFree(drand_state));

	return 0;
}