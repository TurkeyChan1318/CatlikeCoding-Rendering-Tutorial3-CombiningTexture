// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Texture Splatting"
{
    Properties//属性面板，用来说明参数属性
    {
        _MainTex ("Splat Map", 2D) = "white"{}
        [NoScaleOffset] _Texture1 ("Texture 1", 2D) = "white" {}
        [NoScaleOffset] _Texture2 ("Texture 2", 2D) = "white" {}
        [NoScaleOffset] _Texture3 ("Texture 3", 2D) = "white" {}
		[NoScaleOffset] _Texture4 ("Texture 4", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram

            #include "UnityCG.cginc"

            //在属性说明的参数需要在Pass中声明才能使用
            sampler2D _MainTex; float4 _MainTex_ST;
            sampler2D _Texture1, _Texture2, _Texture3, _Texture4;

            //顶点数据结构
            struct VertexData {
                float4 position : POSITION;//POSITION表示对象本地坐标
                float2 uv : TEXCOORD0;//纹理坐标
            };

            //插值后数据结构
            struct Interpolators {
				float4 position : SV_POSITION;//SV_POSITION指系统的坐标，反正就是要加个语义进去才能使用
				float2 uv : TEXCOORD0;//纹理坐标
                float2 uvSplat : TEXCOORD1;
			};

            //顶点数据通过顶点程序后进行插值，插值后数据传递给片元程序
            Interpolators MyVertexProgram (VertexData v) {
				Interpolators i;
				i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                i.uvSplat = v.uv;
				i.position = UnityObjectToClipPos(v.position);
				return i;
			}

            //片元程序
			float4 MyFragmentProgram (Interpolators i) : SV_TARGET {
                float4 splat = tex2D(_MainTex, i.uvSplat);
                float4 color = tex2D(_Texture1, i.uv) * splat.r +
                               tex2D(_Texture2, i.uv) * splat.g +
                               tex2D(_Texture3, i.uv) * splat.b +
                               tex2D(_Texture4, i.uv) * (1.0 - splat.r - splat.g - splat.b);
				return color;
			}

            ENDCG
        }
    }
}