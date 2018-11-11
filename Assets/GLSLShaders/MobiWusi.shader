//http://glslsandbox.com/e#49893.0
Shader "Unlit/MobiWusi"
{
	Properties
	{
        _Resolution ("Resolution", Vector) = (1,1,0,1)
        _Scale("Scale",float)=1
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
            float _Scale;

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
				float t;
                t = time * 1.0;
                vec2 r = _Resolution,
                o = i.uv.xy - r/_Scale;
                o = vec2(length(o) / r.y - .3, atan2(o.y,o.x));    
                vec4 s = 0.07*cos(1.5*vec4(0,1,2,3) + t + o.y + sin(o.y) * cos(t)),
                e = s.yzwx, 
                f = max(o.x-s,e-o.x);

                return  dot(clamp(f*r.y,0.,1.), 72.*(s-e)) * (s-.1) + f;
			}
			ENDCG
		}
	}
}
