// MIT License
//Sources:
// https://github.com/stackgl/glsl-camera-ray
// https://github.com/hughsk/glsl-square-frame
// https://github.com/stackgl/glsl-smooth-min
//http://glslsandbox.com/e#42085.0
Shader "Unlit/InfiniteHill"
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
            
            #ifdef GL_ES
            precision mediump float;
            #endif

            uniform vec2 _Mouse;
            uniform vec2 _Resolution;

            vec2 square(vec2 screenSize, vec2 coord) {
              vec2 position = 2.0 * (coord.xy / screenSize.xy) - 1.0;
              position.x *= screenSize.x / screenSize.y;
              return position;
            }
            float smin(float a, float b, float k) {
              float res = exp(-k * a) + exp(-k * b);
              return -log(res) / k;
            }
            float3x3 calcLookAtMatrix(vec3 origin, vec3 target, float roll) {
              vec3 rr = vec3(sin(roll), cos(roll), 0.0);
              vec3 ww = normalize(target - origin);
              vec3 uu = normalize(cross(ww, rr));
              vec3 vv = normalize(cross(uu, ww));

              return float3x3(uu, vv, ww);
            }
            float3 camera(float3x3 camMat, vec2 screenPos, float lensLength) {
              return normalize(mul(camMat , vec3(screenPos, lensLength)));
            }

            vec3 camera(vec3 origin, vec3 target, vec2 screenPos, float lensLength) {
              float3x3 camMat = calcLookAtMatrix(origin, target, 0.0);
              return camera(camMat, screenPos, lensLength);
            }

            float doModel(vec3 p) {
              //float sphere = length(p - vec3(0, sin(iGlobalTime) + 0.6, 0)) - 1.0;
              //float ground = p.y - 0.0;
              //return smin(sphere, ground, 1.0);
                float value = 1e8;
                
                #define doModel_sphere(radius, height) (length(p - vec3(0, height, 0)) - radius)
                float sphere;
                
                float ground = p.y - 0.0;
                
                sphere = doModel_sphere(.2, 1.);
                value = smin(value, sphere, 1.0);
                
                p.xz -= 10.*_Mouse.x*sign(p.xz);
                p *= 2.;
                sphere = doModel_sphere(.2, 1.);
                value = smin(value, sphere, 1.0);
                
                p.xz -= 10.*_Mouse.x*sign(p.xz);
                p *= 2.;
                sphere = doModel_sphere(.2, 1.);
                value = smin(value, sphere, 1.0);
                
                p.xz -= 10.*_Mouse.x*sign(p.xz);
                p *= 2.;
                sphere = doModel_sphere(.2, 1.);
                value = smin(value, sphere, 1.0);
                
                p.xz -= 10.*_Mouse.x*sign(p.xz);
                p *= 2.;
                sphere = doModel_sphere(.2, 1.);
                value = smin(value, sphere, 1.0);
                
                p.xz -= 10.*_Mouse.x*sign(p.xz);
                p *= 2.;
                sphere = doModel_sphere(.2, 1.);
                value = smin(value, sphere, 1.0);
                
                
                value = smin(value, ground, 1.0);
                
                
                return value;
            }

            vec3 doMaterial(vec3 pos, vec3 nor) {
              return vec3(0.4+sqrt(pos.y+2.)*pos.y*0.25, 0.768+pos.y*pos.y*0.1, 1.0) * 0.5;
            }

            vec3 doLighting(vec3 pos, vec3 nor, vec3 rd, float dis, vec3 mal) {
              vec3 lin = vec3(0,0,0);

              vec3  lig = normalize(vec3(1.0,0.7,0.9));
              float dif = max(dot(nor,lig),0.0);

              lin += dif*vec3(4.00,4.00,4.00);
              lin += vec3(0.50,0.50,0.50);

              vec3 col = mal*lin;

              col *= exp(-0.04*dis*dis);

              return col;
            }

            float calcIntersection(vec3 ro, vec3 rd) {
              const float maxd = 15.0;
              const float precis = 0.01;
              float h = precis*2.0;
              float t = 0.0;
              float res = -1.0;
              for (int i=0; i<30; i++) {
                if (h < precis || t > maxd) break;
                h = doModel(ro+rd*t);
                t += h;
              }

              if (t < maxd) res = t;
              return res;
            }

            vec3 calcNormal(vec3 pos) {
              const float eps = 0.02;

              const vec3 v1 = vec3( 1.0,-1.0,-1.0);
              const vec3 v2 = vec3(-1.0,-1.0, 1.0);
              const vec3 v3 = vec3(-1.0, 1.0,-1.0);
              const vec3 v4 = vec3( 1.0, 1.0, 1.0);

              return normalize( v1*doModel( pos + v1*eps ) +
                                v2*doModel( pos + v2*eps ) +
                                v3*doModel( pos + v3*eps ) +
                                v4*doModel( pos + v4*eps ) );
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
			
			fixed4 frag (v2f input) : SV_Target
			{
				float cameraAngle  = 0.8 * _Resolution;
              vec3  rayOrigin    = vec3(3.5 * sin(cameraAngle), 3.0, 3.5 * cos(cameraAngle));
              vec3  rayTarget    = vec3(0, 0, 0);
              vec2  screenPos    = square(_Resolution,input.uv);
              vec3  rayDirection = camera(rayOrigin, rayTarget, screenPos, 2.0);

              vec3  col = vec3(0,0,0);
              float t   = calcIntersection(rayOrigin, rayDirection);

              if (t > -0.5) {
                vec3 pos = rayOrigin + t*rayDirection;
                vec3 nor = calcNormal(pos);
                vec3 mal = doMaterial(pos, nor);

                col = doLighting(pos, nor, rayDirection, t, mal);
              }

              col = pow(clamp(col,0.0,1.0), vec3(0.4545,0.4545,0.4545));

              return vec4( col, 1.0 );
			}
			ENDCG
		}
	}
}
