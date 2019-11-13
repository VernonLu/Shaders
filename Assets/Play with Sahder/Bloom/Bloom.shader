// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Bloom"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _Threshold("Threshold", float) = 0.6
        _Bloom("Bloom", 2D) = "white" {}
    }

    SubShader
    {
        ZTest Always
        ZWrite Off
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            sampler2D _MainTex;
            float _Threshold;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 tex = tex2D(_MainTex, i.uv);
                float lumiance = dot(fixed3(0.2125, 0.7154, 0.0721), tex.rgb);
                return tex * saturate(lumiance - _Threshold);
            }

            ENDCG
        }

        UsePass "Custom/Gaussian Blur/HORIZONTAL"
        UsePass "Custom/Gaussian Blur/VERTICAL"

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            sampler2D _MainTex;
            sampler2D _Bloom;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed4 bloom = tex2D(_Bloom, i.uv);
                return fixed4(tex.rgb + bloom.rgb, tex.a);
            }

            ENDCG
        }
    }

    Fallback Off
}