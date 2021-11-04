Shader "Owlet/Procedural/Pattern Spiral"
{
    Properties
    {
        _BaseColor("Color", Color) = (1, 1, 1, 1)
        _Frequency("Frequency", Vector) = (2, 2, 0, 0)
    }

    SubShader
    {
        Tags {
            "RenderType" = "Opaque" 
            "IgnoreProjector" = "True" 
            "RenderPipeline" = "UniversalPipeline" 
            "ShaderModel"="2.0"
        }
        LOD 100

        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

        Pass
        {
            Name "Unlit"

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Shaders/Procedural.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half2 _Frequency;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                float4 vertex       : SV_POSITION;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                output.vertex = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                float rotation = _Time.y * 2;
                float2 center = float2(0.5, 0.5);
                float2 uv = input.uv - center;
                float s = sin(rotation);
                float c = cos(rotation);
                float2x2 rMatrix = float2x2(c, -s, s, c);
                rMatrix *= 0.5;
                rMatrix += 0.5;
                rMatrix = rMatrix * 2 - 1;
                uv.xy = mul(uv.xy, rMatrix);
                uv += center;

                float strength = 24;
                float2 delta = uv - center;
                float angle = strength * length(delta);
                float x = cos(angle) * delta.x - sin(angle) * delta.y;
                float y = sin(angle) * delta.x + cos(angle) * delta.y;
                uv = float2(x + center.x, y + center.y);

                delta = uv - center;
                float radius = length(delta) * 2 * -0.4;
                angle = atan2(delta.x, delta.y) * 1.0/6.28 * 26;
                uv = float2(radius, angle);

                return _BaseColor * length(step(float2(0, 1), uv));
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor ""
}
