Shader "Unlit/Depth2D"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_DepthTex("Depth", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

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
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 viewDir : NORMAL;
			};

			sampler2D _MainTex;
			sampler2D _DepthTex;
			float4 _MainTex_ST;
			float4 _DepthTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.viewDir = UNITY_MATRIX_IT_MV[2].xyz;
				return o;
			}
			
			float rotate(float4 vec, float3 angle)
			{
				float angleX = angle.x;
				float c = cos(angleX);
				float s = sin(angleX);
				float4x4 rotateXMatrix = float4x4(1, 0, 0, 0,
					0, c, -s, 0,
					0, s, c, 0,
					0, 0, 0, 1);

				float angleY = angle.y;
				c = cos(angleY);
				s = sin(angleY);
				float4x4 rotateYMatrix = float4x4(c, 0, s, 0,
					0, 1, 0, 0,
					-s, 0, c, 0,
					0, 0, 0, 1);

				float angleZ = angle.y;
				c = cos(angleZ);
				s = sin(angleZ);
				float4x4 rotateZMatrix = float4x4(c, -s, 0, 0,
					s, c, 0, 0,
					0, 0, 1, 0,
					0, 0, 0, 1);

				float4 translatedRotX = mul(vec, rotateXMatrix);
				float4 translatedRotXY = mul(translatedRotX, rotateYMatrix);
				float4 translatedRotXYZ = mul(translatedRotXY, rotateZMatrix);
				return translatedRotXYZ;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col1 = tex2D(_MainTex, i.uv);

				float4 pos;
				pos.x = i.uv.x - 0.5;
				pos.y = i.uv.y - 0.5;
				pos.z = tex2D(_DepthTex, i.uv).r - 0.5;
				pos.w = 1;
				//rotate
				pos = rotate(pos, i.viewDir);
				pos.x += 0.5;
				pos.y += 0.5;
				pos.z += 0.5;

				float2 uv2 = pos.xy;
				// sample the texture
				fixed4 col2 = tex2D(_MainTex, uv2);
				col2.a = col1.a;
				return col2;
			}

			ENDCG
		}
	}
}
