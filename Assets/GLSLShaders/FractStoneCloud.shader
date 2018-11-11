//http://glslsandbox.com/e#29436.2
Shader "Unlit/FractStoneCloud"
{
	Properties
	{
        _Resolution ("Resolution", Vector) = (1,1,0,1)
        _MaxInte("MaxInte",float)=3
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

            uniform vec2 _Resolution;
            float _MaxInte;
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
			
			fixed4 frag (v2f input) : SV_Target
			{
				float r=1.,g=1.,b=1.;
    
                vec2 c = input.uv+_Resolution;
                c = c*_Scale;
                c *= 0.1;
                c += vec2(-.9,.3);
                vec2 z = vec2(0,0);
                
                float I = 0.;
                
                for(int i=1; i<_MaxInte; i++)
                {
                    z = vec2(pow(z.x, 2.)-pow(z.y, 2.),z.x*z.y*2.)+c;
                    if(length(z)>32.)
                    {
                        //float zn = z.x*z.x+z.y*z.y;
                        float zn=length(z);
                        I=float(i);
                        I=fmod(sqrt(I+1.0-log2(log2(zn)))*.15,1.0);
                        break;
                    }
                }
                
                if(I>0.)
                {
                    float roff=0.95; float goff=0.9; float boff=0.1;
                    //float rexp=1.8; float gexp=0.9; float bexp=0.7;
                    float rexp=2.7; float gexp=1.5; float bexp=2.;
                    
                    r = -4.*pow(pow(fmod(I+roff,1.),rexp)-0.5,2.)+1.;
                    g = -4.*pow(pow(fmod(I+goff,1.),gexp)-0.5,2.)+1.;
                    b = -4.*pow(pow(fmod(I+boff,1.),bexp)-0.5,2.)+1.;
                    
                    r = pow(r,0.8);
                    g = pow(g,0.6);
                    b = pow(b,0.2);
                }
                
                return vec4( r, g, b, 1 );

			}
			ENDCG
		}
	}
}
