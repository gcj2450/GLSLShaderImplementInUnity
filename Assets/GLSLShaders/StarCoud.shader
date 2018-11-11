//http://glslsandbox.com/e#48267.0
// ShaderToy version here:
// https://www.shadertoy.com/view/lscczl
Shader "Unlit/StarCoud"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (0,1,0,1)
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
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

            #define vec2 float2
            #define vec3 float3
            #define vec4 float4
            #define time _Time.g
            #define fract frac



            #ifdef GL_ES
            precision mediump float;
            #endif

            uniform vec4 _Resolution;

            #define S(a, b, t) smoothstep(a, b, t)

            float N21(vec2 p) {
                return fract(sin(p.x*123.+p.y*3456.)*3524.);
            }

            vec2 N22(vec2 p) {
                return vec2(N21(p), N21(p+324.));
            }

            float L(vec2 p, vec2 a, vec2 b) 
            {
                vec2 pa = p-a;
                vec2 ba = b-a;
                
                float t = clamp(dot(pa, ba)/dot(ba, ba), 0., 1.);
                
                float d = length(pa - ba*t);
                
                float m = S(.02, .0, d);
                d = length(a-b);
                float f = S(1., .8, d);
                m *= f;
                m += m*S(.05, .06, abs(d - .75))*.01;
                return m;
            }

            vec2 GetPos(vec2 p, vec2 o) {
                p += o;
                vec2 n = N22(p)*time;
                p = sin(n)*.4;
                return o+p;
            }

            float G(vec2 uv) {
                vec2 id = floor(uv);
                uv = fract(uv)-.5;
                
                vec2 g = GetPos(id, vec2(0,0));
                
                float m = 0.;
                for(float y=-1.; y<=1.; y++) {
                    for(float x=-1.; x<=1.; x++) {
                        vec2 offs = vec2(x, y);
                        vec2 p = GetPos(id, offs);
                        
                        m+=L(uv, g, p);
                        
                        vec2 a = p-uv;
                        float flash = .002/dot(a, a);
                        
                        flash *= pow( sin(N21(id+offs)*1.414213562+100.*time)*.4+.6, 1.);
                        //flash *= pow( sin(time)*.5+.5, 3.);
                        m += flash;
                    }
                
                }
                
                m += L(uv, GetPos(id, vec2(-1, 0)), GetPos(id, vec2(0, -1)));
                m += L(uv, GetPos(id, vec2(0, -1)), GetPos(id, vec2(1, 0)));
                m += L(uv, GetPos(id, vec2(1, 0)), GetPos(id, vec2(0, 1)));
                m += L(uv, GetPos(id, vec2(0, 1)), GetPos(id, vec2(-1, 0)));
                
                float d = length(g-uv);
                //m = S(.1, .08, d);
                return m;
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

                vec2 uv = ( i.uv.xy-.5*_Resolution.xy) / _Resolution.y;

                float d = step(uv.y, 0.);
                
                //if(uv.y<0.)
                //  uv.y = abs(uv.y);
                
                float m = 0.;
                
                m = 0.;
                float t = time*.2;
                for(float i=0.; i<1.; i+=.2) 
                {
                    float z = fract(i+t);
                    float s = lerp(10., .5, z);
                    float f = S(0., .4, z)*S(1., .8, z);
                    
                    m += G(uv*s+1000.*i)*f;
                }
                
                t *= 10.;
                vec3 base = .5+sin(vec3(1., .56, .76)*t)*.1;
                vec3 col = base;
                col *= m;
                
                col -= uv.y*base;
                col *= 1.-dot(uv, uv);
                
                //col *= mix(1., .5, d);
                return vec4( col, 1.0 );

			}
			ENDCG
		}
	}
}
