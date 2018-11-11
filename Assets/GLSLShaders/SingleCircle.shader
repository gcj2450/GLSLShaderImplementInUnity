//http://glslsandbox.com/e#29236.0
Shader "Unlit/SingleCircle"
{
	Properties
	{
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

            uniform vec2 _Resolution;
            uniform vec2 _Mouse;

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
                
				vec2 p = (input.uv.xy * 2.0 - _Resolution) / min(_Resolution.x, _Resolution.y);
                vec3 destColor = vec3(0.0, 0.0,0.0);

                //一个白色圆
                destColor += 0.01 / abs(length(p) - 0.8);

                // 另外一个白色圆
                //float t = 0.01* time/ 10.0 / abs(0.5 - length(p));
                //destColor+=vec3(t,t,t);

                //多个同心圆
                //destColor += sin(length(p*50));

                return vec4(destColor, 1.0);

                //一条斜线
               //float clVal = 0.01/distance(input.uv.x,input.uv.y) * sin(input.uv.x) * sin(input.uv.y);
                //return vec4(clVal,clVal,clVal,1);
			}
			ENDCG
		}
	}
}
