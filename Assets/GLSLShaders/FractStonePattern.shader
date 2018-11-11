//http://glslsandbox.com/e#29623.0
Shader "Unlit/FractStonePattern"
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
            #define mix lerp

            uniform vec2 _Mouse;
            uniform vec2 _Resolution;

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
				vec2 p = input.uv.xy / _Resolution.xy;
                vec4 dmin = vec4(1000,1000,1000,1000);
                vec2 z = (-1.0 + 2.0*p)*vec2(1.7,1.0);
                for( int i=0; i<64; i++ ){
                    z = (_Mouse-vec2(0.5,0.5))*1.6+vec2(z.x*z.x-z.y*z.y,2.0*z.x*z.y);
                    dmin=min(dmin,vec4(abs(0.0+z.y+0.5*sin(z.x)),abs(1.0+z.x+0.5*sin(z.y)),dot(z,z),length(fract(z)-0.5)));}    
                vec3 color = vec3( dmin.w,dmin.w,dmin.w );

                //改为vec3(1.00,0.80,0.60)也很好看
                color = mix( color, vec3(1.00,0.80,0.0),     min(1.0,pow(dmin.x*0.25,0.20)));   
                color = mix( color, vec3(0.72,0.70,0.60),     min(1.0,pow(dmin.y*0.50,0.50)));
                color = mix( color, vec3(1.00,1.00,1.00), 1.0-min(1.0,pow(dmin.z*1.00,0.15)));
                color = 1.25*color*color;
                return vec4(color*(0.5 + 0.5*pow(16.0*p.x*(1.0-p.x)*p.y*(1.0-p.y),0.15)),1.0);
			}
			ENDCG
		}
	}
}
