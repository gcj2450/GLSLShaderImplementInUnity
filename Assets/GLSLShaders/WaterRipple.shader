//http://glslsandbox.com/e#19279.8
Shader "Unlit/WaterRipple"
{
	Properties
	{
		_Resolution ("Resolution", Vector) = (1,1,0,1)
        _Zoom("Zoom",float)=0.1
        _VesselLength("VesselLength",float) = 20.0
        _VesselDraught("VesselDraught",float) = 10.7
        _VesselVelocity("VesselVelocity",Vector) = (0.0, 9.0,0,0)
        _BoatPos("BoatPos",Vector)=(0.5, 1.0,0,0)
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

            #define PI 3.14159265359
            #define GravityAcceleration 9.81

            uniform vec2 _Resolution;
            float _Zoom;
            float _VesselLength;
            float _VesselDraught;
            vec2 _VesselVelocity;
            vec2 _BoatPos;


            float evaluate(float c, float l, float t, float xcord, float ycord, float ang)
            {
                float K, A, B, C, D, E, F, G, H, I, J;
                K = c / 96.2361; //k = c / g^2
                
                float cosAng = cos(ang);
                float sinAng = sin(ang);
                
                float lmt = PI/2.0 - 0.25;
                ang = clamp(ang, -lmt, lmt);
                
                float tanAng = tan(ang);

                A = (c*c)/(GravityAcceleration*l); // = c^2/gl
                B = K*(1.0+(tanAng*tanAng)*(xcord*cosAng+ycord*sinAng)) - time * 0.0; // = (x,y)
                C = K*(1.0+(tanAng*tanAng)*((xcord+l)*cosAng+ycord*sinAng)); // = ((x+l),y)
                D = (1.0-exp(-K*t*(1.0+(tanAng*tanAng)))); // = 1-e(-k.t.sec^2(ang)
                E = A*D*sin(B); // = A.D.sin(B)
                F = -4.0*A*A*D*cosAng*cos(B); // = -4.(A^2).D.cos(ang).cos(B)
                G = -6.0*A*A*A*D*(cosAng*cosAng)*sin(B); // -6.(A^3).D.cos^2(ang).sin(B)
                H = -2.0*A*A*D*cosAng*cos(C); // -2.(A^2).D.cos(ang).cos(C)
                I = 6.0*A*A*A*D*(cosAng*cosAng)*sin(C); // +6.(A^3).D.cos^2(ang).sin(C
                J = E+F+G+H+I;

                return J;
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
			
			fixed4 frag (v2f input) : SV_Target
			{
				
                float _VesselSpeed = length(_VesselVelocity);
                
                float t = input.uv.y / _Resolution.y;    
                
                vec2 position = ( input.uv.xy ) * _Zoom;
                vec2 boatPos = _BoatPos* _Resolution.xy * _Zoom;
                vec2 relPos = abs(boatPos - position);
                
                float angle = atan(relPos.y/relPos.x);
                
                float waveHeight = evaluate( _VesselSpeed, _VesselLength, _VesselDraught, relPos.x, relPos.y, angle ) * t * t * 0.5 + 0.5;
                return vec4( waveHeight, waveHeight, waveHeight, 1.0 );
			}
			ENDCG
		}
	}
}
