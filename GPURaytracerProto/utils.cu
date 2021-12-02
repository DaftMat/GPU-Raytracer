#include "utils.cuh"
#include "lodepng.h"

#include <iostream>

void output(glm::vec3* fb, int nx, int ny, std::string filename) {
	unsigned char* image = new unsigned char[nx * ny * 3];
	#pragma omp for
	for (unsigned i = 0; i < nx * ny; ++i) {
		glm::ivec3 c = clamp(glm::ivec3(255.f * fb[i]), 0, 255);
		size_t cpt = size_t(i) * 3;
		for (size_t k = 0; k < 3; ++k) {
			image[cpt + k] = c[k];
		}
	}

	unsigned error = lodepng_encode24_file(std::move(filename).c_str(), image, nx, ny);
	delete[] image;
	if (error) std::cerr << "error " << error << ": " << std::string(lodepng_error_text(error)) << std::endl;
}