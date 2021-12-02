#include "shape.cuh"

Fragment::Fragment(glm::vec3 position, glm::vec3 normal, glm::vec3 wo, glm::vec3 radiance, glm::vec3 emission, bool reflective) :
	m_position{ position },
	m_normal{ normal },
	m_wo{ wo },
	m_radiance{ radiance },
	m_emission{ emission },
	m_reflective{ reflective } {
	if (glm::dot(m_normal, m_wo) < 0.f)
		m_normal = -m_normal;

	glm::vec3 baseWorldUp{ 0.f, 1.f, 0.f };
	glm::vec3 worldUp = m_normal == baseWorldUp ? glm::vec3{ 1.f, 0.f, 0.f } : baseWorldUp;
	m_tangent = glm::normalize(glm::cross(normal, worldUp));
	m_bitangent = glm::normalize(glm::cross(m_tangent, normal));
}