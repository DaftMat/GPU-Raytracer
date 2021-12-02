#include "sphere.cuh"
#include "ray.cuh"

bool Sphere::intersect(const Ray& ray, Fragment& fragment/*, std::shared_ptr<Material> material*/) const {
	glm::vec3 oc = ray.origin() - m_center;
	auto a = glm::dot(ray.direction(), ray.direction());
	auto b = 2.f * glm::dot(oc, ray.direction());
	auto c = glm::dot(oc, oc) - m_radius * m_radius;
	auto d = b * b - 4.f * a * c;
	if (d <= 0.f)
		return false;

	float t = (-b - glm::sqrt(d)) / (2.f * a);
	if (t < ray.tmin() || t > ray.tmax()) {
		t = (-b + glm::sqrt(d)) / (2.f * a);
		if (t < ray.tmin() || t > ray.tmax())
			return false;
	}

	ray.tmax() = t;
	glm::vec3 pos = ray();
	glm::vec3 normal = glm::normalize(pos - m_center);
	if (glm::dot(normal, glm::normalize(-ray.direction())) < 0.f)
		normal = -normal;

	fragment = Fragment{ pos, normal, glm::normalize(-ray.direction()), m_radiance, m_emission, m_reflective };

	return true;
}