#include "triangle.cuh"
#include "ray.cuh"

bool Triangle::intersect(const Ray& ray, Fragment& frag) const {
	glm::vec3 A = m_v0 - m_v2;
	glm::vec3 B = m_v1 - m_v2;
	glm::vec3 T = ray.origin() - m_v2;

	glm::vec3 normal = glm::normalize(glm::cross(B, A));
	if (glm::abs(glm::dot(normal, ray.direction())) < glm::epsilon<float>())
		return false;

	glm::vec3 p = glm::cross(ray.direction(), B);
	glm::vec3 q = glm::cross(T, A);

	float d = glm::dot(p, A);
	if (glm::abs(d) < glm::epsilon<float>())
		return false;
	float u = (1.f / d) * glm::dot(p, T);
	if (u < 0.f)
		return false;
	float v = (1.f / d) * glm::dot(q, ray.direction());
	if (v < 0.f || (u + v) > 1.f)
		return false;

	float t = (1.f / d) * glm::dot(q, B);
	if (t < ray.tmin() || t > ray.tmax())
		return false;

	ray.tmax() = t;
	glm::vec3 pos = ray();
	frag = Fragment{ pos, normal, glm::normalize(-ray.direction()), m_radiance, m_emission, m_reflective };

	return true;
}