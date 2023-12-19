Shader "Custom/BasicToon"
{
    Properties
    {
    	_Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _Color("Color", Color) = (1,1,1,1)
        _AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
        _LightColor("Light Color", Color) = (0.4,0.4,0.4,1)
        _SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
        _Glossiness("Glossiness", Range(0, 64)) = 32
        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimAmount("Rim Amount", Range(0, 1)) = 0.716
        _RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface ConfigureSurface Stepped fullforwardshadows
        #pragma target 3.0

        struct Input
        {
        	float3 worldPos;
        };

        float _Smoothness;
        float4 _AmbientColor;
        float4 _Color;
        float4 _LightColor;
        float _Glossiness;
        float4 _SpecularColor;
        float4 _RimColor;
        float _RimAmount;
        float _RimThreshold;

        half4 LightingStepped (SurfaceOutput s, half3 viewDir, half atten) {
            half3 lightSRC = half3(10.0, 10.0, 10.0);    

            half3 h = normalize (lightSRC + viewDir);
            half NdotH = dot (s.Normal, h);
            float NdotL = dot (s.Normal, lightSRC);
            float intensity = smoothstep(0, 0.01, NdotL);
            float specularIntensity = pow(NdotH * intensity, _Glossiness * _Glossiness);
            float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
            float4 specular = specularIntensitySmooth * _SpecularColor;

            float4 rimDot = 1 - dot(viewDir, s.Normal);
            //float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
            float rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimDot);
            float4 rim = rimIntensity * _RimColor;

            float4 light = intensity * _LightColor;
            return _Color * (_AmbientColor + light + specular + rim);
        }

        void ConfigureSurface (Input input, inout SurfaceOutput surface) {
			surface.Albedo = _Color;
		}


        ENDCG
    }
    FallBack "Diffuse"
}
