//http://glslsandbox.com/e#45503.0
Shader "Unlit/ColorBall"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Speed("Speed",float)=1
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

            uniform vec2 _Resolution;


            // More Mods By NRLABS 2016

            float _Speed = 0.0750;

            float ball(vec2 p, float fx, float fy, float ax, float ay)
            {
                vec2 r = vec2(p.x + sin(time*_Speed / 2.0 * fx) * ax * 12.0, p.y + 
                                cos(time*_Speed/ 2.0 * fy) * ay * 8.0);    
                return .057 / length(r / sin(fy * time * 0.1));
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
				vec2 p = ( input.uv.xy / _Resolution.xy ) * 3.0 - 1.0;
                p.x *= _Resolution.x / _Resolution.y;
                
                float col = 0.0 ,col2 = 0.0;
                col += ball(p, 31.0, 22.0, 0.03, 0.09);
                col += ball(p, 22.5, 22.5, 0.04, 0.04);
                col += ball(p, 12.0, 23.0, 0.05, 0.03);
                col += ball(p, 32.5, 33.5, 0.06, 0.04);
                col += ball(p, 23.0, 24.0, 0.07, 0.03); 
                col += ball(p, 21.5, 22.5, 0.08, 0.02);
                col += ball(p, 33.1, 21.5, 0.09, 0.07);
                col += ball(p, 23.5, 32.5, 0.09, 0.06);
                col += ball(p, 14.1, 13.5, 0.09, 0.05);
                
                col2 += ball(p, 22.0, 27.0, 0.03, 0.05);
                col2 += ball(p, 12.5, 17.5, 0.04, 0.06);
                col2 += ball(p, 23.0, 17.0, 0.05, 0.02);
                col2 += ball(p, 19.5, 23.5, 0.06, 0.09);
                col2 += ball(p, 33.0, 14.0, 0.07, 0.01);    
                col2 += ball(p, 11.5, 12.5, 0.08, 0.04);
                col2 += ball(p, 23.1, 11.5, 0.09, 0.07);
                col2 += ball(p, 13.5, 22.5, 0.09, 0.03);
                col2 += ball(p, 14.1, 23.5, 0.09, 0.08);
                col2 += ball(p, 4.1, 3.5, 0.07, 0.05);
                return vec4(pow(col * 0.54 * col2,3.0/col), 
                                                col * 0.34, col2 * 0.9 * sin(time), 1.0)+ 
                                        vec4(col2 * 0.33,col * col2 * 0.24 * cos(time),col2*0.9,1.0);
			}
			ENDCG
		}
	}
}
