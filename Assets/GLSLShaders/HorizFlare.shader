//http://glslsandbox.com/e#15706.0
Shader "Unlit/HorizFlare"
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

            //MrOMGWTF

            vec3 flare(vec2 spos, vec2 fpos, vec3 clr)
            {
                vec3 color;
                float d = distance(spos, fpos);
                vec2 dd;
                dd.x = spos.x - fpos.x;
                dd.y = spos.y - fpos.y;
                dd = abs(dd);
                
                color = clr * max(0.0, 0.025 / dd.y) * max(0.0, 1.1 -  dd.x);
                color += clr * max(0.0, 0.05 / d);
                color += clr * max(0.0, 0.1 / distance(spos, -fpos)) * 0.15 ;
                color += clr * max(0.0, 0.13 - distance(spos, -fpos * 1.5)) * 1.5 ;
                color += clr * max(0.0, 0.07 - distance(spos, -fpos * 0.4)) * 2.0 ;
                
                
                return color;
            }

            float noise(vec2 pos)
            {
                return fract(1111. * sin(111. * dot(pos, vec2(2222., 22.))));   
            }

            vec4 main( vec2  gl_FragCoord) {

                vec2 position = ( gl_FragCoord.xy / _Resolution.xy * 2.0 ) - 1.0;
                position.x *= _Resolution.x / _Resolution.y;
                float omega = time*2.-(sin(time)/1.5);
                float divisor = 1.-.5*cos(omega);
                vec3 color = flare(position, vec2(sin(omega)/2./divisor, cos(omega)/2./divisor) * 0.5 , vec3(0.5, 0.8, 1.5));

                return vec4( color * (0.95 + noise(position*0.001 + 0.00001) * 0.05), 1.0 );
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
