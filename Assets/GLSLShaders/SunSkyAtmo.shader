//http://www.robobo1221.net/shaders
//Shadertoy: http://www.shadertoy.com/user/robobo1221
//http://glslsandbox.com/e#41673.0
//http://glslsandbox.com/e#41609.0
Shader "Unlit/SunSkyAtmo"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
        //把GLSL Shader 里定义的变量拿到属性里就有效果了
        _TotalRaylen ("TotalRaylen", Vector) = (0.3, 0.5, 1.0)
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

            //#extension GL_OES_standard_derivatives : enable

            uniform vec2 _Mouse;
            uniform vec2 _Resolution;

            vec3 _TotalRaylen;

            vec3 getSkyAbsoption(vec3 x, float y){
                
                vec3 absoption = _TotalRaylen * y;
                     absoption = pow(absoption, vec3(1.0 - y,1.0 - y,1.0 - y)) / x / y;
                
                return absoption;
            }

            float getSunPoint(vec2 p, vec2 lp){
                return smoothstep(0.03, 0.026, distance(p, lp)) * 50.0;
            }

            float getRayleigMultiplier(vec2 p, vec2 lp, float y){
                float disk = max(1.0 - distance(p, lp), 0.0);
                
                return disk*disk*(3.0 - 2.0 * disk);
            }

            float getMie(vec2 p, vec2 lp){
                float disk = clamp(1.0 - pow(distance(p, lp), 0.1), 0.0, 1.0);
                      disk *= disk*(3.0 - 2.0 * disk);
                
                return disk*disk * 32.0;
            }

            vec3 getAtmosphericScattering(vec2 p, vec2 lp){
                vec2 correctedLp = lp / max(_Resolution.x, _Resolution.y) * _Resolution;
                    
                float zenith = 1.0  / sqrt(p.y) - 0.7;
                float sunPointDistMult = clamp(distance(lp.y, 0.0), 0.0, 1.0);
                
                float rayleighMult = getRayleigMultiplier(p, correctedLp, zenith);
                
                vec3 absorption = getSkyAbsoption(_TotalRaylen, zenith);
                vec3 sky = _TotalRaylen * zenith * (1.0 + rayleighMult);
                vec3 sun = getSunPoint(p, correctedLp) * absorption;
                vec3 mie = getMie(p, correctedLp) * absorption * zenith;
                
                vec3 totalSky = lerp(sky * absorption, sky / (sky + 0.5), sunPointDistMult);
                
                    totalSky += sun + mie;
                
                totalSky *= smoothstep(-0.1, 0.3, sunPointDistMult);
                
                return totalSky;
            }

            vec3 getScatterColor(float dist){ 
                vec3 color = vec3(0.03, 0.06, 0.1) * dist;
                return max(pow(color, 1.-color), 0.0);
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
				vec2 position = input.uv.xy / max(_Resolution.x, _Resolution.y) * 2.0;
                vec2 lightPosition = _Mouse * 2.0;
                
                vec3 color = getAtmosphericScattering(position, lightPosition) * 4.0;
                color /= color + 1.0;
                return vec4(color*color, 1.0 );

                //另外一个很好看的天空渐变
                //position = ( input.uv.xy / _Resolution.y); 
                //return vec4(getScatterColor(3.14 / position.y), 1.0 );
			}
			ENDCG
		}
	}
}
