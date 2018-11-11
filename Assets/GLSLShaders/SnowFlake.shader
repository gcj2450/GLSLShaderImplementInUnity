Shader "Unlit/SnowFlake"
{
	Properties
	{
        _Resolution ("Resolution", Vector) = (0,1,0,1)
		_Mouse ("Mouse", Vector) = (0,1,0,1)
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

            // DOF Snowfield!
            // Mouse X controls focal depth

            uniform vec4 _Mouse;
            uniform vec4 _Resolution;

            vec3 snowflake(vec3 coords, vec2 pxPos) {
                float focalPlane = 0.5 + 2.5 * _Mouse.x;
                float iris = 0.01;
                
                float pxDiam = abs(coords.z - focalPlane) * iris;
                vec2 flakePos = vec2(coords.xy) / coords.z;
                float flakeDiam = 0.003 / coords.z;
                
                float dist = length(pxPos - flakePos);
                float bri = (pxDiam + flakeDiam - dist) / (pxDiam * 2.0);
                if (pxDiam > flakeDiam) {
                    bri /= (pxDiam / flakeDiam);
                }

                return vec3(0.7, 0.9, 1.0) * min(1.0, max(0.0, bri));
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
				vec2 pos = ( i.uv.xy / _Resolution.xy ) - 0.5;
                pos.y *= _Resolution.y / _Resolution.x;
                fixed4 gl_FragColor;
                gl_FragColor.rgb = vec3(0.04, 0.13, 0.19);
                for (int i=0; i<150; i++) {
                    vec3 c = vec3(0,0,0);
                    c.z = fract(sin(float(i) * 25.643) * 735.5373);
                    c.z *= 0.2 + fract(sin(float(i) * 74.753) * 526.5463);
                    c.z = 0.5 + (1.0 - c.z) * 2.4;
                    float gSize = 0.5 / c.z;
                    vec2 drift = vec2(0,0);
                    drift.x = fract(sin(float(i) * 52.3464) * 353.43354) * 4.0;
                    drift.x = drift.x + time * 0.06 + 4.0 * sin(time * 0.03 + c.z * 7.0);
                    drift.y = fract(sin(float(i) * 63.2356) * 644.53463) * 4.0;
                    drift.y = drift.y + time * -0.2;
                    drift /= c.z;

                    vec2 grid = vec2(modf((pos.x+drift.x)/c.z, gSize), modf((pos.y-drift.y)/c.z, gSize));
                    c.x = gSize*0.5;
                    c.y = gSize*0.5;
                    gl_FragColor.rgb += snowflake(c, grid);
                }
                gl_FragColor.a = 1.0;
                return gl_FragColor;
			}
			ENDCG
		}
	}
}
