//http://glslsandbox.com/e#27205.1
Shader "Unlit/CloudySky"
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
            #define mix lerp

            #ifdef GL_ES
            precision mediump float;
            #endif

            uniform vec2 _Resolution;

            float2x2 m = float2x2( 0.90,  0.110, -0.70,  1.00 );

            float hash( float n )
            {
                return fract(sin(n)*758.5453);
            }

            float noise( in vec3 x )
            {
                vec3 p = floor(x);
                vec3 f = fract(x); 
                //f = f*f*(3.0-2.0*f);
                float n = p.x + p.y*57.0 + p.z*800.0;
                float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x), mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                        mix(mix( hash(n+800.0), hash(n+801.0),f.x), mix( hash(n+857.0), hash(n+858.0),f.x),f.y),f.z);
                return res;
            }

            float fbm( vec3 p )
            {
                float f = 0.0;
                f += 0.50000*noise( p ); p = p*2.02;
                f -= 0.25000*noise( p ); p = p*2.03;
                f += 0.12500*noise( p ); p = p*2.01;
                f += 0.06250*noise( p ); p = p*2.04;
                f -= 0.03125*noise( p );
                return f/0.984375;
            }

            float cloud(vec3 p)
            {
                p-=fbm(vec3(p.x,p.y,0.0)*0.5)*2.25;
                
                float a =0.0;
                a-=fbm(p*3.0)*2.2-1.1;
                if (a<0.0) a=0.0;
                a=a*a;
                return a;
            }

            vec3 f2(vec2 gl_FragCoord ,vec3 c)
            {
                c+=hash(gl_FragCoord.x+gl_FragCoord.y*9.9)*0.01;
                
                
                c*=0.7-length(gl_FragCoord.xy / _Resolution.xy -0.5)*0.7;
                float w=length(c);
                c=mix(c*vec3(1.0,1.0,1.6),vec3(w,w,w)*vec3(1.4,1.2,1.0),w*1.1-0.2);
                return c;
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
				vec2 position = ( input.uv.xy / _Resolution.xy ) ;
                position.y+=0.2;

                vec2 coord= vec2((position.x-0.5)/position.y,1.0/(position.y+0.2));
                
                
                
                //coord+=fbm(vec3(coord*18.0,time*0.001))*0.07;
                coord+=time*0.05;
                
                
                float q = cloud(vec3(coord*1.0,0.222));

                vec3 col =vec3(0.2,0.7,0.9) + vec3(q*vec3(0.2,0.4,0.1));
                return vec4( f2(input.uv,col), 1.0 );

			}
			ENDCG
		}
	}
}
