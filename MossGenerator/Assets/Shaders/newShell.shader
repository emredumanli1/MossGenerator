Shader "Custom/newShell"
{
    Properties
    {
        _MossTex ("Moss Texture (Alpha = Height)", 2D) = "white" {}
        _ShellOffset ("Shell Offset", Float) = 0.01
        _ShellIndex ("Shell Index", Float) = 0
        _ShellCount ("Shell Count", Float) = 8
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _RotationTex("Rotation Texture" , 2D) = "white" {}
        _ShellColor ("Shell Color", Color) = (0.3, 0.7, 0.3, 1)
        _ShellLength ("Shell Length", Float) = 1.0
        _Density ("Noise Density", Float) = 100.0
        _NoiseMin ("Noise Min", Float) = 0.6
        _NoiseMax ("Noise Max", Float) = 1.0
        _Thickness ("Thickness", Float) = 0.1
        _ShellDistanceAttenuation ("Distance Attenuation", Float) = 1.0
        _DisplacementStrength ("Displacement Strength", Float) = 1.0
        _Growth("Growth", Range(0, 1)) = 0

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
            sampler2D _RotationTex;

            float _ShellOffset;
            float _ShellIndex;
            float _ShellCount;

            float4 _ShellColor;
            float _ShellLength;
            float _Density;
            float _NoiseMin, _NoiseMax;
            float _Thickness;
            float _ShellDistanceAttenuation;
            float _DisplacementStrength;
            float _Growth;


            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };

            float hash(float2 p)
            {
                return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
            }

            v2f vert(appdata v)
            {
                v2f o;
                float p = _ShellIndex / _ShellCount;

                float noiseVal = frac(sin(dot(v.uv * _Density, float2(12.9898,78.233))) * 43758.5453);
                float hairLength = lerp(_NoiseMin, _NoiseMax, noiseVal) * _ShellLength;


                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                float3 tangentDir = normalize(cross(v.normal, float3(0,1,0)));
                float3 wiggleDir = normalize(cross(v.normal, tangentDir));
                float windPhase = dot(v.uv, float2(12.9898, 78.233)) + _ShellIndex * 0.3;
                float windStrength = sin(_Time.y * 1.5 + windPhase) * 0.2;
                
                float shellFactor = _ShellOffset + p * hairLength * _ShellDistanceAttenuation;
                float3 offset = worldNormal * shellFactor + wiggleDir * windStrength * _DisplacementStrength;

                //float3 offset = worldNormal * hairLength * p * _ShellDistanceAttenuation + wiggleDir * windStrength * _DisplacementStrength;

                o.pos = UnityWorldToClipPos(float4(worldPos + offset, 1.0));
                o.normal = worldNormal;
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float p =  (_ShellIndex + 1) / _ShellCount;

                fixed4 mossSample = tex2D(_MossTex, i.uv);
                float texBrightness = dot(mossSample.rgb, float3(0.3, 0.6, 0.1));
                float shade = texBrightness * saturate(3.0 * p);

                float3 lightDir = normalize(float3(0.3, 1, 0.5));
                float diffuse = saturate(dot(normalize(i.normal), lightDir));
                //diffuse = lerp(0.3, 1.0, diffuse);
                shade *= diffuse;


                // Hash-based rotation angle per shell
                float randAngle = frac(sin(dot(i.uv + _ShellIndex, float2(12.9898, 78.233))) * 43758.5453);
                
                fixed4 rotateSample = tex2D(_RotationTex, i.uv);
                float angle = rotateSample.r * 6.2831; // [0, 2] radians

                float cosA = cos(angle);
                float sinA = sin(angle);
                float2 centerUV = frac(i.uv * _Density) - 0.5;
                float2 rotatedUV = float2(
                    centerUV.x * cosA - centerUV.y * sinA,
                    centerUV.x * sinA + centerUV.y * cosA
                ) + 0.5 + floor(i.uv * _Density); // Put it back into world tiling


                float noiseVal = tex2D(_NoiseTex, rotatedUV).r;

                //return float4(frac(rotatedUV), 0, 1); // R = rotated U, G = rotated V


                //float noiseVal = tex2D(_NoiseTex, i.uv * _Density).r;
                
                if (noiseVal < p || noiseVal > p + _Thickness)
                    discard;

                float2 localUV = frac(i.uv * _Density);
                float strand = 1.0 - smoothstep(0.497, 0.5, abs(localUV.x - 0.5));
                if (strand < 0.05)
                    discard;
                if (mossSample.a < 0.1)
                    discard;
                if (p > _Growth)
                    discard;

                return float4(_ShellColor.rgb * shade, 1.0);
            }
            ENDCG
        }
    }
}
