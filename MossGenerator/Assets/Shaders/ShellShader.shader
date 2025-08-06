Shader "Custom/ShellShader"
{
    Properties
    {
        _MossTex ("Moss Texture (Alpha = Height)", 2D) = "white" {}
        _ShellOffset ("Shell Offset", Float) = 0.01
        _ShellIndex ("Shell Index", Float) = 0
        _ShellCount ("Shell Count", Float) = 8
        _AlphaThreshold ("Alpha Discard Threshold", Range(0,1)) = 0.01
        _NoiseTex ("Noise Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="TransparentCutout" }
        LOD 200

        Cull Off
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MossTex;
            sampler2D _NoiseTex;
            float _ShellOffset;
            float _ShellIndex;
            float _ShellCount;
            float _AlphaThreshold;

            float3 _ShellColor;

            float _ShellLength; // This is the amount of distance that the shells cover, if this is 1 then the shells will span across 1 world space unit
			float _Density;  // This is the density of the strands, used for initializing the noise
			float _NoiseMin, _NoiseMax; // This is the range of possible hair lengths, which the hash then interpolates between 
			float _Thickness;

            float _ShellDistanceAttenuation;
            float _Attenuation;
            float _Curvature;
            float _DisplacementStrength;
            float _OcclusionBias;


            float hash(float2 p)
            {
                return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                float p = _ShellIndex / _ShellCount;

                float noiseVal = hash(v.uv * _Density);
                float hairLength = lerp(_NoiseMin, _NoiseMax, noiseVal) * _ShellLength;

                float3 tangentDir = normalize(cross(v.normal, float3(0,1,0)));
                float3 wiggleDir = normalize(cross(v.normal, tangentDir));

                float wiggle = sin(_Time.y * 2 + dot(v.vertex.xyz, float3(1.2, 0.8, 1.0)) + p * 10.0) * 0.05;

                float3 offset = v.normal * hairLength * p * _ShellDistanceAttenuation + wiggle * wiggleDir * _DisplacementStrength;

                float4 worldPos = v.vertex + float4(offset, 0.0);
                o.pos = UnityObjectToClipPos(worldPos);

                o.normal = v.normal;
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                fixed4 mossSample = tex2D(_MossTex, i.uv);
                float p = _ShellIndex / _ShellCount;
                float texBrightness = dot(mossSample.rgb, float3(0.3, 0.6, 0.1)); // weighted green
                float uvDarken = saturate(3.0 * p);
                float shade = texBrightness * uvDarken;

                float3 lightDir = normalize(float3(0.3, 1, 0.5));
                float diffuse = saturate(dot(normalize(i.normal), lightDir));
                diffuse = lerp(0.3, 1.0, diffuse);
                shade *= diffuse;

                float divisions = 1000.0;
                float2 localUV = frac(i.uv * divisions) * 2.0 - 1.0;

                float noiseVal = tex2D(_NoiseTex, i.uv * _Density).r;
                if (noiseVal < p || noiseVal > p + _Thickness)
                    discard;
                    
                // compute distance to cone
                float d = length(localUV) - (1.0 - p);

                // test if inside the cone
                if (d < 0.0)
                {
                    return float4(_ShellColor.rgb * shade, 1.0);
                }
                else
                {
                    discard;
                }
                return float4(0.0,0.0,0.0,0.0);
                
            }
            ENDCG
        }
    }
}
