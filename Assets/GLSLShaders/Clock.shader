//http://glslsandbox.com/e#50073.5
Shader "Unlit/Clock"
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
            #define mod fmod

            #ifdef GL_ES
            precision mediump float;
            #endif

            vec4 cross4(vec4 a,vec4 b)
            {
                return vec4(cross(a.xyz,b.xyz)+a.w*b.xyz+b.w*a.xyz,a.w*b.w-dot(a,b));
            }
            vec3 Rotate(vec3 p,float ang,vec3 axis)
            {
                axis=normalize(axis);
                vec4 a=vec4(p,0.0);
                vec4 rot=vec4(sin(ang*0.5)*axis,cos(ang*.5));
                vec4 res=cross4(rot,a);
                rot.xyz=-rot.xyz;
                res=cross4(res,rot);
                return res.xyz;
            }
            float DeBar( vec3 p, vec2 h )
            {
              vec2 d = abs(vec2(length(p.xz),p.y)) - h;
              return min(max(d.x,d.y),0.0) + length(max(d,0.0));
            }

            float DeRBar( vec3 p, vec3 a, vec3 b, float r )
            {
                vec3 pa = p - a, ba = b - a;
                float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
                return length( pa - ba*h ) - r;
            }
            uniform vec2 _Resolution;
            #define r1 0.8
            #define r2 0.9
            #define R1 0.75
            #define R2 0.9
            #define rr 0.01
            #define RR 0.02
            #define pi 3.1415926535897932384626433832795
            #define pi30 0.10471975511965977461542144610932

            vec4  main(vec2 gl_FragCoord)
            {       
                vec2 pos=(2.0*gl_FragCoord.xy-_Resolution)/_Resolution.y;
                float tick=floor(atan2(pos.x,pos.y)/pi30+0.5);
                float ang=tick*pi30;
                float s=sin(ang),c=cos(ang);
                float2x2 m=float2x2(c,s,-s,c);
                vec2 p=mul(pos,m);  //
                float d,color;

                if(mod(tick,5.0)>0.5){
                    d=(p.y>r1&&p.y<r2)?abs(p.x):1.0;
            //      d=abs(p.x)+abs(p.y-r1);
            //      d=max(0.025-d,0.0);
            //      d=0.02-length(p-vec2(0.0,r1));
                    color=smoothstep(0.02,0.0,d);
                }
                else {
                    d=(p.y>R1&&p.y<R2)?abs(p.x):1.0;
                    color=smoothstep(RR,0.0,d);
                }
                float t=time+4.0*3600.0+24.0*60.0+17.0;//Beijing time. Don't know what in the time uniform structure.
                float h=t/3600.0;
                float minit=mod(floor(t/60.0),60.0);
                float sec=floor(mod(t,60.0));
                float angh=mod(h,24.0)*pi/6.0;
                float angm=minit*pi30;
                float angs=sec*pi30;
                c=cos(angh);s=sin(angh);
                m=float2x2(c,s,-s,c);
                p=mul(pos,m);
                float dh=(p.y>-0.1&&p.y<0.65)?abs(p.x):1.0;
                color+=smoothstep(0.02,0.0,dh);
                
                c=cos(angm);s=sin(angm);
                m=float2x2(c,s,-s,c);
                p=mul(pos,m);
                float dm=(p.y>-0.2&&p.y<0.70)?abs(p.x):1.0;
                color+=smoothstep(0.015,0.0,dm);
                c=cos(angs);s=sin(angs);
                m=float2x2(c,s,-s,c);
                p=mul(pos,m);
                float ds=(p.y>-0.3&&p.y<0.75)?abs(p.x):1.0;
                color+=smoothstep(0.01,0.0,ds);
                return vec4(vec3(color,color,color),1.0);
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
