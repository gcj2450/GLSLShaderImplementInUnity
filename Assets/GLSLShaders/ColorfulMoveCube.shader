//http://glslsandbox.com/e#34642.0
Shader "Unlit/ColorfulMoveCube"
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


            uniform vec3  _Resolution;




            // I/O fragment shader by movAX13h, August 2013

            #define SHOW_BLOCKS

            float rand(float x)
            {
                return fract(sin(x) * 4358.5453123);
            }

            float rand(vec2 co)
            {
                return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5357);
            }

            float box(vec2 p, vec2 b, float r)
            {
              return length(max(abs(p)-b,0.0))-r;
            }

            float sampleMusic()
            {
                return 0.5;
            }

            void main(out vec4 fColor, in vec2 uv)
            {
                const float speed = 0.3;
                const float ySpread = 1.6;
                const int numBlocks = 15;

                float pulse = sampleMusic();
                
                uv = uv.xy / _Resolution.xy - 0.5;
                float aspect = _Resolution.x / _Resolution.y;
                vec3 baseColor = uv.x > 0.0 ? vec3(0.0,0.3, 0.6) : vec3(0.6, 0.0, 0.3);
                
                vec3 color = pulse*baseColor*0.5*(0.9-cos(uv.x*8.0));
                uv.x *= aspect;
                
                for (int i = 0; i < numBlocks; i++)
                {
                    float z = 1.0-0.7*rand(float(i)*1.4333); // 0=far, 1=near
                    float tickTime = time*z*speed + float(i)*1.23753;
                    float tick = floor(tickTime);
                    
                    vec2 pos = vec2(0.6*aspect*(rand(tick)-0.5), sign(uv.x)*ySpread*(0.5-fract(tickTime)));
                    pos.x += 0.24*sign(pos.x); // move aside
                    if (abs(pos.x) < 0.1) pos.x++; // stupid fix; sign sometimes returns 0
                    
                    vec2 size = 1.8*z*vec2(0.04, 0.04 + 0.1*rand(tick+0.2));
                    float b = box(uv-pos, size, 0.01);
                    float dust = z*smoothstep(0.22, 0.0, b)*pulse*0.5;
                    #ifdef SHOW_BLOCKS
                    float block = 0.2*z*smoothstep(0.002, 0.0, b);
                    float shine = 0.6*z*pulse*smoothstep(-0.002, b, 0.007);
                    color += dust*baseColor + block*z + shine;
                    #else
                    color += dust*baseColor;
                    #endif
                }
                
                //color -= rand(uv)*0.04;
                fColor = vec4(color, 1.0);
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
				vec4 fColor;
                main(fColor, input.uv);
                return fColor;
			}
			ENDCG
		}
	}
}
