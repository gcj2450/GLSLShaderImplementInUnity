//http://tokyodemofest.jp/2014/7lines/index.html
//http://glslsandbox.com/e#45062.0
Shader "Unlit/ColorDotProgress"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Speed("Speed",float)=0.5
        _HeartSize("HeartSize",float)=1
        _HeartShape("HeartShape",float)=2
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

            uniform vec2  _Resolution;
            uniform float _Speed;
            uniform float _HeartSize;
            uniform float _HeartShape;

            //画心形
             float drawShape( vec2 p, float size )
            {
                float r = sqrt(p.x*p.x + p.y*p.y);
                float t = atan2(p.y, abs(p.x));
                float shape = r - size*(2.0 - 2.0*sin(t) + sin(t) * (sqrt(cos(t)) / (sin(t) + 1.4)));

                float thresh = 0.02;
                return smoothstep(thresh, thresh+0.01, shape);
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
				vec2 p=(input.uv.xy -.5 * _Resolution)/ min(_Resolution.x,_Resolution.y);
                vec3 c = vec3(0,0,0);

                /*这一段代码是画一个心形
                float aspectRatio = _Resolution.x/_Resolution.y;
                vec2 uv = input.uv.xy / _Resolution.xy;
                p = uv * 2.0 - 1.0;
                p.x *= aspectRatio;

                vec2 q = vec2(p.x, p.y - 0.5);
                float col = drawShape(q, 0.3);
                return vec4(0.9, col, col, 1.0);
                */

                for(int i = 0; i < 20; i++)
                {

                    /*只排成一个圆
                    float x = .5*cos(2.*3.14*float(i)/20.);
                    float y = .5*sin(2.*3.14*float(i)/20.);
                    vec2 o = vec2(x,y);
                    c += 0.01/(length(p-o))*vec3(1,1,1);
                    */

                    float f=2.* 3.14 * float(i) / 20. ;
                    float t = 2.*3.14*float(i)/20. * fract(time*_Speed);
                    //圆的参数方程，圆形移动小点
                    //float x = cos(t);
                    //float y = sin(t);

                    //一个非常好看的心形方程
                    float evl=_Speed * time*i;
                    float x = 16*pow(sin(evl), 3);//sin(time*3.0 + i * 0.0031415926) * 0.8;
                    float y = 13*cos(evl) - 5*cos(2*evl) - 2*cos(3*evl) - cos(4.0*evl);
                    x = -0.05*x; y = 0.05*y;

                    //心形参数方程，心形移动小点
                    //float y=_HeartSize*(2*cos(t)-cos(2*t));
                    //float x=_HeartSize*(2*sin(t)-sin(2*t));

                    //float y = sin(2.*t); //打开这句就是8字形移动
                    vec2 o = .45*vec2(x,y);

                    float r = fract(t*f);
                    float g = 1.-r;
                    float b = 1.-r;
                    c += 0.001/(length(p-o))*vec3(r,g,1);

                }
                return vec4(c,1);
			}
			ENDCG
		}
	}
}
