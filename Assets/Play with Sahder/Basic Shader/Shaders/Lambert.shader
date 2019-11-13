// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


/******************************************
*Lambert(兰伯特)光照模型
*1. 理想的漫反射；
*2. 计算都在顶点着色器，因此像素不会平滑过渡；
*******************************************/
Shader "Vernon/Lambert"
{
	Properties
	{
		_Color("Color", color) = (1.0,1.0,1.0,1.0)
	}
		SubShader{
		Pass{

		Tags{ "LightMode" = "ForwardBase" }

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

		//使用自定义变量
		uniform float4 _Color;

	//使用Unity定义的变量
	uniform float4 _LightColor0;

	struct vertexInput {
		float4 vertex:POSITION;
		float3 normal:NORMAL;
	};

	struct vertexOutput {
		float4 pos:SV_POSITION;
		float4 col:COLOR;
	};

	//顶点程序
	vertexOutput vert(vertexInput v)
	{
		vertexOutput o;

		float3 normalDirection = normalize(mul(float4(v.normal,0.0),unity_WorldToObject).xyz);//将模型空间的法线转到世界空间
		float3 lightDirection;
		float atten = 1.0;

		lightDirection = normalize(_WorldSpaceLightPos0.xyz);//灯光方向
		float3 diffuseReflection = atten * _LightColor0.xyz *  max(0.0, dot(normalDirection,lightDirection));//计算兰伯特漫反射
		float3 lightFinal = diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;//与环境光结合

		o.col = float4(lightFinal*_Color.rgb,1.0);
		o.pos = UnityObjectToClipPos(v.vertex);
		return o;
	}

	//片段程序
	float4 frag(vertexOutput i) :COLOR
	{
		return i.col;
	}

		ENDCG
	}
	}

}