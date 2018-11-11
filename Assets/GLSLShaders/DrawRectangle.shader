//http://glslsandbox.com/e#36578.4
//http://glslsandbox.com/e#36504.4
Shader "Unlit/DrawRectangle"
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
             
            //#extension GL_OES_standard_derivatives : enable
             
            uniform vec2  _Resolution;// resolution

            #define PI  3.14159265
            #define angle  60.0 
            //const float fov     = angle*0.5*PI/180.0;

            vec3 lDir = vec3(-0.577, 0.577, 0.577);
             
            float distBox(vec3 p, vec3 b)
            {
                return length(max(abs(p)-b, 0.0));
            }
             
            float distSphere(vec3 p, float s)
            {
                return length(p) - s;
            }
             
            /*
                
            */
            float distMap(vec3 p)
            {
                float ret = 0.0;
                
                ret = distSphere(p, 1.0);
                ret = distBox(p, vec3(0.5,0.5,0.5));
                
                return ret;
            }
             
            /*
                法線の取得
                1.レイの位置をずらしてマーチ
                2.結果から現在点の法線を算出
            */
            vec3 getNormal(vec3 p)
            {
                float d = 0.0001;
                
                return normalize(vec3(
                    distMap(p + vec3(  d, 0.0, 0.0)) - distMap(p + vec3( -d, 0.0, 0.0)),
                    distMap(p + vec3(0.0,   d, 0.0)) - distMap(p + vec3(0.0,  -d, 0.0)),
                    distMap(p + vec3(0.0, 0.0,   d)) - distMap(p + vec3(0.0, 0.0,  -d))
                ));
            }

            float sphere(vec3 pos, float size)
            {
                return length(pos) - size;
            }

            float udRoundBox( vec3 p, vec3 b, float r )
            {
                return length(max(abs(p)-b,0.0)) - r;
            }

            float dist(vec3 pos)
            {
                return udRoundBox(pos, vec3(4, 4, 4), 0.5);
            }
            //返回一个圆角矩形
            void getRounRect( out vec4 fColor, in vec2 uv ) 
            {
                vec2 tex = (uv.xy - _Resolution.xy / 2.0) / _Resolution.y;
                
                vec3 color = vec3(0, 0, 0);
                
                vec3 pos = vec3(0, 0, -10);
                vec3 dir = normalize(vec3(tex, 0.3));
                
                for (int i = 0; i < 64; ++i)
                {
                    float d = dist(pos);
                    if (d < 0.001) color = vec3(1, 1, 1);
                    
                    pos += dir * d;
                }

                fColor= vec4(color, 1.0);

            }
            //返回正方形
            void getRect(out vec4 fColor, in vec2 uv)
            {
                uv = (uv.xy*2.0-_Resolution)/min(_Resolution.x, _Resolution.y);

                vec3  cPos = vec3(0.0, 0.0, 3.0);
                vec3  cDir = vec3(0.0, 0.0,-1.0);
                vec3  cUp  = vec3(0.0, 1.0, 0.0);
                vec3  cSide= cross(cDir, cUp);
                float focus= 1.8;

                vec3 rPos = cPos;
                //vec3 rDir = normalize(cSide*uv.x + cUp*uv.y + cDir*focus);
                float fov     = angle*0.5*PI/180.0;
                vec3 rDir = normalize(vec3(sin(fov)*uv.x, sin(fov)*uv.y, -cos(fov)));
                
                const int MAX_MARCH = 64;
                float dist;
                float total = 0.0;
                for(int i = 0; i < MAX_MARCH; i++){
                    dist = distMap(rPos);
                    total += dist;
                    rPos = cPos + rDir*total;
                }
                
                /*
                */
                vec3  color  = vec3(1.0, 1.0, 1.0);
                vec3  normal = getNormal(rPos);
                float diff   = min(max(dot(lDir, normal), 0.1), 1.0);
                if(dist<0.001){
                    fColor= vec4(color, 1.0);
                }
                else{
                    fColor= vec4(0.0, 0.0, 0.0, 1.0);
                }
                
                /*
                //轮廓计算：因为是以法线为基础计算的，所以只能是球状的意思
                const float ol = 0.05;// out line(輪郭)
                if(ol > dot(normal, -rDir)){
                    fColor= vec4(1.0, 0.0, 0.0, 1.0);
                }
                else 
                    fColor= vec4(0.0, 0.0, 0.0, 1.0);
                */
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
                vec4 fragColor;
                getRect( fragColor, input.uv);
                //getRounRect( fragColor, input.uv);
                return fragColor;
			}
			ENDCG
		}
	}
}
