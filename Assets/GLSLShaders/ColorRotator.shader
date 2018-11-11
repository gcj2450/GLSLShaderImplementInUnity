//http://glslsandbox.com/e#27823.1
Shader "Unlit/ColorRotator"
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

            vec3 color( const float a ) 
            {
                float r = -1. + min( fmod( a     , 6. ), 6. - fmod( a     , 6. ) );
                float g = -1. + min( fmod( a + 2., 6. ), 6. - fmod( a + 2., 6. ) );
                float b = -1. + min( fmod( a + 4., 6. ), 6. - fmod( a + 4., 6. ) );
                
                r = clamp( r, 0., 1. );
                g = clamp( g, 0., 1. );
                b = clamp( b, 0., 1. );
                
                return vec3( r,g,b );
            }

            vec2 toPolar( vec2 uv )
            {
                float a = atan2( uv.y, uv.x );
                float l = length( uv );
                
                uv.x = a / 3.1415926;
                uv.y = l;
                
                return uv;
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
			
			fixed4 frag (v2f input) : SV_Target
			{
				vec2 p = ( input.uv.xy / _Resolution.xy ) * 2. - 1.;
                p.x *= _Resolution.x/_Resolution.y;
                float f = length(p);
                
                p = toPolar(p);
                p.x += sin(time - f) * clamp( -cos(time*.1) * 4. + 3., 0., 1.);
                vec4 gl_FragColor = vec4( color(p.x*3.), 1.) * (smoothstep( .01,.0,f -1.));
                return lerp( gl_FragColor, vec4(1,1,1,1), 1.-f);
			}
			ENDCG
		}
	}
}
