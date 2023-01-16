Shader "session3/ToonRamp" 
{
    Properties 
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _RampTex("Ramp Texture", 2D) = "white" {}
    }
    
    SubShader 
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry"
        } 
        
        Pass
        {
            Name "Universal Forward"
            Tags {"LightMode" = "UniversalForward"}
            
            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            float4 _MainTex_ST;
            Texture2D _MainTex;
            SamplerState sampler_MainTex;

            float4 _RampTex_ST;
            Texture2D  _RampTex;
            SamplerState sampler__RampTex;
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.normal = TransformObjectToWorldNormal(v.normal);
                o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                return o; 
            }

            half4 frag(VertexOutput i) : SV_Target
            {
                float3 Light = _MainLightPosition.xyz;
                float NdotL = dot(Light, i.normal);
                float halfNdotL = NdotL * 0.5 + 0.5; //NdotL(내적) 범위(-1~1)를 (0~1)로 변경.

                float4 color = _MainTex.Sample(sampler_MainTex, i.uv);
                float3 ambient = SampleSH(i.normal);
                float3 ramp = _RampTex.Sample(sampler_MainTex, float2(halfNdotL, 0));
                color.rgb = color.rgb * ramp + ambient;

                return color;
            } 
            
            ENDHLSL
        }
    }
}