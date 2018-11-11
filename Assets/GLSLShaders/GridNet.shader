Shader "Unlit/GridNet"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Position("Position",float)=0
        _Scale("Scale",float)=0.5
        _Intensity("Intensity",float)=2.5
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
            // Tenjix

            #ifdef GL_ES
            precision mediump float;
            #endif

            #define PI 3.1415926

            uniform vec2 _Resolution;

            float _Position ;
            float _Scale;
            float _Intensity;

            float band(vec2 pos, float amplitude, float frequency) {
                float wave = _Scale * amplitude * sin(2.0 * PI * frequency * pos.x + time) / 2.05;
                float light = clamp(amplitude * frequency * 0.002, 0.001 + 0.001 / _Scale, 5.0) * _Scale / abs(wave - pos.y);
                return light;
            }

            void main( out vec4 fragColor, in vec2 fragCoord ) {

                vec3 color = vec3(0.0, 0.6, .8)*_Intensity;
                color = color == vec3(0,0,0)? vec3(0.5, 0.5, 1.0) : color;
                vec2 pos = (fragCoord.xy / _Resolution.xy);
                pos.y += - 0.5 - _Position;
                
                // +pk
                float spectrum = 0.05;
                const float lim = 104.;
                float timeM= time*0.032 + pos.x*1;
                for(float i = 0.; i < lim; i++){
                    spectrum += band(pos, 1.0*sin(timeM*0.1), 1.0*sin(timeM*i/lim))/lim;
                }
                
                //spectrum += band(pos, 0.7, 2.5);
                //spectrum += band(pos, 0.4, 2.0);
                //spectrum += band(pos, 0.05, 4.5);
                //spectrum += band(pos, 0.1, 7.0);
                //spectrum += band(pos, 0.1, 1.0);
                
                fragColor = vec4(color * spectrum, spectrum);
                
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
                vec4 fragColor;
				main( fragColor, input.uv);
                return fragColor;
			}
			ENDCG
		}
	}
}
