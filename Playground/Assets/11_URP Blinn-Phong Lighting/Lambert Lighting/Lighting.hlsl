#ifndef OWLET_LIGHTING_INCLUDED
#define OWLET_LIGHTING_INCLUDED

void LightingLambert_float (float3 lightColor, float3 lightDir, float3 normal, out float3 diffuse)
{
    float NdotL = saturate(dot(normal, lightDir));
    diffuse = lightColor * NdotL;
}

void PhongSpecular_float(float specularStrength, float3 lightDir, float3 normal, float3 viewDir, 
    float smoothness, out float3 specular)
{
    float3 reflectDir = reflect(-normalize(lightDir), normal);
    float spec = pow(max(dot(normalize(viewDir), reflectDir), 0.0), 32);
    specular = specularStrength * spec;
}

void LightingSpecular_float(float3 lightColor, float3 lightDir, float3 normal, float3 viewDir, 
    float smoothness, out float3 specular)
{
    float3 halfVec = SafeNormalize(float3(lightDir) + SafeNormalize(viewDir));
    float NdotH = saturate(dot(normalize(normal), halfVec));
    float modifier = pow(NdotH, smoothness);
    specular = lightColor * modifier;
}

#endif
