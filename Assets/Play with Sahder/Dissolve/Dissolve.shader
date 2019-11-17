// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Vernon/Dissolve" {
	Properties{
		_MainTex("Main tex",2D) = ""{}

		//溶解纹理,根据这张图的R值（也可以是其它通道的值）来做溶解判断，简单的说就是利用这张图的特征来作为溶解的样式
		_DissolveTex("Dissolve tex",2D) = ""{}

		//溶解速度
		_DissolveSpeed("Dissolve speed",Range(0,5)) = 2

		//溶解颜色
		_DissolveColor("Dissolve color",Color) = (0,0,0,1)

		//溶解因子1,大于这个因子就向溶解色过渡
		_DissolveFactor1("Dissolve factor1",range(0,1)) = 0.7

		//边缘颜色
		_EdgeColor("Edge color",Color) = (0,0,0,1)

		//溶解因子2,大于这个因子就向边缘色过渡
		_DissolveFactor2("Dissolve factor2",range(0,1)) = 0.9

	}

	SubShader {

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			struct appdata_custom {
				float4 vertex:POSITION;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f {
				float4 pos:POSITION;
				float2 uv:TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DissolveTex;
			float4 _DissolveColor;
			float4 _EdgeColor;
			float _DissolveSpeed;
			float _DissolveFactor1;
			float _DissolveFactor2;
			float _DissolvePercentage;

			v2f vert(appdata_custom v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			half4 frag(v2f IN) :COLOR {

				half4 c = tex2D(_MainTex,IN.uv);

				float dissolve_c_r = tex2D(_DissolveTex,IN.uv).r;

				float factor = saturate(_Time.y * _DissolveSpeed / 5);

				if (factor > dissolve_c_r) {
					discard;
					//clip(-1.0);
				}

				float rate = factor / dissolve_c_r;
				if (rate > _DissolveFactor1) {
					//向溶解色过渡
					c.rgb = lerp(c.rgb,_DissolveColor.rgb,rate);
					if (rate > _DissolveFactor2) {
						//向边缘色过渡
						c.rgb = lerp(c.rgb, _EdgeColor.rgb,rate);
					}
				}
				return c;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}