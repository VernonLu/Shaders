// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Vernon/Dissolve" {
	Properties{
		_MainTex("Main tex",2D) = ""{}

		//溶解纹理,根据这张图的R通道来做溶解判断
		_DissolveTex("Dissolve tex",2D) = ""{}

		//溶解时间
		_Duration("Duration", float) = 1

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
			float _DissolveFactor1;

			float4 _EdgeColor;
			float _DissolveFactor2;

			float _Duration;

			v2f vert(appdata_custom v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			half4 frag(v2f IN) :COLOR {

				half4 c = tex2D(_MainTex,IN.uv);

				float dissolve_c_r = tex2D(_DissolveTex,IN.uv).r;

				int tmp = _Time.y / _Duration;
				float time = _Time.y - (tmp * _Duration);

				float factor = saturate(time / _Duration);

				if (factor > dissolve_c_r) {
					discard;
				}

				float rate = factor / dissolve_c_r;

				if (rate > _DissolveFactor1) {
					//向溶解色过渡
					c.rgb = lerp(c.rgb, _DissolveColor.rgb, rate);
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