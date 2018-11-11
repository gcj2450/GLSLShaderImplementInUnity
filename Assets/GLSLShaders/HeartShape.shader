//http://glslsandbox.com/e#47978.0

Shader "Unlit/HeartShape"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (0,1,0,1)
         _Color ("Color", Color) = (0.0,0.9,1.3)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100

		Pass
		{
            Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
            #define vec2 float2
            #define vec3 float3
            #define vec4 float4
            #define time _Time.g

            #ifdef GL_ES
            precision mediump float;
            #endif

            //#extension GL_OES_standard_derivatives : enable

            uniform vec4 _Resolution;
            uniform vec3 _Color;

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
				vec2 p = ( i.uv.xy * 2.0 - _Resolution) / min(_Resolution.x,_Resolution.y);
                
                float f = 0.0;
                float T = 3.0 * time;
                for ( float i = 0.0; i < 100.0; i++){
                    T += 0.0131415926;
                    float c = 16.*pow(sin(T), 3.);//sin(time*3.0 + i * 0.0031415926) * 0.8;
                    float s = 13.*cos(T) - 5.*cos(2.*T) - 2.*cos(3.*T) - cos(4.0*T);
                    c = 0.05*c; s = -0.05*s;
                    f += 0.0001/abs(length(p+vec2(c,s))-i/50000.)*(pow(i,2.0)/1000.0);
                    f += 0.0001/abs(length(p+vec2(-c,s))-i/50000.)*(pow(i,2.0)/1000.0);
                }
                //return _Color*f;  //使用这一句需要把上面的_Color类型改为float3
                return vec4(vec3(_Color*f),1.0); 
			}
			ENDCG
		}
	}
}
