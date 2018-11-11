//http://glslsandbox.com/e#16736.0
Shader "Unlit/CheckBoard"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
            #define vec2 float2
            #define vec3 float3
            #define vec4 float4
            #define time _Time.g
            #define fract frac

            uniform float4 _Resolution;

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
   
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f input) : SV_Target
			{
				vec2 pos = (input.uv.xy*2.0 -_Resolution)/_Resolution.y;

                if((sin(pos.x * 10.) * cos(pos.y * 10.0)) < 0 )
                {
                    return vec4(1,1,1,1);
                }
                else
                {
                    return vec4(0,0,0,0);
                }
			}
			ENDCG
		}
	}
}
