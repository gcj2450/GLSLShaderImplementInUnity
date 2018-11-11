//http://glslsandbox.com/e#42909.0
Shader "Unlit/MilkyStarLine"
{
	Properties
	{
		 _Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
        _Scale ("Scale", float) = 1
        _Angle ("Angle", float) = 1
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
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
            #define vec2 float2
            #define vec3 float3
            #define vec4 float4
            #define time _Time.g
            #define fract frac
            #define mix lerp
            #define mod fmod
            #define mat3 float3x3

            #ifdef GL_ES
            precision mediump float;
            #endif


            // afl_ext 2017


            //#extension GL_OES_standard_derivatives : enable

            uniform vec2 _Mouse;
            uniform vec2 _Resolution;
            float _Scale;
            float _Angle;

            mat3 rotationMatrix(vec3 axis, float angle)
            {
                axis = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float oc = 1.0 - c;

                return mat3(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s,
                    oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s,
                    oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c);
            }


            float hash( float n ){
                return fract(sin(n)*758.5453);
            }

             float configurablenoise(vec3 x, float c1, float c2) {
                vec3 p = floor(x);
                vec3 f = fract(x);
                f       = f*f*(3.0-2.0*f);

                float h2 = c1;
                 float h1 = c2;
                #define h3 (h2 + h1)

                 float n = p.x + p.y*h1+ h2*p.z;
                return mix(mix( mix( hash(n+0.0), hash(n+1.0),f.x),
                        mix( hash(n+h1), hash(n+h1+1.0),f.x),f.y),
                       mix( mix( hash(n+h2), hash(n+h2+1.0),f.x),
                        mix( hash(n+h3), hash(n+h3+1.0),f.x),f.y),f.z);

            }

            float supernoise3dX(vec3 p){

                float a =  configurablenoise(p, 883.0, 971.0);
                float b =  configurablenoise(p + 0.5, 113.0, 157.0);
                return (a * b);
            }

            float fbmHI2d(vec2 p, float dx){
               // p *= 0.1;
                p *= 1.2;
                //p += getWind(p * 0.2) * 6.0;
                float a = 0.0;
                float w = 1.0;
                float wc = 0.0;
                for(int i=0;i<5;i++){
                    //p += noise(vec3(a));
                    a += clamp(2.0 * abs(0.5 - (supernoise3dX(vec3(p, time * 0.2)))) * w, 0.0, 1.0);
                    wc += w;
                    w *= 0.5;
                    p = p * dx;
                }
                return a / wc;// + noise(p * 100.0) * 11;
            }

            float stars(vec2 seed, float intensity){
                return smoothstep(1.0 - intensity*0.9, (1.0 - intensity *0.9)+0.1, supernoise3dX(vec3(seed * 700.0, time * 0.2)) * (0.8 + 0.2 * supernoise3dX(vec3(seed * 40.0, time * 0.2))));
            }
            vec3 stars(vec2 uv){
                float intensityred = (1.0 / (1.0 + 30.0 * abs(uv.y))) * fbmHI2d(uv * 30.0, 3.0) * (1.0 - abs(uv.x ));   
                float intensitywhite = (1.0 / (1.0 + 20.0 * abs(uv.y))) * fbmHI2d(uv * 30.0 + 120.0, 3.0) * (1.0 - abs(uv.x )); 
                float intensityblue = (1.0 / (1.0 + 20.0 * abs(uv.y))) * fbmHI2d(uv * 30.0 + 220.0, 3.0) * (1.0 - abs(uv.x ));  
                float galaxydust = smoothstep(0.1, 0.5, (1.0 / (1.0 + 20.0 * abs(uv.y))) * fbmHI2d(uv * 20.0 + 220.0, 3.0) * (1.0 - abs(uv.x )));   
                float galaxydust2 = smoothstep(0.2, 0.5, (1.0 / (1.0 + 20.0 * abs(uv.y))) * fbmHI2d(uv * 50.0 + 220.0, 3.0) * (1.0 - abs(uv.x )));  
                intensityred = 1.0 - pow(1.0 - intensityred, 3.0) * 0.73;
                intensitywhite = 1.0 - pow(1.0 - intensitywhite, 3.0) * 0.73;
                intensityblue = 1.0 - pow(1.0 - intensityblue, 3.0) * 0.73;
                float redlights = stars(uv, intensityred );
                float whitelights = stars(uv, intensitywhite );
                float bluelights = stars(uv, intensityblue );
                vec3 starscolor = vec3(1.0, 0.8, 0.5) * redlights + vec3(1.0,1,1) * whitelights + vec3(0.6, 0.7, 1.0) * bluelights;
                vec3 dustinner = vec3(0.8, 0.9, 1.0);
                vec3 dustouter = vec3(0.2, 0.1, 0.0);
                vec3 innermix = mix(dustinner, starscolor, 1.0 - galaxydust);
                vec3 bloom = dustinner * (1.0 / (1.0 + 30.0 * abs(uv.y))) * fbmHI2d(uv * 3.0, 3.0) * (1.0 - abs(uv.x ));    
                vec3 allmix = mix(dustouter, innermix + bloom, 1.0 - galaxydust2);
                return .2*allmix + bloom;
            }

            vec3 milkyway(vec2 uv){
                return stars(uv);
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
                vec2 position = ( input.uv.xy / _Resolution.xy ) + _Mouse / 4.0;
                
                vec2 pos =mul(rotationMatrix(vec3(0.0, 0.0, 1.0), _Angle) ,vec3(position*_Scale, 0.0).xy);

                return vec4( milkyway(pos), 1.0 );

			}
			ENDCG
		}
	}
}
