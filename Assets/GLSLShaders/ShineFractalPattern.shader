//http://glslsandbox.com/e#24285.0
Shader "Unlit/ShineFractalPattern"
{
	Properties
	{
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Mouse ("Mouse", Vector) = (1,1,0,1)
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

            //by TommyX 
            // modded by lavergeduredu31

            uniform vec2 _Mouse;
            uniform vec2 _Resolution;
            uniform sampler2D _MainTex;
            float4 _MainTex_ST;

            vec2 center = vec2(0.5,0.5);
            #define ITER 100

            vec4 main( in vec2 gl_FragCoord ) {

                vec2 position = ( gl_FragCoord.xy / _Resolution.xy ) - 0.5 + (_Mouse-0.5) * 1.0;
                
                vec3 color = vec3(0,0,0);

                vec2 z, c;
                
                float scale = 0.1;
                
                float t = -0.56;
                
                c.x = t;
                c.y = t;
                
                z.x = 3.0 * position.x * scale;
                    z.y = 2.0 * position.y * scale;
                
                int j;
                for (int i = 0; i < ITER; i++) {
                    j = i;
                    float x = (z.x * z.x - z.y * z.y) + c.x;
                    float y = (z.y * z.x + z.x * z.y) + c.y;
                    
                    if((x * x + y * y) > 4.0) break;
                    z.x = x;
                    z.y = y;
                }
                
                vec2 bbpos;
                bbpos = gl_FragCoord.xy / _Resolution.xy;
                float decayx = (0.5-(abs(bbpos.x-0.5)+abs(bbpos.y-0.5)))*0.1+0.95;
                float decay = 0.4;
                vec2 rayCenter = vec2(.5+.25*cos(time), .5+.25*sin(time));
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.98).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.96).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.94).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.93).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.92).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.91).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.90).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.89).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.88).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.87).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.86).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.85).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.84).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.83).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.82).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.81).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.80).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.79).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.78).rgb*decay*decayx;
                color += tex2D(_MainTex, rayCenter + (bbpos-rayCenter)*0.77).rgb*decay*decayx;
                color *= 0.05;
                color.r *= 0.89;
                color.g *= 0.93;
                
                color += (j == ITER ? 0.0 : float(j)) / (1.0*float(ITER));
                
                return vec4(color,1.0);
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
			
			fixed4 frag (v2f i) : SV_Target
			{
				return main(i.uv);
			}
			ENDCG
		}
	}
}
