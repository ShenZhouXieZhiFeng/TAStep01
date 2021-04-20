Shader "cap09/Shadow"
{
    Properties
    {
        _Diffuse ("Diffuse Color", Color) = (1,1,1,1)
        _Specular ("_Specular Color", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
        _Atten ("Attne", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM

            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            float _Atten;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNorml : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNorml = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNorml = normalize(i.worldNorml);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNorml, worldLightDir));

                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                float3 halfDir = normalize(viewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNorml, halfDir)), _Gloss);

                fixed shadow = SHADOW_ATTENUATION(i);

                return fixed4(ambient + (diffuse + specular) * _Atten * shadow, 1.0);
            }
            ENDCG
        }

        // Pass
        // {
        //     Tags { "LightMode"="ForwardAdd" }

        //     Blend One One

        //     CGPROGRAM

        //     #pragma multi_compile_fwdadd

        //     #pragma vertex vert
        //     #pragma fragment frag

        //     #include "Lighting.cginc"
        //     #include "AutoLight.cginc"

        //     fixed4 _Diffuse;
        //     fixed4 _Specular;
        //     float _Gloss;
        //     float _Atten;

        //     struct a2v
        //     {
        //         float4 vertex : POSITION;
        //         fixed3 normal : NORMAL;
        //     };

        //     struct v2f
        //     {
        //         float4 vertex : SV_POSITION;
        //         fixed3 worldNorml : TEXCOORD0;
        //         fixed3 worldPos : TEXCOORD1;
        //     };

        //     v2f vert (a2v v)
        //     {
        //         v2f o;
        //         o.vertex = UnityObjectToClipPos(v.vertex);
        //         o.worldNorml = UnityObjectToWorldNormal(v.normal);
        //         o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        //         return o;
        //     }

        //     fixed4 frag (v2f i) : SV_Target
        //     {
        //         fixed3 worldNorml = normalize(i.worldNorml);
        //         #ifdef USING_DIRECTIONAL_LIGHT
        //             fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
        //         #else
        //             fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
        //         #endif

        //          fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
        //         fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNorml, worldLightDir));

        //         float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
        //         float3 halfDir = normalize(viewDir + worldLightDir);
        //         fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNorml, halfDir)), _Gloss);

        //         #ifdef USING_DIRECTIONAL_LIGHT
        //             fixed3 atten = _Atten;
        //         #else
        //             float3 lightCoord = mul(unity_WorldToLight, i.worldPos).xyz;
        //             fixed3 atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
        //         #endif

        //         return fixed4(ambient + (diffuse + specular) * atten, 1.0);
        //     }

        //     ENDCG
        // }
    }
    FallBack "VertexLit"
}
