//http://glslsandbox.com/e#6687.0
Shader "Unlit/ShineBox"
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
            // by rotwang

            #ifdef GL_ES
            precision mediump float;
            #endif

            uniform vec2 _Resolution;
            const float PI = 3.1415926535;

            float max3(float a,float b,float c)
            {
                return max(a, max(b,c));
            }



            float rect( vec2 p, vec2 b, float smooth )
            {
                vec2 v = abs(p) - b;
                float d = length(max(v,0.0));
                return 1.0-pow(d, smooth);
            }

            vec4 main( vec2 gl_FragCoord ) {

                vec2 unipos = (gl_FragCoord.xy / _Resolution);
                vec2 pos = unipos*2.0-1.0;
                pos.x *= _Resolution.x / _Resolution.y;

                float flash = sin(time*8.0);
                float uflash = flash;
                
                
                
                // scroll
                //pos.x -= sin(time*0.5)*1.0;
                
                float d1 = rect(pos - vec2(-1.0,0.0), vec2(0.1,0.75), 0.1); 
                vec3 clr1 = vec3(0.2,0.6,1.0) *d1; 
                
                float d2 = rect(pos - vec2(0.0,0.0), vec2(0.1,0.5), 0.1); 
                vec3 clr2 = vec3(0.6,0.99,0.2) *d2; 

                float d3 = rect(pos - vec2(1.0,0.0), vec2(0.1,0.25), uflash*0.2); 
                vec3 clr3 = vec3(0.99,0.6,0.2) *0.75*d3 + (0.25*flash); 

                
                
                vec3 clr = clr1+clr2+clr3;
                return vec4( clr , 1.0 );

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
			
			fixed4 frag (v2f i) : SV_Target
			{
				return main(i.uv);
			}
			ENDCG
		}
	}
}
