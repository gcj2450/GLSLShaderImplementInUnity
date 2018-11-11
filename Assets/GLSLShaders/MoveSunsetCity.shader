//http://glslsandbox.com/e#41611.0
Shader "Unlit/MoveSunsetCity"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
        _Coiff("Coiff",float)=1
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
            precision highp float;
            #endif

            float _Coiff;
             
            uniform vec2 _Mouse;
            uniform vec2 _Resolution;


            vec3 getAtmosphericScattering(vec2 uv){
                
                float zenith = (0.1 / uv.y * _Coiff); //Density of the atmosphere
                
                vec3 color = vec3(0.26,0.5,1.0) * zenith; //The color of the sky multiplied by the density
                //Make it so higher values gets scattered more than lower values based on density
                color = pow(color, 1.0 - vec3(zenith,zenith,zenith));  
                
                return max(color, 0.0); //Limit the final color to not go under 0.0
                
            }

            float random(float p) {
              return fract(sin(p)*10000.);
            }
            float noise(vec2 p) {
              return random(p.x + p.y*100.);
            }

            float city(vec2 uv){
                return 1.0 - step(random(floor(uv.x * 30.0)) * 0.1 + 0.05, uv.y);
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
				vec2 position = input.uv.xy / _Resolution.y; 
                //position.x += mouse.x;
                position.x += time*0.1;
                vec3 color = getAtmosphericScattering(position);
                     color /= 1.0 + color; //Fix color banding

                //添加一些噪点当星星
                color += noise(position) * noise(position+1.0) * noise(position+2.0) * noise(position+3.0)
                    * noise(position+4.0) * noise(position+5.0) * noise(position+6.0) ;
                
                color = lerp(color, vec3(0,0,0), city(position));

                return vec4(color, 1.0);
			}
			ENDCG
		}
	}
}
