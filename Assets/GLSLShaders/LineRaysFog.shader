//http://glslsandbox.com/e#10999.0
Shader "Unlit/LineRaysFog"
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

            /** underwater intro by matt deslauriers / mattdesl */

            uniform vec2 _Resolution;
            uniform vec2 _Mouse;

            #define PI 3.1416

            vec3 dir(vec3 pos, float rotation) {
                
                return vec3(0,0,0);   
            }

            vec4 main(vec2 gl_FragCoord)
            {
                vec2 p = (gl_FragCoord.xy) / _Resolution.xy;
                p.x += 0.5;
                p.y -= 0.5;
                vec2 center = vec2(1.0, 0.5);
                float d = distance(p, center);
                
                    
                //bluish tint from top left
                float dval=1.0-d*0.75;
                vec3 color = vec3(dval,dval,dval) * vec3(0.33, 0.35, 0.5);
                
                //add some green near centre
                color += (1.0-distance(p, vec2(1.0, 0.0))*1.)*0.5 * vec3(0.1, 0.35, 0.40);
                
                vec3 lightColor = vec3(0.1, 0.1, 0.1);
                
                //will be better as uniforms
                for (int i=0; i<4; i++) {
                    //direction of light
                    float zr = sin(time*0.05*float(i))*1.5 - PI/2.0;
                    vec3 dir = vec3(cos(zr), sin(zr), 0.0);
                    
                    p.x += 0.002;
                    
                    //normalized spotlight vector
                    vec3 SpotDir = normalize(dir);
                    
                    //
                    vec3 attenuation = vec3(0.8, 2.0, 5.0);
                    float shadow = 1.0 / (attenuation.x + (attenuation.y*d) + (attenuation.z*d*d));

                    vec3 pos = vec3(p, 0.0);
                    vec3 delta = normalize(pos - vec3(center, 0.0));
                    
                    float cosOuterCone = cos(radians(1.0));
                    float cosInnerCone = cos(radians(18.0 + float(i*6)));
                    float cosDirection = dot(delta, SpotDir);
                    
                    //light...
                    color += smoothstep(cosInnerCone, cosOuterCone, cosDirection) * shadow * lightColor;
                }
                color += sin(time*0.5)*0.05;
                return vec4(vec3(color), 1.0);
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
