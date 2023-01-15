Shader "toonvariant" 
{
    Properties {
        _Ambientcolor("Ambient color",color)=(0,0,0,0)
        _LightWidth("Light Width",Range(0,255))=1
        [IntRange] _LightStep("Light Step", Range(2,10)) = 2
        
        _StepOffset("Step Offset", Range(-1,1)) = 0
        _StepWidth("Step Width", Range(0,1)) = 0.5
    }


    SubShader 
    {
        Tags 
        {
            "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry"
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
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION; 
                float3 normal : NORMAL;
            };
            
            float4 _Ambientcolor;
            float _LightWidth;
            float _LightStep;
            float _StepOffset;
            float _StepWidth;

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz); 
                o.normal = TransformObjectToWorldNormal(v.normal);
                return o; 
            }


            half4 frag(VertexOutput i) : SV_Target 
            {
                Light mainLight = GetMainLight();
                half NdotL = dot(i.normal, mainLight.direction);

                // https://learn.microsoft.com/en-us/windows/win32/direct3d9/casting-and-conversion
                NdotL = saturate(NdotL * (1 - _StepWidth) + _StepOffset);
                NdotL = int(NdotL * _LightStep) / _LightStep;
                
                half4 color =  half4(NdotL * _MainLightColor.rgb, 1) + (1 - NdotL) * _Ambientcolor;

                return color;
            } 

            ENDHLSL
        } 
    }
}