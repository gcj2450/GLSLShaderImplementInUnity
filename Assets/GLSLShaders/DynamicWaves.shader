//http://glslsandbox.com/e#19024.2
Shader "Unlit/DynamicWaves"
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


            bool SubCyclic(float a, float x, float y, float t){
                y = 36.0*y;
                x = 9.0*x;
                if(y<0.) return true;
                x = sin(x+t)*sin(x+t)*3.1416*a;
                bool ret = a*acos(1.-y/a) + sqrt(y*(2.*a-y)) < x;
                return ret;
            }
            bool SubHoriz(vec2 p){
                float a = 0.5;
                float horiz = sin(time*3. + p.x *10.)*.02
                    + sin(-time*5. + p.x *40.)*.005
                    + sin(-time*7. + p.x *140.)*.0008
                    + sin(time*11. + p.x *70.)*.002 + .3;
                p.y += horiz*0.4;
                return  SubCyclic(a, p.x, p.y, time) ||
                    SubCyclic(a, p.x, p.y, -pow(time+p.x, 0.9))
                ;
            }
            vec4 main( vec2 gl_FragCoord) {

                vec2 position = gl_FragCoord.xy / _Resolution;
                float ratio = _Resolution.x / _Resolution.y;
                position.x *= ratio;

                // Fond
                vec3 color = vec3(.5, .6, .8)*0.9;
                    
                // Atmosphère
                color += (1.-position.y)/4.;
                
                // Soleil :D
                float sunSize = 0.027;
                vec2 sunPosition = vec2(sin(time*.5), cos(time*.5));
                float sunDistance = distance(position, sunPosition);
                if (sunDistance < sunSize) {
                    color = vec3(1,1,1);
                }
                //color += max(1. - sunDistance*sunDistance, 0.)*0.3;
                
                
                // upper-most plane
                if(SubHoriz((position-0.5)))
                // lowest plane
                if(SubHoriz((position-0.5)+vec2(1., 0.27))) color = vec3(0.03, 0.23, 0.4);  else    
                // 2nd lowest
                if(SubHoriz((position-0.5)+vec2(2., 0.13))) color = vec3(0.13, 0.35, 0.49); else    
                // 3rd lowest
                if(SubHoriz((position-0.5)+vec2(3., 0.06))) color = vec3(0.27, 0.48, 0.63); else    
                    color = vec3(0.44, 0.62, 0.77);
                    
                color.x += max(1. - pow(sunDistance, 1.7)/3., 0.)*0.3;
                color.y += max(1. - pow(sunDistance, 2.0)/3., 0.)*0.2;
                //color.z += max(1. - sunDistance*sunDistance, 0.)*0.0;

                return vec4( color, 1.0 );

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
