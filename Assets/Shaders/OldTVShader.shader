Shader "Custom/OldTVShader"
{
    Properties
    {
        // "Global variables"
        _MainTex ("Texture", 2D) = "white" {}
        _Static ("Static Texture", 2D) = "white" {}
        _Noise ("Noise Texture", 2D) = "white" {}
        _Amplitude ("Amplitude", float) = 1
        _Smoothness ("Smoothness", float) = 1
        _Line1Width ("Line 1 Width", float) = 0.1
        _Line1Speed ("Line 1 Speed", float) = 300
        _Line1Travel ("Line 1 Travel", float) = 1
        _Line1Darkness ("Line 1 Darkness", float) = 0.3
        _Line2Width ("Line 2 Width", float) = 0.2
        _Line2Speed ("Line 2 Speed", float) = 5
        _Line2Travel ("Line 2 Travel", float) = 4
        _Line2Darkness ("Line 2 Darkness", float) = 0.5
        _AspectRatio("Aspect Ratio X/Y", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
    
        // Pass for GPU, main code goes in here
        Pass
        {
            // HLSL code must go in here
            HLSLPROGRAM
            // Compile function vert as a vertex (polygon) shader
            #pragma vertex vert
            // Compile function frag as a fragment (pixel) shader 
            #pragma fragment frag
			
			#include "UnityCG.cginc"

            // Structure for data passed into the shader
            struct appdata
			{
                // Positions of the polygons in the scene
                float4 vertex : POSITION;
                // Positions of pixels on the game screen
                float2 uv : TEXCOORD0;
			};

            // Vertex to fragment structure, returned by v2f function
			struct v2f
			{
                // Positions of pixels on the game screen
				float2 uv : TEXCOORD0;
                // Converted polygon positions
                float4 vertex : SV_POSITION;
			};
            
            sampler2D _MainTex;
            sampler2D _Static;
            sampler2D _Noise;
            float _Amplitude;
            float _Smoothness;
            float _Line1Width;
            float _Line1Speed;
            float _Line1Travel;
            float _Line1Darkness;
            float _Line2Width;
            float _Line2Speed;
            float _Line2Travel;
            float _Line2Darkness;
            float _AspectRatio;

            // Vertex function, converts polygons to pixels
            v2f vert (appdata v)
            {
                v2f o;
                // Convert the vertices of the object to SV
                o.vertex = UnityObjectToClipPos(v.vertex);
                // Copy over the UV coordinates
                o.uv = v.uv;

                if (_AspectRatio > 1)
                {
                    o.uv.y /= _AspectRatio;
                }
                else
                {
                    o.uv.x *= _AspectRatio;
                }

                return o;
            }
            
            // Fragment funtion, converts pixels to colours
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 lum = Luminance(tex2D(_MainTex, i.uv));

                float random = tex2D(_Noise, _Time).r;
                float2 noiseCoords = i.uv.xy + random * 8;

                fixed4 col = lum * (1 - tex2D(_Static, noiseCoords * _Smoothness).r  * _Amplitude);

                float lineStart = (_Line1Speed * _Time) % _Line1Travel;
                float lineEnd = (_Line1Speed * _Time + _Line1Width) % _Line1Travel;

                if
                (
                    (
                        lineStart < lineEnd
                         && 
                        i.uv.y > lineStart && i.uv.y < lineEnd
                    ) 
                    ||
                    (
                        lineStart > lineEnd && 
                        (
                            i.uv.y > 0 && i.uv.y < lineEnd
                            ||
                            i.uv.y < _Line1Travel && i.uv.y > lineStart
                        )
                    )
                )
                {
                    return col * (1 - _Line1Darkness);
                }

                lineStart = (_Line2Speed * _Time) % _Line2Travel;
                lineEnd = (_Line2Speed * _Time + _Line2Width) % _Line2Travel;

                if
                (
                    (
                        lineStart < lineEnd
                         && 
                        i.uv.y > lineStart && i.uv.y < lineEnd
                    ) 
                    ||
                    (
                        lineStart > lineEnd && 
                        (
                            i.uv.y > 0 && i.uv.y < lineEnd
                            ||
                            i.uv.y < _Line2Travel && i.uv.y > lineStart
                        )
                    )
                )
                {
                    return col * (1 - _Line2Darkness);
                }

                return col;
            }
            ENDHLSL
        }
    }

    FallBack "Standard"
}
