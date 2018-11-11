//http://glslsandbox.com/e#14423.0
Shader "Unlit/WrinklePaper"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Scale("Scale",float)=1
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
            float _Scale;

            float pi = atan(1.)*4.;

            vec2 rand(vec2 co)
            {
                vec2 tmp;
                tmp.x = fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
                tmp.y = fract(sin(dot(co.xy ,vec2(7.3547,83.376))) * 58137.2774);   
                return tmp;
            }

            //Gradient functions from glsl.heroku.com/e#10011
            float LinearGrad(vec2 p1,vec2 p2,vec2 px)
            {
                vec2 dir = normalize(p2-p1);
                float g = dot(px-p1,dir)/length(p1-p2);
                return clamp(g,0.,1.);
            }

            float RadialGrad(vec2 p1,vec2 p2,vec2 px)
            {
                float g = distance(p1,px)/length(p1-p2);
                return 1.-clamp(g,0.,1.);
            }

            float SquareGrad(vec2 p1,vec2 p2,vec2 px)
            {
                vec2 p1x = abs(p1 - px);
                vec2 p12 = abs(p1-p2);
                float g = max(p1x.x,p1x.y)/max(p12.x,p12.y);
                return 1.-clamp(g,0.,1.);
            }

            float ConicalGrad(vec2 p1,vec2 p2,vec2 px)
            {
                float ap1x = atan2((p1-px).x,(p1-px).y)+pi;
                float ap12 = atan2((p1-p2).x,(p1-p2).y);
                float g = abs((abs(fmod((ap1x + pi -  ap12),(pi*2.))) - pi))/(pi);
                return clamp(g,0.,1.);
            }

            float Difference(float v1,float v2)
            {
                return abs(v1-v2);
            }

            float Wrinkle(vec2 p)
            {
                float col = time * 0.001;
                for(float i = 0.;i < 32.;i++)
                {
                    float grad = LinearGrad(rand(vec2(i*.1,i*.24)),rand(vec2(i*.6,i*.94)),p);
                    col = Difference(col,grad);
                }
                return col;
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
			
			fixed4 frag (v2f input) : SV_Target
			{
                vec2 p = ( input.uv.xy / _Resolution.xy )*_Scale;

                float col = 0.0;
                
                col = Wrinkle(p);
                col = 1.-Difference(col,Wrinkle(p-vec2(0.005,0.005))+0.2);
                
                return vec4( vec3( col,col,col ), 1.0 );

			}
			ENDCG
		}
	}
}
