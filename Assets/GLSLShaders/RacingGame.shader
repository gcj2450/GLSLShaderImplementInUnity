﻿//---------------------------------------------------------
//http://glslsandbox.com/e#23585.1
// Shader:   RacingGame.glsl    by eiffie 12/2013
// original: https://www.shadertoy.com/view/Xd23DD
// tags:     racing, 3d, raymarching, lightning, cars
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//---------------------------------------------------------
Shader "Unlit/RacingGame"
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
            //uniform sampler2D texture;

            //---------------------------------------------------------
            float spec, specExp=8.0, pixelSize;
            const vec3 sunColor=vec3(1.0,0.7,0.3);
            vec3 L;

            float smin(float a,float b,float k)
            { return -log(exp(-k*a)+exp(-k*b))/k; } //from iq

            vec3 cp1,cp2,cp3;
            float2x2 cm1,cm2,cm3;

            void PositionCars(float t)
            {
                float f=fmod(t,3.1416);
                if(fmod(t/6.283,2.0)>1.0)f=0.0;
                f=smoothstep(0.0,0.6,abs(f-1.4))*0.16;
                float x=cos(t)*10.0+cos(t*8.0)*0.6;
                float y=sin(t)*10.0+sin(t*3.0)*0.6;
                cp1=vec3(x,0.0,y);
                t+=0.01;
                x-=cos(t)*10.0+cos(t*8.0)*0.6;
                y-=sin(t)*10.0+sin(t*3.0)*0.6;
                float a=atan2(x,y);
                cm1=float2x2(cos(a),sin(a),-sin(a),cos(a));
                t+=0.09;
                x=cos(t)*10.0+cos(t*8.0)*0.725;
                y=sin(t)*10.0+sin(t*3.0)*0.725;
                cp2=vec3(x,0.0,y);
                t+=0.01;
                x-=cos(t)*10.0+cos(t*8.0)*0.725;
                y-=sin(t)*10.0+sin(t*3.0)*0.725;
                a=atan2(x,y);
                cm2=float2x2(cos(a),sin(a),-sin(a),cos(a));
                t+=f-0.04;
                x=cos(t)*10.0+cos(t*8.0)*0.45;
                y=sin(t)*10.0+sin(t*3.0)*0.45;
                cp3=vec3(x,0.0,y);
                t+=0.01;
                x-=cos(t)*10.0+cos(t*8.0)*0.45;
                y-=sin(t)*10.0+sin(t*3.0)*0.45;
                a=atan2(x,y);
                cm3=float2x2(cos(a),sin(a),-sin(a),cos(a));
            }
            vec3 rc=vec3(0.7,0.26,1.5);
            float DE(in vec3 z0)
            {
                float a=atan2(z0.z,z0.x);
                float g=(sin(z0.x+sin(z0.z*1.7))+sin(z0.z+sin(z0.x*1.3)))*0.2;
                float d=abs(length(z0.xz-vec2(cos(a*8.0),sin(a*3.0))*0.75)-10.0)-0.4;
                float dg=z0.y+g*smoothstep(0.0,0.5,d);
                vec3 c,p=z0,prp=vec3(0,0,0);
                float d0=100.0;
                
                c=(z0-cp1)*10.0;
                c.xz=mul(cm1,c.xz);
                float dt=length(max(vec3(0,0,0),abs(c)-rc))-0.1;
                if(dt<d0){d0=dt;p=c;prp=vec3(1.21,0.4,1.97);}
                c=(z0-cp2)*10.0;
                c.xz=mul(cm2,c.xz);
                dt=length(max(vec3(0,0,0),abs(c)-rc))-0.1;
                if(dt<d0){d0=dt;p=c;prp=vec3(1.12,0.35,1.92);}
                c=(z0-cp3)*10.0;
                c.xz=mul(cm3,c.xz);
                dt=length(max(vec3(0,0,0),abs(c)-rc))-0.1;
                if(dt<d0){d0=dt;p=c;prp=vec3(0.61,0.26,1.48);}

                if(d0<dg*10.0)
                {   
                    float r=length(p.yz+vec2(prp.x,0.0));
                    d0=length(max(vec3(abs(p.x)-prp.y,r-prp.z,-p.y+0.16),0.0))-0.05;
                    d0=max(d0,p.z-1.0);
                    p+=vec3(0.0,-0.25,0.39);
                    p.xz=abs(p.xz);
                    p.xz-=vec2(0.5300,0.9600);
                    p.x=abs(p.x);
                    r=length(p.yz);
                    d0=smin(d0,length(max(vec3(p.x-0.08,r-0.25,-p.y-0.08),0.0))-0.04,8.0);
                    d0=max(d0,-max(p.x-0.165,r-0.24));
                    float d2=length(vec2(max(p.x-0.13,0.0),r-0.2))-0.02;
                    float d3=min(max(p.x-0.05,r-0.18),length(vec2(max(p.x-0.11,0.0),r-0.18))-0.02);//length(vec2(max(p.x-0.11,0.0),r-0.18))-0.02;
                    d0=min(d0,min(d2,d3));
                }
                return min(dg,d0*0.1);
            }

            vec3 clr=vec3(0,0,0);
            float CE(in vec3 z0)
            {
                float a=atan2(z0.z,z0.x);
                float g=(sin(z0.x+sin(z0.z*1.7))+sin(z0.z+sin(z0.x*1.3)))*0.2;
                float d=abs(length(z0.xz-vec2(cos(a*8.0),sin(a*3.0))*0.75)-10.0)-0.4;
                float dg=(z0.y+g*smoothstep(0.0,0.5,d))*10.0;
                vec3 c,p=z0,col=vec3(0,0,0),prp=vec3(0,0,0);
                float d0=100.0;
                
                c=(z0-cp1)*10.0;
                c.xz=mul(cm1,c.xz);
                float dt=length(max(vec3(0,0,0),abs(c)-rc))-0.1;
                if(dt<d0){d0=dt;p=c;col=vec3(1.0,0.0,0.0);prp=vec3(1.21,0.4,1.97);}
                c=(z0-cp2)*10.0;c.xz=mul(cm2,c.xz);
                dt=length(max(vec3(0,0,0),abs(c)-rc))-0.1;
                if(dt<d0){d0=dt;p=c;col=vec3(0.0,1.0,0.0);prp=vec3(1.12,0.35,1.92);}
                c=(z0-cp3)*10.0;c.xz=mul(cm3,c.xz);
                dt=length(max(vec3(0,0,0),abs(c)-rc))-0.1;
                if(dt<d0){d0=dt;p=c;col=vec3(0.0,0.0,1.0);prp=vec3(0.61,0.26,1.48);}

                if(d0<dg)
                {   
                    vec3 p0=p;
                    float r=length(p.yz+vec2(prp.x,0.0));
                    d0=length(max(vec3(abs(p.x)-prp.y,r-prp.z,-p.y+0.16),0.0))-0.05;
                    d0=max(d0,p.z-1.0);
                    p+=vec3(0.0,-0.25,0.39);
                    p.xz=abs(p.xz);
                    p.xz-=vec2(0.5300,0.9600);
                    p.x=abs(p.x);
                    r=length(p.yz);
                    d0=smin(d0,length(max(vec3(p.x-0.08,r-0.25,-p.y-0.08),0.0))-0.04,8.0);
                    d0=max(d0,-max(p.x-0.165,r-0.24));
                    float d2=length(vec2(max(p.x-0.13,0.0),r-0.2))-0.02;
                    float d3=min(max(p.x-0.05,r-0.18),length(vec2(max(p.x-0.11,0.0),r-0.18))-0.02);
                    if(abs(p0.y-0.7)<0.1 && abs(p0.x)<prp.y+0.08 && p0.z>-0.9900)col=vec3(0,0,0);
                    if(d2<d0)
                    {
                        d0=d2;
                        col=vec3(0,0,0);
                    }
                    if(d3<d0)
                    {
                        d0=d3;
                        col=vec3(0.75,0.75,0.75);
                    }
                }
                if(dg<d0)
                {
                    spec=0.0;
                    col=lerp(vec3(0.5,0.4,0.0),vec3(0.1-g,0.3,0.1),smoothstep(0.0,0.25,d));
                    col=lerp(vec3(0.2-d*0.5,0.2-d*0.5,0.2-d*0.5),col,smoothstep(0.0,0.05,d));
                    a=min(d*floor(fmod(a*39.1,2.0)),abs(d+0.1)-0.4);
                    col=lerp(vec3(1.0,1.0,1.0),col,smoothstep(-0.40,-0.39,a));
                }
                else spec=0.5;
                clr+=col;
                return min(dg,d0)*0.1;
            }

            float linstep(float a, float b, float t)
            {   return clamp((t-a)/(b-a),0.,1.);  }  // i got this from knighty and/or darkbeam

            //random seed and generator
            float randSeed;
            float randStep()   //a simple pseudo random number generator based on iq's hash
            {   return  (0.8+0.2*fract(sin(++randSeed)*43758.5453123));   }

            float AO(vec3 ro, vec3 rd)
            {
                float t=0.0,d=1.0,s=1.0,rCoC=0.01;
                ro+=rd*rCoC*2.0;
                for(int i=0;i<16;i++){
                    float r=rCoC+t*0.5;//radius of cone
                    d=DE(ro+rd*t)+r*0.5;
                    s*=linstep(-r,r,d);
                    t+=abs(d)*randStep();
                }
                return clamp(0.25+0.75*s,0.0,1.0);
            }

            vec3 Light(vec3 P, vec3 rd, float t, float d)
            {
                vec2 v=vec2(pixelSize*t*0.1,0.0);
                clr=vec3(0,0,0);
                vec3 N=normalize(vec3(-CE(P-v.xyy)+CE(P+v.xyy),-CE(P-v.yxy)+CE(P+v.yxy),-CE(P-v.yyx)+CE(P+v.yyx)));
                clr*=0.1666;
                float s=0.03;
                if(clr.b>0.15) s=0.8;
            //  if(s<0.1)
            //    N=normalize(N+(texture2D(texture,P.xz*s).rgb-vec3(0.5))*0.2);
                clr*=max(0.25,dot(N,L));
                if(spec>0.0){
                    clr=lerp(clr,vec3(1.0,0.0,1.0),length(clr)*0.75*abs(dot(rd,N)));
                    clr+=sunColor*pow(max(0.0,dot(reflect(rd,N),L)),specExp)*spec;
                }
                return lerp(clr*AO(P,L),vec3(0.05,0.05,0.05),clamp(d*20.0,0.0,1.0)); //apply super soft shadow/ao
            }

            float3x3 lookat(vec3 fw,vec3 up)
            {
                fw=normalize(fw);vec3 rt=normalize(cross(fw,up));return float3x3(rt,cross(rt,fw),fw);
            }

            vec4 main(vec2 gl_FragCoord)
            {
                pixelSize = 2.0 / _Resolution.y;
                randSeed=fract(cos((gl_FragCoord.x+gl_FragCoord.y*117.0+time*10.0)*473.7192451));
                L=normalize(vec3(-0.25,0.33,-0.7));
                float tim=time*0.2;
                PositionCars(tim);
                tim+=sin(time*0.4)*1.5;
                float x=cos(tim)*12.0+cos(tim*1.6)*3.0;
                float y=sin(tim)*12.0+sin(tim*1.7)*3.0;
                vec3 ro=vec3(x,1.5,y);
                vec3 cp=lerp(cp2,cp3,sin(tim*1.3));
                vec2 uvOff=(2.0*gl_FragCoord.xy-_Resolution.xy)/_Resolution.y;

                vec3 rd=mul(lookat(cp-ro,vec3(0.0,1.0,0.0)),normalize(vec3(uvOff,12.0)));
                vec3 col=vec3(0.05,0.1,0.2)+sunColor*(pow(max(0.0,dot(L,rd)),2.0)+clamp(-rd.y*6.0,0.0,1.0));
                vec3 bcol=col;
                float t=0.0, d=1.0, od=1.0;
                for(int i=0;i<64;i++)
                {
                    if(d<0.0 || t>40.0)continue;
                    t+=d=DE(ro+rd*t)*0.95;
                }
                if(t<40.0)  // if we hit a surface color it
                    col=Light(ro+rd*t,rd,t,d);
                
                col=lerp(col,bcol,t*t/1600.0);
                return vec4(clamp(1.5*col,0.0,1.0),1.0);
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
