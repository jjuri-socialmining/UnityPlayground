#ifndef OWLET_LIGHTING_INCLUDED
#define OWLET_LIGHTING_INCLUDED

////////////////////////////////////////
// 获取主光源参数
////////////////////////////////////////
void MainLight_float(float3 WorldPos, out float3 Direction, out float3 Color, out float DistanceAtten, out float ShadowAtten)
{
#if defined(SHADERGRAPH_PREVIEW)
    Direction = float3(0.5, 0.5, 0);
    Color = float3(1, 1, 1);
    ShadowAtten = 1;
    DistanceAtten = 1;
#else
    // TransformWorldToShadowCoord 定义在Shadows.hlsl文件内
    // 需要开启 _MAIN_LIGHT_SHADOWS_CASCADE
    // float4 TransformWorldToShadowCoord(float3 positionWS)
    // {
    //     #ifdef _MAIN_LIGHT_SHADOWS_CASCADE
    //     half cascadeIndex = ComputeCascadeIndex(positionWS);
    //     #else
    //     half cascadeIndex = 0;
    //     #endif

    //     float4 shadowCoord = mul(_MainLightWorldToShadow[cascadeIndex], float4(positionWS, 1.0));

    //     return float4(shadowCoord.xyz, cascadeIndex);
    // }
    float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);

    // GetMainLight 定义在Lighting.hlsh文件内
    // MainLightRealtimeShadow用来计算光照衰减
    // 需要开启 _MAIN_LIGHT_SHADOWS
    // Light GetMainLight(float4 shadowCoord)
    // {
    //     Light light = GetMainLight();
    //     light.shadowAttenuation = MainLightRealtimeShadow(shadowCoord);
    //     return light;
    // }
    Light mainLight = GetMainLight(shadowCoord);
    // 返回光源方向
    Direction = mainLight.direction;
    // 返回光源颜色
    Color = mainLight.color;
    // 阴影衰减
    ShadowAtten = mainLight.shadowAttenuation;
    // 距离衰减
    DistanceAtten = mainLight.distanceAttenuation;
#endif
}
////////////////////////////////////////
// 兰伯特光照
////////////////////////////////////////
void LightingLambert_float (float3 lightColor, float3 lightDir, float3 normal, out float3 diffuse)
{
    float NdotL = saturate(dot(normal, lightDir));
    diffuse = lightColor * NdotL;
}

////////////////////////////////////////
// 冯氏高光计算
////////////////////////////////////////
void PhongSpecular_float(float3 specularColor, float3 lightDir, float3 normal, float3 viewDir, 
    float smoothness, out float3 specular)
{
    float3 reflectDir = reflect(-normalize(lightDir), normal);
    float spec = pow(max(dot(normalize(viewDir), reflectDir), 0.0), smoothness);
    specular = specularColor * spec;
}

////////////////////////////////////////
// 布林冯氏高光计算
////////////////////////////////////////
void LightingSpecular_float(float3 lightColor, float3 lightDir, float3 normal, float3 viewDir, 
    float smoothness, out float3 specular)
{
    smoothness = exp2(10 * smoothness + 1);
    normal = normalize(normal);
    viewDir = SafeNormalize(viewDir);

    float3 halfVec = SafeNormalize(float3(lightDir) + float3(viewDir));
    half NdotH = saturate(dot(normal, halfVec));
    half modifier = pow(NdotH, smoothness);
    specular = lightColor * modifier;
}

#endif
