//http://glslsandbox.com/e#23102.0
Shader "Unlit/GrassRoad"
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

            #define PI 3.14159265359

            vec4 main( in vec2 gl_FragCoord ) {

                vec2 position = (( gl_FragCoord.xy / _Resolution.xy ) - vec2(0.5, 0.5)) * 2.0;

                float xSize = abs(position.x / position.y);
                float tanAngle = tan(lerp(PI/2.0, PI/4.0, abs(position.y)));
                
                float ground = step(0.0, -position.y);
                float road = step(xSize, 1.0) * ground;
                float side = step(0.8, xSize) * road;
                float center = step(xSize, 0.05);
                
                float brightness = step(0.5, road) * 0.5;
                
                float stripe = max(0.0, sign(fmod(tanAngle*1.0 + time*4.0, 2.0) - 1.0) * road);
                
                brightness += 0.5 * (stripe * (side + 1.0 * center));
                
                // sides = red
                float red = side;
                brightness -= red*0.25; // reduce overall brightness just to make the sides more pleasing
                
                // ground = green
                float green = (1.0 - road) * ground * 0.75 + (1.0 - ground) * 0.5;
                
                // sky = blue
                float blue = (1.0 - ground);
                brightness += blue * (1.0 - position.y) * 0.5;

                return vec4( brightness + red, brightness + green, brightness + blue, 1.0 );
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
