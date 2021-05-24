Shader "cap10/ShdaerRefraction"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _RefractColor ("Refraction Color", Color) = (1,1,1,1)
        _RefractAmount ("Recraction Amount", Range(0, 1)) = 1
        _RefractRatio ("Refraction Ratio", Range(0.1, 1)) = 0.5
        _CubeMap ("Refraction CubeMap", Cube) = "_Skybox" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldViewDir : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 worldRefr : TEXCOORD3;
            };

            float4 _Color;
            float4 _RefractColor;
            float _RefractAmount;
            float _RefractRatio;
            samplerCUBE _CubeMap;

            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

                // 计算折射方向
                o.worldRefr = refract(-normalize(o.worldViewDir), normalize(o.worldNormal), _RefractRatio);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 diffuse = _LightColor0.xyz * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

                fixed3 refraction = texCUBE(_CubeMap, i.worldRefr).rgb * _RefractColor.rgb;

                fixed3 color = ambient + lerp(diffuse , refraction, _RefractAmount);

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
