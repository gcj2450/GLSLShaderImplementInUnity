//http://glslsandbox.com/e#38092.0
Shader "Unlit/RotFiveCircle"
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
            #define time _Time.y
            #define fract frac

            #ifdef GL_ES
            precision mediump float;
            #endif

            //#extension GL_OES_standard_derivatives : enable

            uniform vec2 _Resolution;

            const float PI = 3.14;

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
				vec2 position = (2.0*input.uv.xy - _Resolution.xy)/_Resolution.x;
                float intensity = 0.02/abs(length(position) - .32);
                vec3 color = vec3(intensity*.2, 0, intensity);
                
                for(float i = .0; i < 5.; i++) {
                    vec2 q = position.xy + 0.2*vec2(cos(i*2.*PI/5. +time), sin(i*2.*PI/5. + time));
                    float intensity = .001/abs(length(q) - (.1*abs(sin(time)) + .1));
                    color += vec3(0, intensity, intensity*0.5);
                }
                
                return vec4(vec3(color), 1.0);
			}
			ENDCG
		}
	}
}
