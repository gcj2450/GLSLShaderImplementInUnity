//http://glslsandbox.com/e#48595.6
Shader "Unlit/EvolutionSky"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (0,1,0,1)
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

            uniform vec4 _Resolution;

            #define iterations 4
            #define formuparam2 0.89
            #define volsteps 10
            #define stepsize 0.190
            #define zoom 3.900
            #define tile 0.450
            #define speed2 0.010
            #define brightness 0.2
            #define darkmatter 0.400
            #define distfading 0.560
            #define saturation 0.400
            #define transverseSpeed 1.1
            #define cloud 0.2
            #define PI 3.14159265359


            float field( in vec3 p) {
              float strength = 7.0 + 0.03 * log(1.e-6 + fract(sin(time) * 4373.11));
              float accum = 0.0;
              float prev = 0.0;
              float tw = 0.0;

              for (int i = 0; i < 6; ++i) {
                float mag = dot(p, p);
                p = abs(p) / mag + vec3(-0.5, -0.8 + 0.1 * sin(time * 0.2 + 2.0), -1.1 + 0.3 * cos(time * 0.15));
                float w = exp(-float(i) / 7.0);
                accum += w * exp(-strength * pow(abs(mag - prev), 2.3));
                tw += w;
                prev = mag;
              }
              return max(0.0, 5.0 * accum / tw - 0.7);
            }

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
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

              vec2 uv2 = (2.0 * (i.uv.xy / _Resolution.xy)) - 1.0;
              vec2 uvs = uv2 * _Resolution.xy / max(_Resolution.x, _Resolution.y);

              float time2 = time  ;

              float speed = speed2;
              speed = 0.005 * cos(time2 * 0.02 + PI / 4.0);

              float formuparam = formuparam2;

              // get coords and direction

              vec2 uv = uvs;

              // mouse rotation
              float aXZ = 0.9;
              float aYZ = -0.6;
              float aXY = 0.9 + time * 0.04;

              vec4 rotXZ = vec4(cos(aXZ), sin(aXZ), -sin(aXZ), cos(aXZ));
              vec4 rotYZ = vec4(cos(aYZ), sin(aYZ), -sin(aYZ), cos(aYZ));
              vec4 rotXY = vec4(cos(aXY), sin(aXY), -sin(aXY), cos(aXY));

              float v2 = 1.0;

              vec3 dir = vec3(uv * zoom, 1.0);
              vec3 from = vec3(0.0,0.0,0.0);

              from.x -= 0.5 * (-0.5);
              from.y -= 0.5 * (-0.5);

              vec3 forward = vec3(0.0, 0.0, 1.0);

              from.x += transverseSpeed * (1.0) * cos(0.01 * time) + 0.001 * time;
              from.y += transverseSpeed * (1.0) * sin(0.01 * time) + 0.001 * time;
              from.z += 0.003 * time;

              dir.xy *= rotXY;
              forward.xy *= rotXY;

              dir.xz *= rotXZ;
              forward.xz *= rotXZ;

              dir.yz *= rotYZ;
              forward.yz *= rotYZ;

              from.xy *= -rotXY;
              from.xz *= rotXZ;
              from.yz *= rotYZ;

              // zoom
              float zooom = (time2 - 3311.0) * speed;
              from += forward * zooom;
              float sampleShift = fmod(zooom, stepsize);

              float zoffset = -sampleShift;
              sampleShift /= stepsize; // make from 0 to 1

              // volumetric rendering
              float s = 0.24;
              float s3 = s + stepsize / 2.0;
              vec3 v = vec3(0.0,0.0,0.0);
              float t3 = 0.0;

              vec3 backCol2 = vec3(0,0,0);
              for (int r = 0; r < volsteps; r++) {
                vec3 p2 = from + (s + zoffset) * dir;
                vec3 p3 = (from + (s3 + zoffset) * dir) * (1.9 / zoom);

                p2 = abs(vec3(tile,tile,tile) - fmod(p2, vec3(tile * 2.0,tile * 2.0,tile * 2.0))); // tiling fold
                p3 = abs(vec3(tile,tile,tile) - fmod(p3, vec3(tile * 2.0,tile * 2.0,tile * 2.0))); // tiling fold

                #ifdef cloud
                t3 = field(p3);
                #endif

                float pa = 0.0;
                float a = 0.0;
                for (int i = 0; i < iterations; i++) {
                  p2 = abs(p2) / dot(p2, p2) - formuparam; // the magic formula
                  float D = abs(length(p2) - pa); // absolute sum of average change

                  if (i > 2) {
                    a += i > 7 ? min(12.0, D) : D;
                  }
                  pa = length(p2);
                }

                a = a * a * a; // add contrast

                // brightens stuff up a bit
                float s1 = s + zoffset;

                // need closed form expression for this, now that we shift samples
                float fade = pow(distfading, max(0.0, float(r) - sampleShift));

                v += fade;

                // fade out samples as they approach the camera
                if (r == 0)
                  fade *= (1.0 - (sampleShift));

                // fade in samples as they approach from the distance
                if (r == volsteps - 1)
                  fade *= sampleShift;
                v += vec3(s1, s1 * s1, s1 * s1 * s1 * s1) * a * brightness * fade; // coloring based on distance

                backCol2 += lerp(0.4, 1.0, v2) * vec3(0.20 * t3 * t3 * t3, 0.4 * t3 * t3, t3 * 0.7) * fade;

                s += stepsize;
                s3 += stepsize;
              }

              v = lerp(vec3(length(v),length(v),length(v)), v, saturation); // color adjust

              vec4 forCol2 = vec4(v * 0.01, 1.0);

              #ifdef cloud
              backCol2 *= cloud;
              #endif

              // backCol2.r *= 1.80;
              // backCol2.g *= 0.05;
              // backCol2.b *= 0.90;

              return forCol2 + vec4(backCol2, 1.0);

			}
			ENDCG
		}
	}
}
