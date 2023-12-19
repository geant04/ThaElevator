Shader "Custom/Waves"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Amplitude ("Amplitude", Float) = 1.0
        _Wavelength ("Wavelength", Range(0, 10)) = 1
        _Speed ("Speed", Range(0, 10)) = 1
        _Light ("Light Color", Color) = (1,1,1,1)
        _AmbientColor ("Ambient Color", Color) = (1,1,1,1)
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        _specularShine ("Shininess", Range(0, 100)) = 14.0
        _FresnelBias ("Fresnel Bias", Range(0, 50)) = 8.0
        _FresnelShine ("Fresnel Shininess",  Range(0, 100)) = 14.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Water fullforwardshadows vertex:vert
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        float random (float u, float v)
        {
            float2 uv = float2(u, v);
            return frac(sin(dot(uv,float2(12.9898,78.233)))*43758.5453123);
        }

        half _Glossiness;
        half _Metallic;
        fixed4 _Color, _Light, _AmbientColor, _FresnelColor;
        float _Amplitude, _Wavelength, _Speed, _specularShine, _FresnelShine;

        half4 LightingWater (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
            float4 lightColor = _Light;
            float ambientStrength = 0.25;
            float3 ambient = _AmbientColor * ambientStrength;

            half3 halfwayDir = normalize(lightDir + viewDir);
            float diff = max(dot(s.Normal, lightDir), 0.0) * 0.50;

            float3 fresNormal = s.Normal;
            fresNormal = normalize(fresNormal);
            float fdot = 1 - dot(viewDir, fresNormal);
            fdot /= 2.0;
            float fresnelSpec = pow(fdot, _FresnelShine);
            float3 fresnel = _FresnelColor.rgb * fresnelSpec;
            
            float shininess = _specularShine;
            float nh = max(0.0, dot(s.Normal, halfwayDir));
            float spec = pow(nh, shininess * shininess);

            float fbase = 1 - (dot(viewDir, halfwayDir));
            fresnelSpec = pow(fbase, 5.0) + 0.20;
            spec *= fresnelSpec + 8.0 * fresnelSpec;

            float3 highlights = lightColor.rgb * spec;

            float3 diffuse = diff * lightColor;
            float3 result = (ambient + diffuse * diffuse) * s.Albedo;

            half4 c;
            c.rgb = (result + highlights + fresnel);
            c.a = s.Alpha;

            return c;
        }

        float FBMSineWave(float4 wave, float3 p, 
                            inout float tangent, inout float binormal, 
                            inout float2 prevPartial, float waveNumber) {
            // x,y = direction
            // w = amplitude, z = speed?
            // p is the position
            float2 d = normalize(wave.xy);
            float amp = wave.z;
            float freq = wave.w;
            float h = 0.0;
            float wavelength = (_Wavelength * 100) * (random(d.x, d.y) - 0.5);

            for(int i=0; i < 32; i++) {
                float xz = d.x * (p.x + prevPartial.x) + d.y * (p.z + prevPartial.y);
                float omega = 0.8 * UNITY_PI / wavelength;

			    h += amp * sin(omega * xz + _Time.y * freq);

                prevPartial.x = amp * omega * cos(omega * xz + _Time.y * freq);
                prevPartial.y = amp * freq * cos(omega * xz + _Time.y * freq);

                tangent += prevPartial.x;
                binormal += prevPartial.y;

                freq *= 1.18;
                amp *= 0.60;
                wavelength *= 0.67;
            }

            return h;
        }

        void vert(inout appdata_full vertexData) {
            float3 p = vertexData.vertex.xyz;
            float dx = 0.0;
            float dz = 0.0;
            float2 prevPartial = float2(0.0, 0.0);

            for(int i=0; i<32; i++) {
                float2 dir = float2(2.0 * (random(i*i, i*i) - 0.5), 
                                     2.0 * (random(i*i, i) - 0.5));
                float randAmp = random(i, i)  - 0.5;
                float randSpeed = 2.0 * (random(i+4, i * 10) - 0.5);

                float4 wave = float4(dir.x, dir.y, 
                                    _Amplitude * 2.0 * randAmp, 
                                    _Speed * randSpeed);

                p.y += FBMSineWave(wave, p, dx, dz, prevPartial, i);
            }

            float3 tangent = float3(1.0, dx, 0.0);
            float3 binormal = float3(0.0, dz, 1.0);

			float3 normal = normalize(cross(binormal, tangent));
			vertexData.vertex.xyz = p;
			vertexData.normal = normal;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            // Metallic and smoothness come from slider variables
            //o.Metallic = _Metallic;
            //o.Smoothness = _Glossiness;
            //o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
