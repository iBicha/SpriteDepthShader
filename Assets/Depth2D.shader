Shader "Unlit/Depth2D"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_DepthTex("Depth", 2D) = "white" {}
		_rX("RotateX", float) = 0
		_rY("RotateY", float) = 0
		_rZ("RotateZ", float) = 0
		_Animate("Animate Angle", float) = 0
		_Speed("Animate Speed", float) = 0
}
	SubShader
	{
	    //Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	    Tags {"RenderType"="Opaque"}
     	LOD 100
     
     	//ZWrite Off
     	//Blend SrcAlpha OneMinusSrcAlpha 
     	Cull Off

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

			sampler2D _MainTex;
			sampler2D _DepthTex;
			float4 _MainTex_ST;
			float4 _DepthTex_ST;
			float _rX,_rY,_rZ;
			float _rX2,_rY2,_rZ2;
			float _Animate, _Speed;

			v2f vert (appdata v)
			{

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.uv2, _DepthTex);
				//We will want to change angle by viewing vector. Maybe later.
				//o.viewDir = UNITY_MATRIX_IT_MV[2].xyz;
				return o;
			}
			
			float4 rotate(float4 vec)
			{
 				float angleX = radians(_rX2);
				float angleY = radians(_rY2);
				float angleZ = radians(_rZ2);

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
				//Prepare some angles
				_rX2 = cos(_Time.y * _Speed) * _Animate + _rY;
			 	_rY2 = sin(_Time.y * _Speed) * _Animate + _rX;
			 	_rZ2 = _rZ;

			 	//Getting the depth value
				fixed4 depth = tex2D(_DepthTex, i.uv2);

				//rotating depth value, using depth value
				float4 pos;
				pos.xy = i.uv2.xy;
				pos.z = Luminance(depth.rgb);
				pos.w = 1;

				pos.xyz -= 0.5;
				pos = rotate(pos);
				pos.xyz += 0.5;

			    depth = tex2D(_DepthTex, pos.xy);

				//rotating rgb value, using rotated depth value
				pos.xy = i.uv.xy;
				pos.z = Luminance(depth.rgb);
				pos.w = 1;

				pos.xyz -= 0.5;
				pos = rotate(pos);
				pos.xyz += 0.5;

				// sample the texture
				fixed4 col = tex2D(_MainTex, pos.xy) ;
				return col;
			}

			ENDCG
		}
	}
}
