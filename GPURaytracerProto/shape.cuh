#pragma once

#include "math.cuh"

class Ray;

class Fragment {
public:
	GPU_ONLY Fragment() = default;
	GPU_ONLY Fragment(glm::vec3 position, glm::vec3 normal, glm::vec3 wo, glm::vec3 radiance, glm::vec3 emission, bool m_reflective);

	GPU_ONLY Fragment(const Fragment&) = default;
	GPU_ONLY Fragment(Fragment&&) = default;

	GPU_ONLY Fragment& operator=(const Fragment&) = default;
	GPU_ONLY Fragment& operator=(Fragment&&) = default;

	GPU_ONLY glm::vec3 position() const { return m_position; }
	GPU_ONLY glm::vec3& position() { return m_position; }

	GPU_ONLY glm::vec3 normal() const { return m_normal; }
	GPU_ONLY glm::vec3& normal() { return m_normal; }

	GPU_ONLY glm::vec3 wo() const { return m_wo; }
	GPU_ONLY glm::vec3& wo() { return m_wo; }

	GPU_ONLY glm::vec3 tangent() const { return m_tangent; }
	GPU_ONLY glm::vec3& tangent() { return m_tangent; }

	GPU_ONLY glm::vec3 bitangent() const { return m_bitangent; }
	GPU_ONLY glm::vec3& bitangent() { return m_bitangent; }

	GPU_ONLY glm::vec3 radiance() const { return m_radiance; }
	GPU_ONLY glm::vec3& radiance() { return m_radiance; }

	GPU_ONLY glm::vec3 emission() const { return m_emission; }
	GPU_ONLY glm::vec3& emission() { return m_emission; }

	GPU_ONLY bool reflective() const { return m_reflective; }
	GPU_ONLY bool& reflective() { return m_reflective; }

private:
	glm::vec3 m_position{ 0.f };
	glm::vec3 m_normal{ 0.f };
	glm::vec3 m_wo{ 0.f };
	glm::vec3 m_tangent{ 0.f };
	glm::vec3 m_bitangent{ 0.f };

	/// Material description (basic)
	glm::vec3 m_radiance{ 0.f };
	glm::vec3 m_emission{ 0.f };
	bool m_reflective{ false };
};

class Shape {
public:
	CPU_GPU Shape(glm::vec3 radiance, glm::vec3 emission, bool reflective = false)
		: m_radiance{ radiance }, m_emission{ emission }, m_reflective{ reflective } {}

	GPU_ONLY virtual bool intersect(const Ray& ray, Fragment& frag) const = 0;

protected:
	glm::vec3 m_radiance;
	glm::vec3 m_emission;
	bool m_reflective;
};