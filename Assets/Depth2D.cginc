#ifndef DEPTH_2D_INCLUDED
#define DEPTH_2D_INCLUDED

#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				//float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 vertex : SV_POSITION;
				//float3 viewDir : NORMAL; //Viewing angle.
			};

float4 rotate(float4 vec, float3 angle, float4 center)
{

	float a = cos(0);

	float angleX = radians(angle.x);
	float angleY = radians(angle.y);
	float angleZ = radians(angle.z);

	float c = cos(angleX);
	float s = sin(angleX);
	float4x4 rotateXMatrix = float4x4(1, 0, 0, 0,
		0, c, -s, 0,
		0, s, c, 0,
		0, 0, 0, 1);

	c = cos(angleY);
	s = sin(angleY);
	float4x4 rotateYMatrix = float4x4(c, 0, s, 0,
		0, 1, 0, 0,
		-s, 0, c, 0,
		0, 0, 0, 1);

	c = cos(angleZ);
	s = sin(angleZ);
	float4x4 rotateZMatrix = float4x4(c, -s, 0, 0,
		s, c, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1);

	vec -= center;
	vec = mul(vec, rotateXMatrix);
	vec = mul(vec, rotateYMatrix);
	vec = mul(vec, rotateZMatrix);
	vec += center;
	return vec;
}

#if ANGLE_ANIMATE
float4 animateAngle(float4 angle, float speed, float animateAngle) {
	angle.x = cos(_Time.y * speed) * animateAngle + angle.x;
	angle.y = sin(_Time.y * speed) * animateAngle + angle.y;
	return angle;
}
#endif


#endif
