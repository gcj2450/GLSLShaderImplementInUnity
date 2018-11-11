//http://glslsandbox.com/e#11820.0
Shader "Unlit/RotateLeaves"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
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

            uniform vec2 _Mouse;
            uniform vec2 _Resolution;

            vec4 main( vec2 gl_FragCoord) {

                vec2 q = gl_FragCoord.xy / _Resolution.xy;
                float x = -1.0 + 2.1*q.x;
                float y = -1.0 + 2.0*q.y;
                
                y *= _Resolution.y / _Resolution.x;
                
                float a = atan2(x,y);
                float r = sqrt(x*x + y*y);
                
                float s = 0.5 + 0.5*sin(4.0*a + time);
                
                float g = sin(1.57 + 4.0*a+time);
                
                float d = 0.15 + 0.3*sqrt(s) + 0.15*g*g;
                
                float h = (r/d)-.1;
                float f = 1.0 - smoothstep(0.95, 1.0, h);
                h *= 1.0-0.5*(1.0-h)*smoothstep(0.95+0.05*h,1.0,sin(4.0*a+time));
                vec3 bcol = vec3(0.9+0.1*q.y,1.0,0.9-0.1*q.y);
                
                bcol *= 1.0 - 0.5*r;
                
                h = 0.1 + h;
                vec3 col = lerp(bcol, 1.2*vec3(0.6*h,0.2+0.5*h,0.0), f);
                
                return vec4(col, 1.0);
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
			
			fixed4 frag (v2f i) : SV_Target
			{
				return main(i.uv);
			}
			ENDCG
		}
	}
}
