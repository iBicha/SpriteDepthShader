shader "gamevial/gasgiant2" {
	properties{
		_MainTex("Diffuse", 2D) = "white" {}
	_RippleTex("Ripple (RGB) Trans (A)", 2D) = "black" {}

	_Shininess("Shininess",Float) = 10
		_OffsetX("UV Offset X",Float) = .5
		_OffsetY("UV Offset Y",Float) = .5
		_Push1("Direction",Vector) = (0,0,1,1)

		_Fade("Fade Edges",Range(0,10)) = .1

	}


		SubShader{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }

		CGPROGRAM

#pragma target 3.0
#pragma surface surf Lambert alpha
#include "UnityCG.cginc"

		uniform sampler2D _MainTex;
	uniform sampler2D _BumpTex;
	uniform sampler2D _RippleTex;
	float _OffsetX,_OffsetY;
	float _Fade;
	float4 _Push1;
	struct Input {
		float2 uv_MainTex;
		float2 uv_RippleTex;
		float3 viewDir;
	};

	void surf(Input IN, inout SurfaceOutput o)
	{
		float2 ripuv1 = IN.uv_RippleTex + _Push1.xy*_Time[0];
		float2 ripuv2 = IN.uv_RippleTex + _Push1.zw*_Time[0];
		half4 vRip = tex2D(_RippleTex,ripuv1) + tex2D(_RippleTex,ripuv2) - half4(1,1,1,1);
		float2 uv = IN.uv_MainTex + float2((vRip.r)*_OffsetX,(vRip.g)*_OffsetY);
		float4 c = tex2D(_MainTex, uv);
		o.Albedo = c.rgb;
		o.Alpha = pow(dot(normalize(IN.viewDir),o.Normal),_Fade);
	}
	ENDCG
	}


}
