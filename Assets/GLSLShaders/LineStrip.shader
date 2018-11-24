//http://glslsandbox.com/e#44477.0
//http://glslsandbox.com/e#44478.0
Shader "Unlit/LineStrip"
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
            precision highp float;
            #endif

            uniform vec2 _Resolution;

            float makePoint(float x,float y,float fx,float fy,float sx,float sy,float t){
               float xx=x+tan(t*fx)*sx;
               float yy=y+sin(t*fy)*sy;
               //return 1.0/sqrt(length(xx+yy));  //返回线
               return 1.0/sqrt(xx*xx+yy*yy);    //返回点
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
				vec2 p=(input.uv.xy/_Resolution.x)*2.0-vec2(1.0,_Resolution.y/_Resolution.x);

               p=p*2.0;
               
               float x=p.x;
               float y=p.y;

               float a=
                   makePoint(x,y,3.3,2.9,0.3,0.3,time);
               a=a+makePoint(x,y,1.9,2.0,0.4,0.4,time);
               
               float b=
                   makePoint(x,y,1.2,1.9,0.3,0.3,time);
               b=b+makePoint(x,y,0.7,2.7,0.4,0.4,time);

               float c=
                   makePoint(x,y,3.7,0.3,0.3,0.3,time);
               c=c+makePoint(x,y,1.9,1.3,0.4,0.4,time);
               
               vec3 d=vec3(a,b,c)/32.0;
               
               return vec4(d.x,d.y,d.z,1.0);
			}
			ENDCG
		}
	}
}
