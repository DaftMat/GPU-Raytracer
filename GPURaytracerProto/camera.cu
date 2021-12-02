#include "camera.cuh"
#include "ray.cuh"

Camera::Camera(float imgWidth, float imgHeight, glm::vec3 position, glm::vec3 at, glm::vec3 worldUp, float fov) :
	m_aspect{ imgWidth / imgHeight },
	m_position{ position },
	m_fov{ fov },
	m_imgWidth{ imgWidth },
	m_imgHeight{ imgHeight }
{
	m_front = glm::normalize(at - position);
	m_right = glm::normalize(glm::cross(worldUp, m_front));
	m_up = glm::normalize(glm::cross(m_front, m_right));
	m_center = 1.f / tanf((m_fov * glm::pi<float>() / 180.f) * 0.5f) * m_front;

}

Ray Camera::castRay(float u, float v) const {
	float aspectInv = 1.f / m_aspect;

	float deltay = 1.f / (m_imgHeight * 0.5f);   //! one pixel size
	glm::vec3 dy = deltay * aspectInv * m_up; //! one pixel step
	glm::vec3 raydeltay = (0.5f - m_imgHeight * 0.5f) / (m_imgHeight * 0.5f) * aspectInv * m_up;

	float deltax = 1.f / (m_imgWidth * 0.5f);
	glm::vec3 dx = deltax * m_right;
	glm::vec3 raydeltax = (0.5f - m_imgWidth * 0.5f) / (m_imgWidth * 0.5f) * m_right;

	glm::vec3 corner = m_center + raydeltax - raydeltay;
	glm::vec3 rayDir = corner + u * dx - v * dy;

	return Ray{ m_position, glm::normalize(rayDir) };
}