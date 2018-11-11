//http://glslsandbox.com/e#44809.0
//去掉雪花点的代码
Shader "Unlit/RGBCircle"
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

            #ifdef GL_ES
            precision mediump float;
            #endif

            uniform vec2 _Resolution;

            #define PI 3.14159265359
            #define T (time / .99)

            vec3 hsv2rgb(vec3 c)
            {
                vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 4.0);
                vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
            }

            const float aoinParam1 = 0.7;

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
				vec2 position = (( input.uv.xy / _Resolution.xy ) - 0.5);
                position.x *= _Resolution.x / _Resolution.y;
                
                vec3 color = vec3(0,0,0);
                
                for (float i = 0.; i < PI*2.0; i += PI/20.0) {
                    vec2 p = position - vec2(cos(i), sin(i)) * 0.15;
                    vec3 col = hsv2rgb(vec3((i + T)/(PI*2.0), 1., 1));
                    color += col * (2.4/512.) / length(p);
                }                 

                position.x *= _Resolution.x / _Resolution.y;
                
                vec2 uv=(input.uv.xy * 2.-_Resolution.xy)/min(_Resolution.x,_Resolution.y); 
                vec3 finalColor=vec3(0,0,0);
                float c=smoothstep(1.,0.3,clamp(uv.y*.3+.9,1.,.85));
               
                finalColor=(vec3(c,c,c));   
                return (vec4( color, 1.0 ) + vec4(finalColor,1)) / vec4(2, 2, 2, 1);
			}
			ENDCG
		}
	}
}
