#include "UnityCG.cginc"
#define DistanceToProjectionWindow 5.671281819617709             //1.0 / tan(0.5 * radians(20));
#define DPTimes300 1701.384545885313                             //DistanceToProjectionWindow * 300

#define SamplerSteps 25
uniform sampler2D _CameraDepthTexture;
float4 _CameraDepthTexture_TexelSize;

uniform sampler2D _MainTex;
uniform float4 _MainTex_ST;
uniform float _SSSScale;
uniform float4 _Kernel[SamplerSteps];

struct VertexInput {
	float4 vertex : POSITION;
	float2 uv :TEXCOORD0;
};

struct VertexOutput {
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
};

VertexOutput vert(VertexInput v) {
	VertexOutput o;
	o.pos = v.vertex;
	o.uv = v.uv;
	return o;
}

float4 SSS(float4 SceneColor, float2 UV, float2 SSSIntencity) {
	float SceneDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, UV));
	float BlurLength = DistanceToProjectionWindow / SceneDepth;
	float2 UVOffset = SSSIntencity * BlurLength;
	float4 BlurSceneColor = SceneColor;
	BlurSceneColor.rgb *= _Kernel[0].rgb;

	[loop]
	for (int i = 1; i < SamplerSteps; i++) {
		float2 SSSUV = UV + _Kernel[i].a * UVOffset;
		float4 SSSSceneColor = tex2D(_MainTex, SSSUV);
		float SSSDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, SSSUV)).r;
		float SSSScale = saturate(DPTimes300 * SSSIntencity * abs(SceneDepth - SSSDepth));
		SSSSceneColor.rgb = lerp(SSSSceneColor.rgb, SceneColor.rgb, SSSScale);
		BlurSceneColor.rgb += _Kernel[i].rgb * SSSSceneColor.rgb;
	}
	return BlurSceneColor;
}