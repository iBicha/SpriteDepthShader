Shader "Unlit/Depth2D"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_DepthTex("Depth Map", 2D) = "white" {}
		_DepthTex2("Processed Depth Map", 2D) = "white" {}
		_RotationAngle("Rotation Angle", Vector) = (0,0,0,0)
		_RotationCenter("Rotation Center", Vector) = (0.5,0.5,0.5,0)
		_FillColor ("Fill Gap Color", COLOR) = (1,0,1,1) 
		[Toggle(ANGLE_ANIMATE)] _ToggleAnimation ("Animation", Float) = 0
        _Animate("Animation Angle", float) = 0
		_Speed("Animation Speed", float) = 0

	} 
	SubShader
	{
		Pass
		{
		 	Name "Depth2DMain"
		 	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

			ZTest Always 
			Cull Off 
			ZWrite Off 
     		Blend SrcAlpha OneMinusSrcAlpha 

			CGPROGRAM
			#pragma shader_feature ANGLE_ANIMATE

			#pragma vertex vert
			#pragma fragment frag
			
			#include "Depth2D.cginc"
			#include "UnityCG.cginc"


			sampler2D _MainTex;
			sampler2D _DepthTex2;
			float4 _MainTex_ST;
			float4 _DepthTex2_ST;

			float4 _RotationAngle, _RotationCenter;
			float _Animate, _Speed;

			v2f vert (appdata v)
			{

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.uv2, _DepthTex2);
				//We will want to change angle by viewing vector. Maybe later.
				//o.viewDir = UNITY_MATRIX_IT_MV[2].xyz;
				return o;
			} 

			fixed4 frag (v2f i) : SV_Target
			{
			 	//Getting the depth value
				fixed4 depth2 = tex2D(_DepthTex2, i.uv2);
#if ANGLE_ANIMATE 
				_RotationAngle = animateAngle(_RotationAngle, _Speed, _Animate);
#endif
				//rotating depth value, using depth value
				float4 pos = float4(i.uv.x, i.uv.y, Luminance(depth2.rgb), 1);
				pos = rotate(pos, _RotationAngle, _RotationCenter);

				fixed4 col = tex2D(_MainTex, pos.xy); 
				return col;
			}

			ENDCG
		}

	}
}
