//http://glslsandbox.com/e#42079.0
Shader "Unlit/EvoFlowerLight"
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

            //.h
            vec3 sim(vec3 p,float s);
            vec2 rot(vec2 p,float r);
            vec2 rotsim(vec2 p,float s);

            //nice stuff :)
            vec2 makeSymmetry(vec2 p){
               vec2 ret=p;
               ret=rotsim(ret,5.08052);
               ret.x=abs(ret.x);
               return ret;
            }

            float makePoint(float x,float y,float fx,float fy,float sx,float sy,float t){
               float xx=x+tan(t*fx)*sx;
               float yy=y-tan(t*fy)*sy;
               return 0.5/sqrt(abs(x*xx+yy*yy));
            }

            vec3 sim(vec3 p,float s){
               vec3 ret=p;
               ret=p+s/2.0;
               ret=fract(ret/s)*s-s/2.0;
               return ret;
            }

            vec2 rot(vec2 p,float r){
               vec2 ret;
               ret.x=p.x*cos(r)-p.y*sin(r);
               ret.y=p.x*sin(r)+p.y*cos(r);
               return ret;
            }

            vec2 rotsim(vec2 p,float s){
               vec2 ret=p;
               ret=rot(p,-5.08/(s*2.0));
               ret=rot(p,floor(atan2(ret.x,ret.y)/5.08*s)*(5.08/s));
               return ret;
            }
            //Util stuff end



            vec2 complex_mul(vec2 factorA, vec2 factorB){
               return vec2( factorA.x*factorB.x - factorA.y*factorB.y, factorA.x*factorB.y + factorA.y*factorB.x);
            }

            vec2 torus_mirror(vec2 uv){
                return vec2(1,1)-abs(fract(uv*.5)*2.-1.);
            }

            float sigmoid(float x) {
                return 2./(1. + exp2(-x)) - 1.;
            }

            float smoothcircle(vec2 uv, float radius, float sharpness){
                return 0.5 - sigmoid( ( length( (uv - 0.5)) - radius) * sharpness) * 0.5;
            }

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
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
				 vec2 posScale = vec2(2.0,2.0);
                
                vec2 aspect = vec2(1.,_Resolution.y/_Resolution.x);
                vec2 uv = 0.5 + (input.uv.xy * vec2(1./_Resolution.x,1./_Resolution.y) - 0.5)*aspect;
                float mouseW = atan2((_Mouse.y - 0.5)*aspect.y, (_Mouse.x - 0.5)*aspect.x);
                vec2 mousePolar = vec2(sin(mouseW), cos(mouseW));
                vec2 offset = (_Mouse - 0.5)*2.*aspect;
                offset =  - complex_mul(offset, mousePolar) +time*0.0;
                vec2 uv_distorted = uv;
                
                float filter = smoothcircle( uv_distorted, 0.12, 100.);
                uv_distorted = complex_mul(((uv_distorted - 0.5)*lerp(2., 6., filter)), mousePolar) + offset;


               vec2 p=(input.uv.xy/_Resolution.x)*2.0-vec2(1.0,_Resolution.y/_Resolution.x);
                p = uv_distorted;
                p.y=-p.y;
               p=p*2.0;
              
               p=makeSymmetry(p);
               
               float x=p.x;
               float y=p.y;
               
               float t=time*0.1618;

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
               
               vec3 d=vec3(a+b,b+c,c)/32.0;
               
               return vec4(d.x,d.y,d.z,max(d.x, max(d.y, d.z)));
           }
		ENDCG
		}
	}
}
