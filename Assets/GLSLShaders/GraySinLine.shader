Shader "Unlit/GraySinLine"
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

            vec4 main(vec2 gl_FragCoord)
            {
                vec3 col = vec3(0., 0., 0.);
                const int itrCount = 10;
                for (int i = 0; i < itrCount; ++i)
                {
                    
                    float offset = float(i) / float(itrCount);
                    float t = time + (offset * offset * 2.);
                    
                    vec2 pos=(gl_FragCoord.xy/_Resolution.xy);
                    pos.y-=0.5;
                    pos.y+=sin(pos.x*9.0+t)*.2*sin(t*.8);
                    float color=1.0-pow(abs(pos.y),0.2);
                    float colora=pow(1.,0.2*abs(pos.y));
                    
                    float rColMod = ((offset * .5) + .5) * colora;
                    float bColMod = (1. - (offset * .5) + .5) * colora;
                    
                    col += vec3(color * rColMod, color, color * bColMod) * (1. / float(itrCount));
                }
                col = clamp(col, 0., 1.);
                
                return vec4(col.x, col.y, col.z ,1.0);
                    
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
