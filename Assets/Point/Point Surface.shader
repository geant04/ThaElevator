Shader "Graph/Point Surface" {
	Properties {
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
	}

	SubShader {
		// code section of hybrid CG and HLSL
		CGPROGRAM
		// ConfigureSurface is a method used to configure the shader
		#pragma surface ConfigureSurface Standard fullforwardshadows
		#pragma target 3.0

		struct Input {
			float3 worldPos;
		};

		float _Smoothness;

		void ConfigureSurface (Input input, inout SurfaceOutputStandard surface) {
			surface.Albedo = saturate(input.worldPos * 0.5 + 0.5);
			surface.Smoothness = _Smoothness;
		}
		ENDCG
	}
	// this is to make sure we fallback to the default diffuse lighting
	FallBack "Diffuse"
}