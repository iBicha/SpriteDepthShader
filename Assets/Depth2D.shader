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
		Cull Off
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

			float scale = 0.5;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.viewDir = UNITY_MATRIX_IT_MV[2].xyz;
				return o;
			}
			
			float4 rotate(float4 vec, float3 angle)
			{
 				float angleX = angle.y;
				float angleY = angle.x;
				float angleZ = angle.z;

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

				vec = mul(vec, rotateXMatrix);
				vec = mul(vec, rotateYMatrix);
				vec = mul(vec, rotateZMatrix);
				return vec;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 depth = tex2D(_DepthTex, i.uv);
				float4 pos;
				pos.x = i.uv.x;
				pos.y = i.uv.y;
				pos.z = depth.r;
				pos.w = 1;

				pos.xyz -= 0.5;

				//rotate
				pos = rotate(pos, i.viewDir);
				
				pos.xyz += 0.5;

				// sample the texture
				fixed4 col = tex2D(_MainTex, pos.xy) ;
				return col;
			}

			ENDCG
		}
	}
}
