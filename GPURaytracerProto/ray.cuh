#pragma once

#include "math.cuh"

class Ray {
public:
	GPU_ONLY Ray(glm::vec3 origin, glm::vec3 direction, float tmin = 0.01f, float tmax = std::numeric_limits<float>::infinity())
		: m_origin{ origin }, m_direction{ direction }, m_tmin{ tmin }, m_tmax{ tmax } {}

	GPU_ONLY Ray(const Ray&) = default;
	GPU_ONLY Ray(Ray&&) = default;

	GPU_ONLY Ray& operator=(const Ray&) = default;
	GPU_ONLY Ray& operator=(Ray&&) = default;

	GPU_ONLY glm::vec3 operator()() const { return m_origin + m_tmax * m_direction; }
	GPU_ONLY glm::vec3 operator()(float t) const { return m_origin + t * m_direction; }

	GPU_ONLY glm::vec3 origin() const { return m_origin; }
	GPU_ONLY glm::vec3& origin() { return m_origin; }

	GPU_ONLY glm::vec3 direction() const { return m_direction; }
	GPU_ONLY glm::vec3& direction() { return m_direction; }

	GPU_ONLY float tmin() const { return m_tmin; }
	GPU_ONLY float& tmin() { return m_tmin; }

	GPU_ONLY float& tmax() const { return m_tmax; }

private:
	glm::vec3 m_origin, m_direction;
	float m_tmin;
	mutable float m_tmax;
};