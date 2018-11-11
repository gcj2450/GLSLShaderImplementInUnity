//http://glslsandbox.com/e#42669.0
Shader "Unlit/ColorfulLineStrip"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Intensity("Intensity",float)=1
        _Speed("_Speed",float)=0.03
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

            uniform float2 _Resolution;
            float _Intensity;
            float _Speed;

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
				vec2 uPos = ( input.uv.xy / _Resolution.xy );//normalize wrt y axis
                uPos -= .5;
                vec3 color = vec3(0,0,0);
                for( float i = 0.; i < 7.; ++i ) {
                    uPos.y += sin( uPos.x*(i) + (time * i * i * _Speed) ) * 0.15;
                    float lineWidth = abs(1.0 / uPos.y)*_Intensity;
                    color += vec3( lineWidth*(7.0-i)/7.0, lineWidth*i/10.0, pow(lineWidth,0.9)*1.5 );
                }

                return vec4(color, 1.0);
			}
			ENDCG
		}
	}
}
