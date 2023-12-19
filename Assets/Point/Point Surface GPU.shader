Shader "Graph/Point Surface GPU" {
	Properties {
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
	}

	SubShader {
		// code section of hybrid CG and HLSL
		CGPROGRAM
		// ConfigureSurface is a method used to configure the shader
		#pragma surface ConfigureSurface Standard fullforwardshadows addshadow
		#pragma instancing_options assumeuniformscaling procedural:ConfigureProcedural
		#pragma editor_sync_compilation
		#pragma target 4.5

		#include "PointGPU.hlsl"

		struct Input {
			float3 worldPos;
		};

		float _Smoothness;

		void ConfigureSurface (Input input, inout SurfaceOutputStandard surface) {
			surface.Albedo = saturate(( (input.worldPos - float3(0.0, 0.1, 10.0)) / 15.0) * 0.5 + 0.5) * 1.2;
			surface.Smoothness = _Smoothness;
		}
		ENDCG
	}
	// this is to make sure we fallback to the default diffuse lighting
	FallBack "Diffuse"
}