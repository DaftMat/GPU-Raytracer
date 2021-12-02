#pragma once

#include "shape.cuh"

class Triangle : public Shape {
public:
	CPU_GPU Triangle(glm::vec3 v0, glm::vec3 v1, glm::vec3 v2, glm::vec3 radiance = glm::vec3{ 0.4f }, glm::vec3 emission = glm::vec3{ 0.f }, bool reflective = false)
		: Shape::Shape{ radiance, emission }, m_v0{ v0 }, m_v1{ v1 }, m_v2{ v2 } {}

	GPU_ONLY bool intersect(const Ray& ray, Fragment& frag) const override;

private:
	glm::vec3 m_v0, m_v1, m_v2;
};