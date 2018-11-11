//http://glslsandbox.com/e#24166.5
Shader "Unlit/FogCube"
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

            #define MAXITER 100
            #define DELTA 0.001
            #define SPEED 50.0
            #define MAXDIST 100.0

            // Procedural Geometry Concept for VRRunner by Jaksa

            float noise(float x) {
                return fract(sin(dot(vec2(x,x), vec2(12.9898, 78.233)))* 43758.5453);
            }

            float cube(vec3 p) {
                vec3 center = vec3(0,-5,10);
                vec3 dist = abs(p - center) - 3.0;
                dist.y = p.y - center.y;
                return max(dist.x, max(dist.y, dist.z));
            }

            float cubes(vec3 p) {
                float section = floor(p.z/10.0);
                
                p.z = fmod(p.z, 10.0);
                
                p.y += noise(section+3.0)*10.0;
                p.x += noise(section)*50.0-25.0;
                
                return min(7.0, cube(p));
            }

            float scene(vec3 p) {   
                return min(cubes(p), 60.0 + p.y);
            }

            vec4 main( in vec2 gl_FragCoord ) {
                vec2 p2d = ( gl_FragCoord.xy / _Resolution.xy ) * 2.0 - 1.0;
                p2d.x *= _Resolution.x/_Resolution.y;

                vec3 ro = vec3(0,0,time*SPEED);
                vec3 rd = normalize(vec3(p2d, 1.0));
                
                vec3 p = ro;
                float dist = 0.0;
                for (int i = 0; i < MAXITER; i++) {
                    float d = scene(p);
                    if (d < DELTA) break;
                    if (d > MAXDIST) break;
                    p += d*rd;
                    dist += d;
                }
                        
                return vec4(vec3(dist*.007,dist*.007,dist*.007), 1.0);
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
				return main(input.uv );
			}
			ENDCG
		}
	}
}
