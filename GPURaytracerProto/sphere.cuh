#pragma once

#include "math.cuh"
#include "shape.cuh"
#include <memory>

class Ray;

class Sphere : public Shape {
public:
	CPU_GPU Sphere(glm::vec3 position, float radius, glm::vec3 radiance = glm::vec3{ 0.4f }, glm::vec3 emission = glm::vec3{ 0.f }, bool reflective = false)
		: Shape::Shape{ radiance, emission, reflective }, m_center{ position }, m_radius{ radius } {}

	GPU_ONLY bool intersect(const Ray& ray, Fragment& frag) const override;

private:
	glm::vec3 m_center;
	float m_radius;
};