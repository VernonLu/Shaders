Shader "Vernon/BaseTexture" {
	Properties {
		_Color ("Main Tint", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_SecTex("Second Texture", 2D) = "white" {}
		_Mask("Mask Texture", 2D) = "white" {}
		_Lerp("Lerp", Range(-1,1)) = 0 
	}
	SubShader {
		Pass{

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag 
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _SecTex;
			float4 _SecTex_ST;
			float _Lerp;
			sampler2D _Mask;
			float4 _Mask_ST;


			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);		//转换为裁剪空间坐标
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);	//uv对应
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 diffuse;
				if(_Lerp <= 0)
				{
					diffuse = lerp(tex2D(_MainTex,i.uv).rgb, tex2D(_SecTex,i.uv).rgb, (1-abs(_Lerp))*tex2D(_Mask,i.uv).rgb);
				}
				else
				{
					diffuse = lerp(tex2D(_SecTex,i.uv).rgb, tex2D(_MainTex,i.uv).rgb,(_Lerp-1)*tex2D(_Mask,i.uv).rgb);
				}
				return fixed4(diffuse,1.0);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}