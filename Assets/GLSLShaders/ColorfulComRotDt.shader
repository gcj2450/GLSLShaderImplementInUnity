//http://glslsandbox.com/e#24709.0\
//http://glslsandbox.com/e#24710.0
//http://glslsandbox.com/e#24414.0
Shader "Unlit/ColorfulComRotDt"
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

            vec4 RotComDo(in vec2 gl_FragCoord)
            {
                vec2 p = (gl_FragCoord.xy * 2.0 - _Resolution) / min(_Resolution.x, _Resolution.y);
                vec3 destColor = vec3(0,0,0);
                
                for(float i = 0.0; i < 10.0; i++){
                    float j = i + 1.23;
                    vec2 q = p + vec2(sin(time * j), cos(time * j));
                    destColor += 0.05 * abs(cos(time)) / length(q);
                }
                
                for(float i = 0.0; i < 10.0; i++){
                    float j = i + 6.54;
                    vec2 q = p + vec2(-sin(time * j) * abs(sin(time*3.0) + 0.5), cos(time * j) * abs(sin(time*3.0) + 0.5));
                    destColor += 0.02 * abs(tan(time/1.23)) / length(q);
                }
                
                float g = destColor.r * abs(sin(time*2.0));
                float b = destColor.r * abs(sin(time*5.0));
                float r = destColor.r * abs(cos(time*0.5));
                
                return vec4(r, g, b, 1.0);
            }

            vec4 AnotherMove(in vec2 gl_FragCoord)
            {
                vec2 p = (gl_FragCoord.xy * 2.0 - _Resolution) / min(_Resolution.x, _Resolution.y);
                p =mul( float2x2(cos(time*1.0), sin(time*1.0), -sin(time*1.0), cos(time*1.0)),p);
                
                vec3 destColor = vec3(0,0,0);
                for(float i = 2.0; i < 10.0; i++){
                    float j = i * i;
                    vec2 q = p + vec2(sin(time * j)*length(cos(time)), cos(time * j)*length(sin(time)));
                    destColor += 0.02 * abs(atan(time)) / length(q);
                }
                float g = destColor.r * abs(sin(time*5.0));
                float b = destColor.r * abs(sin(time*3.0));
                float r = destColor.r * abs(cos(time*0.2));
                
                destColor = vec3(0,0,0);
                for(float i = 2.0; i < 10.0; i++){
                    float j = i * i;
                    float tt = time + 2.0;
                    vec2 q = p + vec2(sin(tt * j)*length(cos(tt)), cos(tt * j)*length(sin(tt)));
                    destColor += 0.02 * abs(atan(tt)) / length(q);
                }
                
                g += destColor.r * abs(sin(time*2.0));
                b += destColor.r * abs(sin(time*5.0));
                r += destColor.r * abs(cos(time*0.5));
                
                return vec4(r, g, b, 1.0);
            }

            vec4 RotBlueDot(in vec2 gl_FragCoord)
            {
                #define PI 3.14159265358979
                #define N 10

                float size = 0.018;
                float dist = 1.0;
                float ang = 1.0;
                vec2 pos = vec2(0.765765765765675,7657576576576576765750.0);
                vec3 color = vec3(0, 0.012, 0.025);
                time = time * 1.5;
                for(int h=0; h<N; h++){
                    for(int i=0; i<N; i++){
                        float r = 0.5;
                        ang = pow(PI,PI*sin(ang)) / ((float(N+i+h))*(sin(time)))/rsqrt((sqrt(time)+atan(time))/pow(time, atan(float(i)*sin(time))));
                        pos = vec2(sin(ang),cos(ang))*-(r*r)*atan((time*ang)/sin(log(sqrt((cos(float(i+h)) * sin(float(-i-h))))) * sin(time)))/atan(time);
                        dist += size / distance(pos,gl_FragCoord+_Mouse);
                    }
                }
                return vec4(color * dist, 1.0);
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
                //return RotComDo(input.uv);
				//return AnotherMove(input.uv);
                return RotBlueDot(input.uv);
			}

			ENDCG
		}
	}
}
