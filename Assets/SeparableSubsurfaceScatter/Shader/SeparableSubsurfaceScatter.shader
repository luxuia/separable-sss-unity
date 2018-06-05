Shader "PostProcess/SeparableSubsurfaceScatter"
{
	Properties
	{
	}


	CGINCLUDE
#include "SeparableSubsurfaceScatterCommon.cginc"
#pragma target 3.0
	ENDCG

	SubShader
	{

		ZTest Always
		ZWrite Off
		Cull Off
		Stencil {
			Ref 5
			comp equal
			pass keep
		}

		Pass
		{
			Name "XBlur"
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fwdbase

			float4 frag(VertexOutput i) : SV_TARGET {
				float4 SceneColor = tex2D(_MainTex, i.uv);
				float SSSIntencity = (_SSSScale * _CameraDepthTexture_TexelSize.x);
				float3 XBlur = SSS(SceneColor, i.uv, float2(SSSIntencity, 0)).rgb;
				return float4(XBlur, SceneColor.a);
			}
			ENDCG
		}

		Pass
		{
			Name "YBlur"
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fwdbase

			float4 frag(VertexOutput i) : COLOR {
				float4 SceneColor = tex2D(_MainTex, i.uv);
				float SSSIntencity = (_SSSScale * _CameraDepthTexture_TexelSize.y);
				float3 YBlur = SSS(SceneColor, i.uv, float2(0, SSSIntencity)).rgb;
				return float4(YBlur, SceneColor.a);
			}
			ENDCG
		}
	}
}
