﻿//http://glslsandbox.com/e#25469.0
Shader "Unlit/ColorfulRot"
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


            //.h
            vec3 sim(vec3 p,float s);
            vec2 rot(vec2 p,float r);
            vec2 rotsim(vec2 p,float s);
            vec2 zoom(vec2 p,float f);

            //nice stuff :)
            vec2 makeSymmetry(vec2 p){
               vec2 ret=p;
               ret=rotsim(ret,sin(time*0.9)*2.0+3.0);


               ret.x=abs(ret.x);
               return ret;
            }

            float makePoint(float x,float y,float fx,float fy,float sx,float sy,float t){
               float xx=x+tan(t*fx)*sy;
               float yy=y-tan(t*fy)*sy;
               float a=0.5/sqrt(abs(abs(x*xx)+abs(yy*y)));
               float b=0.5/sqrt(abs(x*xx+yy*y));
               return a*b;
            }

            //util functions
            const float PI=3.14159265;

            vec3 sim(vec3 p,float s){
               vec3 ret=p;
               ret=p+s/2.0;
               ret=fract(ret/s)*s-s/40.0;
               return ret;
            }

            vec2 rot(vec2 p,float r){
               vec2 ret;
               ret.x=p.x*sin(r)*cos(r)-p.y*cos(r);
               ret.y=p.x*cos(r)+p.y*sin(r);
               return ret;
            }

            vec2 rotsim(vec2 p,float s){
               vec2 ret=p;
               ret=rot(p,-PI/(s*2.0));
               ret=rot(p,floor(atan2(ret.x,ret.y)/PI*s)*(PI/s));
               return ret;
            }

            vec2 zoom(vec2 p,float f){
                return vec2(p.x*f,p.y*f);
            }
            //Util stuff end


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
			
			fixed4 frag (v2f input) : SV_Target
			{
				vec2 p = input.uv.xy/_Resolution.y-vec2((_Resolution.x/_Resolution.y)/2.0,0.5);

               p=rot(p,sin(time+length(p))*1.0);
               p=zoom(p,sin(time*2.0)*0.5+0.8);

               p=p*2.0;
               
               float x=p.x;
               float y=p.y;
               
               float t=time*0.5;

               float a=
                   makePoint(x,y,3.3,2.9,0.3,0.3,t);
               a=a+makePoint(x,y,1.9,2.0,0.4,0.4,t);
               a=a+makePoint(x,y,0.8,0.7,0.4,0.5,t);
               a=a+makePoint(x,y,2.3,0.1,0.6,0.3,t);
               a=a+makePoint(x,y,0.8,1.7,0.5,0.4,t);
               a=a+makePoint(x,y,0.3,1.0,0.4,0.4,t);
               a=a+makePoint(x,y,1.4,1.7,0.4,0.5,t);
               a=a+makePoint(x,y,1.3,2.1,0.6,0.3,t);
               a=a+makePoint(x,y,1.8,1.7,0.5,0.4,t);   
               
               float b=
                   makePoint(x,y,1.2,1.9,0.3,0.3,t);
               b=b+makePoint(x,y,0.7,2.7,0.4,0.4,t);
               b=b+makePoint(x,y,1.4,0.6,0.4,0.5,t);
               b=b+makePoint(x,y,2.6,0.4,0.6,0.3,t);
               b=b+makePoint(x,y,0.7,1.4,0.5,0.4,t);
               b=b+makePoint(x,y,0.7,1.7,0.4,0.4,t);
               b=b+makePoint(x,y,0.8,0.5,0.4,0.5,t);
               b=b+makePoint(x,y,1.4,0.9,0.6,0.3,t);
               b=b+makePoint(x,y,0.7,1.3,0.5,0.4,t);

               float c=
                   makePoint(x,y,3.7,0.3,0.3,0.3,t);
               c=c+makePoint(x,y,1.9,1.3,0.4,0.4,t);
               c=c+makePoint(x,y,0.8,0.9,0.4,0.5,t);
               c=c+makePoint(x,y,1.2,1.7,0.6,0.3,t);
               c=c+makePoint(x,y,0.3,0.6,0.5,0.4,t);
               c=c+makePoint(x,y,0.3,0.3,0.4,0.4,t);
               c=c+makePoint(x,y,1.4,0.8,0.4,0.5,t);
               c=c+makePoint(x,y,0.2,0.6,0.6,0.3,t);
               c=c+makePoint(x,y,1.3,0.5,0.5,0.4,t);
               
               vec3 d=vec3(a,b,c)/31.0;
               
               return vec4(d.x,d.y,d.z,1.0);
			}
			ENDCG
		}
	}
}
