//---------------------------------------------------------
//http://glslsandbox.com/e#30314.0
// Shader:   StormyFlight2.glsl by S.Guillitte in 2015-02-24
//           Improved version of the lightning bolt effect.
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// original: https://www.shadertoy.com/view/XlsGWS
// Tags:     2d, noise, lightning, thunder
//---------------------------------------------------------
Shader "Unlit/ThunderLight"
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

            //#extension GL_OES_standard_derivatives : enable

            uniform vec2 _Resolution;

            float hash(float x)
            {
              return fract(21654.6512 * sin(385.51 * x));
            }
            float hash(in vec2 p)
            {
              return fract(sin(p.x*15.32+p.y*35.78) * 43758.23);
            }

            vec2 hash2(vec2 p)
            {
              return vec2(hash(p*.754),hash(1.5743*p.yx+4.5891))-.5;
            }

            vec2 hash2b(vec2 p)
            {
              return vec2(hash(p*.754),hash(1.5743*p+4.5476351));
            }

            vec2 add = vec2(1.0, 0.0);

            vec2 noise2(vec2 x)
            {
              vec2 p = floor(x);
              vec2 f = fract(x);
              f = f*f*(3.0-2.0*f);
              vec2 res = mix(mix( hash2(p),          hash2(p + add.xy),f.x),
                             mix( hash2(p + add.yx), hash2(p + add.xx),f.x),f.y);
              return res;
            }

            vec2 fbm2(vec2 x)
            {
              vec2 r = vec2(0,0);
              float a = 1.0;
                
              for (int i = 0; i < 8; i++)
              {
                r += abs(noise2(x)+.5 )* a;
                x *= 2.;
                a *= .5;
              }
              return r;
            }

            float2x2 m2 = float2x2( 0.80, -0.60, 0.60, 0.80 );

            vec2 fbm3(vec2 x)
            {
              vec2 r = vec2(0,0);
              float a = 1.0;
              for (int i = 0; i < 6; i++)
              {
                r +=mul (m2,noise2((x+r)/a)*a); 
                r =- .8*abs(r);
                a *= 1.7;
              }     
              return r;
            }

            float dseg(vec2 ba, vec2 pa)
            {
              float h = clamp( dot(pa,ba)/dot(ba,ba), -0.2, 1. );   
              return length( pa - ba*h );
            }

            float arc(vec2 x, vec2 p, vec2 dir)
            {
              vec2 r = p;
              float d = 10.;
              for (int i = 0; i < 5; i++)
              {
                vec2 s = noise2(r+time)+dir;
                d = min(d,dseg(s,x-r));
                r += s;      
              }
              return d*3.0; 
            }

            float thunderbolt(vec2 x, vec2 tgt)
            {
              vec2 r = tgt;
              float d = 1000.;
              float dist = length(tgt-x);
                 
              for (int i = 0; i < 19; i++)
              {
                if(r.y > x.y+.5)break;
                vec2 s = (noise2(r+time)+vec2(0.,.7))*2.;
                dist = dseg(s,x-r);
                d = min(d,dist);
                r += s;
                if(i-(i/5)*5==0)
                {
                  if(i-(i/10)*10==0)
                       d = min(d,arc(x,r,vec2( .3,.5)));
                  else d = min(d,arc(x,r,vec2(-.3,.5)));
                }
              }
              return exp(-5.*d)+.2*exp(-1.*dist);
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
                vec2 p = 2.0*input.uv.xy / _Resolution.xy - 1.0;
                vec2 tgt = vec2(1., -8.);
                float c = 0.;
                vec3 col = vec3(0,0,0);

                float t = hash(floor(5.*time));
                tgt += 8.*hash2b(tgt+t);
                //if(hash(t+2.3) > 0.8)
                {
                    c = thunderbolt(p*10.+2.*fbm2(5.*p),tgt);   
                    col += clamp(1.7*vec3(0.8,.7,.9)*c,0.,1.);  
                }
                return vec4(col, 1.0);
			}
			ENDCG
		}
	}
}
