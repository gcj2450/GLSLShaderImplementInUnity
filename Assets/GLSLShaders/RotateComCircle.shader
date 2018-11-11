//http://glslsandbox.com/e#41935.0
Shader "Unlit/RotateComCircle"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
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

            uniform vec2 _Resolution;

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
			
			fixed4 frag (v2f input) : SV_Target
			{
				vec2 position = ( input.uv.xy * 2.0 -  _Resolution) / min(_Resolution.x, _Resolution.y);
                vec3 destColor = vec3(1.0, 0.0, 1.5 );
                float f = 0.05;
                
                for(float i = 0.5; i < 70.0; i++){
                    
                    float s = sin(time + i ) ;
                    float c = cos(time + i );
                    f += 0.007 / abs(length(5.0* position *f - vec2(c, s)) -0.4);
                }

                return vec4(vec3(destColor * f), 4.0);
			}
			ENDCG
		}
	}
}
