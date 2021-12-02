#pragma once

#include "math.cuh"

class Ray;

class Camera {
public:
	CPU_GPU explicit Camera(float imgWidth, float imgHeight, glm::vec3 position = { 0.f, 1.f, 5.f }, glm::vec3 at = glm::vec3{ 0.f }, glm::vec3 worldUp = glm::vec3{ 0.f, 1.f, 0.f }, float fov = 70.f);

	GPU_ONLY Ray castRay(float u, float v) const;

private:
	float m_aspect;
	glm::vec3 m_position;
	glm::vec3 m_front;
	glm::vec3 m_right;
	glm::vec3 m_up;
	glm::vec3 m_center;
	float m_fov;

	float m_imgWidth, m_imgHeight;
};