Shader "session3/ToonLight" 
{
    Properties 
    {
        _AmbientColor("Ambient color",color)=(0,0,0,0)
        _LightWidth("Light Width",Range(0,255))=1
        _LightStep("Light Step",Range(0,20))=10
    }

    SubShader 
    {
        Tags {"RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry"} 
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
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            float4 _AmbientColor;
            float _LightWidth;
            float _LightStep;

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.normal = TransformObjectToWorldNormal(v.normal);
                return o; 
            }

            half4 frag(VertexOutput i) : SV_Target
            {
                float4 color = float4(1,1,1,1);
                float3 LightColor = _MainLightColor.rgb;
                float3 Light = _MainLightPosition.xyz;
                float3 NdotL = saturate(dot( i.normal,Light));
                
                float3 toonlight = ceil((NdotL) * _LightWidth) / _LightStep;
                toonlight=NdotL>0? toonlight : _AmbientColor.rgb;
                color.rgb *= toonlight*LightColor;
                return color;
            } 
            
            ENDHLSL
        } 
    }
}