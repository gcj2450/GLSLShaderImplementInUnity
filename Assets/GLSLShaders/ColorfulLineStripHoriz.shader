//http://glslsandbox.com/e#38167.0
Shader "Unlit/ColorfulLineStripHoriz"
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

            #define PI 3.14159


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
				vec2 p = ( input.uv.xy / _Resolution.xy ) - 0.5;
                float sx = 0.1* (p.x + 0.6) * sin( 200.0 * p.y - 10. * time);
                float dy = 4./ ( 100. * abs(p.y - sx));
                dy += (vec2(p.x , 0.)*0.6/(30. * length(p + vec2(p.x, 0.)))).y;
                sx += (vec2(p.y , 0.)*0.1*( p.x + 0.9)*dy).x;
                return vec4( (p.x + 0.1) * dy, 0.1 * dy, dy, 8. );

			}
			ENDCG
		}
	}
}
