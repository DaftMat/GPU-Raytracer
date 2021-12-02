#include "scene.cuh"
#include "ray.cuh"
#include "sphere.cuh"

bool Scene::intersect(const Ray& ray, Fragment& fragment) const {
	bool intersected = false;
	for (int i = 0; i < m_nbShapes; ++i) {
		intersected = m_shapes[i]->intersect(ray, fragment) || intersected;
	}
	return intersected;
}

glm::vec3 Scene::skyColor(glm::vec3 dir) const {
	//auto i = 0.5f * (dir + 1.f);
	//return (1.f - i) * glm::vec3{ 1.f } + i * glm::vec3{ 0.5f, 0.7f, 1.f };
	return glm::vec3{ 0.f };
}