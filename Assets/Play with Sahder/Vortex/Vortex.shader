// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Vernon/Vortex" {
	Properties {
		_MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		_Duration("Duration", float) = 1
		_Factor("Facotr", float) = 8
		_Transparency("Transparency", range(0,1)) = 1
	}

		SubShader {
			Tags {
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
				"RenderType" = "Transparent"
				"PreviewType" = "Plane"
			}

			Cull Off
			Lighting Off
			ZWrite Off
			Blend One OneMinusSrcAlpha


			Pass {
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile _ PIXELSNAP_ON
				#include "UnityCG.cginc"

				struct appdata_t {
					float4 vertex   : POSITION;
					float4 color    : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f {
					float4 vertex   : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord  : TEXCOORD0;
				};

				sampler2D _MainTex;

				fixed4 _Color;

				float _Duration;

				float _Factor;

				float _Transparency;

				float2 swirl(float2 uv) {
					//先减去贴图中心点的纹理坐标，方便旋转计算 
					uv -= float2(0.5, 0.5);

					//计算旋转范围
					int tmp = _Time.y / _Duration;
					float time = _Time.y - (tmp * _Duration);
					float factor = time / _Duration;

					//计算当前坐标与中心点的距离 
					float dist = length(uv);

					//计算当前顶点是否在旋转范围内
					float percent = (factor - dist) / (factor);

					if (percent < 1.0 && percent >= 0.0) {
						//计算旋转角度
						float angle = percent * percent * time * _Factor;

						float y = sin(angle);
						float x = cos(angle);

						//计算旋转后的位置
						uv = float2(uv.x * x - uv.y * y, uv.x * y + uv.y * x);
					}

					//加上贴图中心点的纹理坐标。
					uv += float2(0.5, 0.5);

					return uv;
				}


				fixed4 SampleSpriteTexture(float2 uv) {
					fixed4 color = tex2D(_MainTex, uv);
					return color;
				}

				v2f vert(appdata_t v) {
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.texcoord = v.texcoord;
					o.color = v.color * _Color;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target {

					i.texcoord = swirl(i.texcoord);

					fixed4 c = tex2D(_MainTex, i.texcoord) * i.color;

					c.a = _Transparency;
					
					c.rgb *= c.a;

					return c;
				}
			ENDCG
		}
	}
}