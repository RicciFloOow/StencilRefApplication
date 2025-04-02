Shader "StencilRefApps/Transformation/Mask"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShapeFactor ("Shape Factor", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "Queue"="Geometry-1" }
        ZTest LEqual ZWrite Off
        ColorMask 0

        Stencil 
        {
            Ref 0 //这里的值无所谓
            Comp Always
            Pass Replace
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma use_dxc//SV_StencilRef是dx11.3才出的, unity的dx11版本好像是不支持dx11.3的(只支持到shader model 5.0)得用dx12

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _ShapeFactor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            uint frag (v2f i) : SV_StencilRef
            {
                float s = tex2D(_MainTex, i.uv).x;
                return s <= _ShapeFactor ? 1u : 2u;
            }
            ENDCG
        }
    }
}
