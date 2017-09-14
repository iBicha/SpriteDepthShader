// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Matrix PlayGround Shader - UnityCoder.com
// References:
// Matrices http://www.codinglabs.net/article_world_view_projection_matrix.aspx
// Rotation: http://www.gamedev.net/topic/610115-solved-rotation-deforming-mesh-opengl-es-20/#entry4859756

Shader "UnityCoder/MatrixPlayground"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	_tX("TranslateX", float) = 0
		_tY("TranslateY", float) = 0
		_tZ("TranslateZ", float) = 0
		_sX("ScaleX", float) = 1
		_sY("ScaleY", float) = 1
		_sZ("ScaleZ", float) = 1
		_rX("RotateX", float) = 0
		_rY("RotateY", float) = 0
		_rZ("RotateZ", float) = 0
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		//Cull Off

		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

		struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		UNITY_FOG_COORDS(1)
			float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	float _tX,_tY,_tZ;
	float _sX,_sY,_sZ;
	float _rX,_rY,_rZ;

	v2f vert(appdata v)
	{
		v2f o;

		float4x4 translateMatrix = float4x4(1,	0,	0,	_tX,
			0,	1,	0,	_tY,
			0,	0,	1,	_tZ,
			0,	0,	0,	1);

		float4x4 scaleMatrix = float4x4(_sX,	0,	0,	0,
			0,	_sY,0,	0,
			0,	0,	_sZ,0,
			0,	0,	0,	1);

		float angleX = radians(_rX);
		float c = cos(angleX);
		float s = sin(angleX);
		float4x4 rotateXMatrix = float4x4(1,	0,	0,	0,
			0,	c,	-s,	0,
			0,	s,	c,	0,
			0,	0,	0,	1);

		float angleY = radians(_rY);
		c = cos(angleY);
		s = sin(angleY);
		float4x4 rotateYMatrix = float4x4(c,	0,	s,	0,
			0,	1,	0,	0,
			-s,	0,	c,	0,
			0,	0,	0,	1);

		float angleZ = radians(_rZ);
		c = cos(angleZ);
		s = sin(angleZ);
		float4x4 rotateZMatrix = float4x4(c,	-s,	0,	0,
			s,	c,	0,	0,
			0,	0,	1,	0,
			0,	0,	0,	1);


		float4 localVertexPos = v.vertex;

		// NOTE: the order matters, try scaling first before translating, different results
		float4 localTranslated = mul(translateMatrix,localVertexPos);
		float4 localScaledTranslated = mul(localTranslated,scaleMatrix);
		float4 localScaledTranslatedRotX = mul(localScaledTranslated,rotateXMatrix);
		float4 localScaledTranslatedRotXY = mul(localScaledTranslatedRotX,rotateYMatrix);
		float4 localScaledTranslatedRotXYZ = mul(localScaledTranslatedRotXY,rotateZMatrix);

		o.vertex = UnityObjectToClipPos(localScaledTranslatedRotXYZ);

		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv);
	return col;
	}
		ENDCG
	}
	}
}