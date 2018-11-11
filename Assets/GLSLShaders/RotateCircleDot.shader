//http://glslsandbox.com/e#29704.1
Shader "Unlit/RotateCircleDot"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Brightness("Brightness",float)=5
        _RotSpeed("RotSpeed",float)=5
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
            float _Brightness;
            float _RotSpeed;

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
				vec2 p = ( input.uv.xy / _Resolution.xy );
                p = p*2.0-1.0;
                p.x *= _Resolution.x/_Resolution.y;
                
                float t = time*_RotSpeed;
                
                vec3 col;
                for(int i=0; i<16; i++){
                  float a = float(i)/16.0 * 3.141592 * 2.0;
                  float len=length(p+ vec2(cos(t+a)*0.2, sin(t+a)*0.2) );
                  col += 1.0 / vec3(len,len,len)*0.02;
                }
                col *= fract(_Brightness);
                    
                return vec4( col, 1.0 );
			}
			ENDCG
		}
	}
}
