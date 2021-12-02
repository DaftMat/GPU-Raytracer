#pragma once

#include "math.cuh"
#include "shape.cuh"

class Ray;
class Fragment;

class Scene {
public:
	CPU_GPU Scene() = default;
	CPU_GPU Scene(Shape** shapes, int nbShapes) : m_shapes{ shapes }, m_nbShapes{ nbShapes } {}
	
	GPU_ONLY bool intersect(const Ray& ray, Fragment& fragment) const;

	GPU_ONLY glm::vec3 skyColor(glm::vec3 dir) const;

private:
	Shape** m_shapes;
	int m_nbShapes{ 0 };
};