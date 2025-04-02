Shader "StencilRefApps/Transformation/SuzanneShape"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        [IntRange] _StencilRef("Stencil Ref", Range(0, 255)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Stencil 
        {
            Ref[_StencilRef]
            Comp Equal
            Pass Replace
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD1;
            };

            float4 _Color;

            v2f vert (appdata v)
            {
                float4 wPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1));
                v2f o;
                o.vertex = mul(UNITY_MATRIX_VP, wPos);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = _WorldSpaceCameraPos - wPos.xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                i.normal = normalize(i.normal);
                i.viewDir = normalize(i.viewDir);
                float VDotN = saturate(dot(i.normal, i.viewDir)) * 0.5 + 0.5;
                return _Color * VDotN;
            }
            ENDCG
        }

        Pass
        {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 sspos : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _Color;

            v2f vert(appdata v)
            {
                float4 wPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1));
                v2f o;
                o.vertex = mul(UNITY_MATRIX_VP, wPos);
                o.sspos = o.vertex;
                return o;
            }

            float mod(float x, float y)
            {
                return x - y * floor(x / y);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //假装是特效
                float2 uv = i.sspos.xy / i.sspos.w;
                uv *= float2(1, _ScreenParams.y / _ScreenParams.x);
                uv = floor(uv * 32);
                float3 baseColor = lerp(0.5, 0.75, mod((uv.x + uv.y), 2.0));
                return float4(baseColor, 1);
            }
            ENDCG
        }
    }
}
