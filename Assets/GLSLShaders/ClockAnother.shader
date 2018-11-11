//http://glslsandbox.com/e#7738.0
Shader "Unlit/ClockAnother"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Scale("Scale",float)=1
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
            #define mix lerp
            #define mod fmod

            #ifdef GL_ES
            precision mediump float;
            #endif

            uniform vec2 _Resolution;
            float _Scale;

            // Created by inigo quilez - iq/2013
            // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

            // Switched to screen space distance by Trisomie21

            float distanceToSegment( vec2 a, vec2 b, vec2 p, float t )
            {
                vec2 pa = p - a;
                vec2 ba = b - a;
                float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
                float d = length( pa - ba*h );
                
                // Screen space distance
                return clamp((t-.5*d)*_Resolution.y, 0., 1.);
            }

            vec4  main(vec2 gl_FragCoord)
            {
                // get time
                float secs = mod( floor(time),        70.0 );
                float mins = mod( floor(time/60.0),   60.0 )+5.;
                float hors = mod( floor(time/3600.0), 24.0 );
                
                vec2 uv = -1.0 + _Scale*gl_FragCoord.xy / _Resolution.xy;
                uv.x *= _Resolution.x/_Resolution.y;
                
                float r = length( uv );
                float a = atan2( uv.y, uv.x )+3.1415926;
                
                // background color
                vec3 nightColor = vec3( 0.2, 0.2, 0.2 ) + 0.1*uv.y;
                vec3 dayColor   = vec3( 0.5, 0.6, 0.7 ) + 0.2*uv.y;
                vec3 col = mix( nightColor, dayColor, smoothstep( 5.0, 7.0, hors ) - 
                                                      smoothstep(19.0,21.0, hors ) );
                // inner watch body 
                col = mix( col, vec3(0.9-0.4*pow(r,4.0),0.9-0.4*pow(r,4.0),0.9-0.4*pow(r,4.0)), 1.0-smoothstep(0.94,0.95,r) );

                // hours & minute marks 
                float u, h, m;
                u = r * 6.2831 / 12.;
                h = fract(a*r/u +.5)-.5;
                h = .004-.5*abs(h*u);
                h *= (1.-step(r, .84))*step(r, .95);
                
                u = r * 6.2831 / 60.;
                m = fract(a*r/u +.5)-.5;
                m = .0025-.5*abs(m*u);
                m *= (1.-step(r, .89))*step(r, .95);
                col = mix( col, vec3(0,0,0), max(m*_Resolution.y, 0.)+max(h*_Resolution.y, 0.) );
                
                // seconds hand
                vec2 dir;
                dir = vec2( sin(6.2831*secs/60.0), cos(6.2831*secs/60.0) );
                float f = distanceToSegment( vec2(0,0), dir*0.9, uv, .005);
                col = mix( col, vec3(1,0.0,0.0), f );

                // minutes hand
                dir = vec2( sin(6.2831*mins/60.0), cos(6.2831*mins/60.0) );
                f = distanceToSegment( vec2(0,0), dir*0.7, uv, .01 );
                col = mix( col, vec3(0,0,0), f );

                // hours hand
                dir = vec2( sin(6.2831*hors/12.0), cos(6.2831*hors/12.0) );
                f = distanceToSegment( vec2(0,0), dir*0.4, uv, .015 );
                col = mix( col, vec3(0,0,0), f );

                // center mini circle   
                col = mix( col, vec3(0.5,0.5,0.5), clamp((.055-r)*_Resolution.y, 0., 1.) );
                col = mix( col, vec3(0,0,0), clamp((.004-.5*abs(.055-r))*_Resolution.y, 0., 1.) );

                // border of watch
                col = mix( col, vec3(0,0,0), clamp((.01-.5*abs(r-.95))*_Resolution.y, 0., 1.) );

                return vec4( col,1.0 );
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
				o.uv = v.uv;
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
