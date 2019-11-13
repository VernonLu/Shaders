// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

/**
公式：
	漫反射光照 = （光照颜色与强度 * 漫反射颜色）* （dot(法线方向 ，光照方向) * 0.5 + 0.5）；
作用：
	解决背光面阴暗无细节的问题，只是视觉增强，无物理学依据。
*/

Shader "Vernon/Half-Lambert" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader{
		Pass{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragam vertex vert
			#pragam fragemnt frag
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float3 worldNormal : TEXCOORD0;12
			};
			v2f vert(a2v v) {4
				v2f o;
				o.pos = mul(UNITY_MARTIX_MVP, v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				return 0;
			}
			fixed4 frag(v2f i) : SV_Target{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				fixed3 color = ambient + diffuse;

				return fixed4(color,1.0);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
