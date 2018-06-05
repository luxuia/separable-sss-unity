Shader "Custom/StencilSurface" {
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}

		_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
		_GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
		[Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel("Smoothness texture channel", Float) = 0

		_BumpScale("Scale", Float) = 1.0
		_BumpMap("Normal Map", 2D) = "bump" {}

		_OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
		_OcclusionMap("Occlusion", 2D) = "white" {}

	}

CGINCLUDE
		#define UNITY_SETUP_BRDF_INPUT MetallicSetup
ENDCG

	SubShader
	{
		Tags{ "RenderType" = "Opaque" "PerformanceChecks" = "False" }
		LOD 300

		// ------------------------------------------------------------------
		//  Base forward pass (directional light, emission, lightmaps, ...)
	Pass
	{
		Name "FORWARD"
		Tags{ "LightMode" = "ForwardBase" }

		Blend One Zero
		ZWrite On

		Stencil{
			Ref 5
			comp always
			pass replace
		}
		CGPROGRAM
#pragma target 3.0

		// -------------------------------------

#pragma shader_feature _NORMALMAP

#pragma multi_compile_fwdbase
#pragma multi_compile_fog
#pragma multi_compile_instancing
		// Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
		//#pragma multi_compile _ LOD_FADE_CROSSFADE

#pragma vertex vertBase
#pragma fragment fragBase
#include "UnityStandardCoreForward.cginc"

		ENDCG
	}
		// ------------------------------------------------------------------
		//  Additive forward pass (one light per pass)
		Pass
	{
		Name "FORWARD_DELTA"
		Tags{ "LightMode" = "ForwardAdd" }
		Blend One One
		Fog{ Color(0,0,0,0) } // in additive pass fog should be black
		ZWrite Off
		ZTest LEqual

		CGPROGRAM
#pragma target 3.0

		// -------------------------------------


#pragma shader_feature _NORMALMAP

#pragma multi_compile_fwdadd_fullshadows
#pragma multi_compile_fog
		// Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
		//#pragma multi_compile _ LOD_FADE_CROSSFADE

#pragma vertex vertAdd
#pragma fragment fragAdd
#include "UnityStandardCoreForward.cginc"

		ENDCG
	}
		// ------------------------------------------------------------------
		// Extracts information for lightmapping, GI (emission, albedo, ...)
		// This pass it not used during regular rendering.
		Pass
	{
		Name "META"
		Tags{ "LightMode" = "Meta" }

		Cull Off

		CGPROGRAM
#pragma vertex vert_meta
#pragma fragment frag_meta

#include "UnityStandardMeta.cginc"
		ENDCG
	}
	}

	FallBack "Standard"
}
