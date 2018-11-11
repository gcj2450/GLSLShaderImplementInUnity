//http://glslsandbox.com/e#33183.0
Shader "Unlit/DotProgresser"
{
	Properties
	{
        _Resolution ("Resolution", Vector) = (1,1,0,1)
		_Offset ("Offset", Vector) = (1,1,0,1)
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

            #ifdef GL_ES
            precision lowp float;
            #endif

            //#extension GL_OES_standard_derivatives : enable

            uniform vec2 _Resolution;
            uniform vec2 _Offset;

            bool mustShow(float x){
                return cos(6.0 * time + x / 25.0) > -0.7;   
            }

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
				o.uv =v.uv;
				return o;
			}
			
			fixed4 frag (v2f input) : SV_Target
			{
				vec2 p =_Offset+ (input.uv.xy * 2.0 - _Resolution.xy) / _Resolution.y;

                vec3 destColor = vec3(0,0,0);
                for(float i = 0.0; i < 12.0; i++){
                    if(mustShow(i))destColor += 0.01 / length(vec2(p.x + (i - 12.0) * 0.1, p.y));
                }
                return vec4(destColor, 1.0);
			}
			ENDCG
		}
	}
}
