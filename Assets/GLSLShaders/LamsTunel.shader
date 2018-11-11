//http://glslsandbox.com/e#1674.0
Shader "Unlit/LamsTunel"
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
            #define mix lerp
            #define mod fmod
            /* lame-ass tunnel by kusma */

            #ifdef GL_ES
            precision mediump float;
            #endif

            uniform vec2 _Resolution;




            float rand (float x) {
                return fract(sin(x * 24614.63) * 36817.352);    
            }

            vec4  main( vec2 gl_FragCoord) {
                vec2 position = (gl_FragCoord.xy - _Resolution * 0.5) / _Resolution.yy;
                float th = atan2(position.y, position.x) / (2.0 * 3.1415926) + 10.0;
                float dd = length(position);
                float d = 0.5 / dd + time;

                vec3 uv = vec3(th + d, th - d, th + sin(d));
                float a = 0.5 + cos(uv.x * 3.1415926 * 2.0) * 0.3;
                float b = 0.5 + cos(uv.y * 3.1415926 * 8.0) * 0.3;
                float c = 0.5 + cos(uv.z * 3.1415926 * 6.0) * 0.5;
                float f = abs(sin(time*2.0));
                vec3 color = mix(vec3(1.0, 0.8, 1.0-f), vec3(0.5*f, 0, 0), pow(a, 0.2)) * 3.;
                color += mix(vec3(0.8, 0.9, 1.0), vec3(0.1, 0.1, 0.2),  pow(b, 0.1)) * 0.75;
                color += mix(vec3(0.9, 0.8, 1.0), vec3(0.1, 0.2, 0.2),  pow(c, 0.1)) * 0.75;
                
                float scale = sin(0.1 * time) * 0.5 + 5.0;
                float distortion = _Resolution.y / _Resolution.x;

                vec2 position2 = (((gl_FragCoord.xy * 0.8 / _Resolution) ) * scale);
                position2.y *= distortion;

                float gradient = 0.0;
                vec3 color2 = vec3(0,0,0);
             
                float fade = 0.5;
                float z = 0.6;
             
                vec2 centered_coord = position2 - vec2(2.0,1.0);

                for (float i=1.0; i<=134.0; i++)
                {
                    vec2 star_pos = vec2(sin(i) * 200.0, sin(i*i*i) * 300.0);
                    float z = mod(i*i - 100.0*time, 512.0);
                    float fade = (456.0 - z) /300.0;
                    vec2 blob_coord = star_pos / z;
                    gradient += ((fade / 1500.0) / pow(length(centered_coord - blob_coord ), 1.8)) * ( fade);
                }

                color2 = color * gradient;
                
                return vec4( max( color * clamp(dd, 0.0, 1.0) , color2 ) , 1.0);
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
