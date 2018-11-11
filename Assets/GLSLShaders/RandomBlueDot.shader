//http://glslsandbox.com/e#45014.0
Shader "Unlit/RandomBlueDot"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _FRadius("FRadius",float)=0.05
        _Bubles("Bubles",float)=64
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

            uniform vec2 _Resolution;

             float _FRadius = 0.05;
             int _Bubles = 64;

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

                vec2 uv = -1.0 + 2.0*input.uv.xy / _Resolution.xy;
                uv.x *=  _Resolution.x / _Resolution.y;
                
                vec3 color = vec3(0,0,0);

                // bubbles
                for (int i=0; i < _Bubles; i++ ) {
                        // bubble seeds
                    float pha = tan(float(i)*6.+1.0)*0.5 + 0.5;
                    float siz = pow( cos(float(i)*2.4+5.0)*0.5 + 0.5, 4.0 );
                    float pox = cos(float(i)*3.55+4.1) * _Resolution.x / _Resolution.y;
                    
                        // buble size, position and color
                    float rad = _FRadius + sin(float(i))*0.12+0.08;
                    vec2  pos = vec2( pox+sin(time/15.+pha+siz), -1.0-rad + (2.0+2.0*rad)
                                     *fmod(pha+0.1*(time/5.)*(0.2+0.8*siz),1.0)) * vec2(1.0, 1.0);
                    float dis = length( uv - pos );
                    vec3  col = lerp( vec3(0.1, 0.2, 0.8), vec3(0.2,0.8,0.6), 0.5+0.5*sin(float(i)*sin(time*pox*0.03)+1.9));
                    
                        // render
                    color += col.xyz *(1.- smoothstep( rad*(0.65+0.20*sin(pox*time)), rad, dis )) * (1.0 - cos(pox*time));
                }

                return vec4(color,1.0);
			}
			ENDCG
		}
	}
}
