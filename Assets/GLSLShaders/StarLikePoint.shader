//http://glslsandbox.com/e#30371.0
Shader "Unlit/StarLikePoint"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Scale("Scale",float)=50
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
            float _Scale;

            float makePoint(float x,float y,float fx,float fy,float sx,float sy,float t){
               float xx=x+sin(t*fx)*sx * _Scale;
               float yy=y+cos(t*fy)*sy * _Scale;
               return 1.0/sqrt(xx*xx*yy*yy)/_Scale;
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
				//vec2 p=(input.xy/_Resolution.xy)*2.0-vec2(1.0,_Resolution.y/_Resolution.x);
               //p=p*2.0;
                
               vec2 p = (( input.uv.xy / _Resolution.xy ) * 2.0 - 1.0)*_Scale;
               p*=normalize(_Resolution).xy;
              
               float x=p.x;
               float y=p.y;
               float thyme= time * 0.15;
               float a=makePoint(x,y,2.0,2.5,0.9,0.3,thyme);
               float b=makePoint(x,y,1.0,1.5,0.6,0.6,thyme);
               float c=makePoint(x,y,3.0,3.5,0.3,0.9,thyme);
               float d=makePoint(x,y,1.0,1.5,0.3,0.9,thyme);
               float e=makePoint(x,y,2.0,2.5,0.6,0.6,thyme);
               float f=makePoint(x,y,3.0,3.5,0.9,0.3,thyme);

               vec3 C=vec3(a*3.0,a*a,a*a)+vec3(b*b,b*3.0,b*b)+vec3(c*c,c*c,c*3.0)+
                   vec3(d*1.5,d*1.5,d*d*d)+vec3(e*e*e,e*1.5,e*1.5)+vec3(f*1.5,f*f*f,f*1.5);
               
               return vec4(pow(C,vec3(1.0/2.2,1.0/2.2,1.0/2.2)),1.0);
			}
			ENDCG
		}
	}
}
