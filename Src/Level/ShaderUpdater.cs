using System;
using Godot;

public partial class ShaderUpdater : Node3D
{
    private ShaderMaterial material;
    [Export] Node3D cubeNode;
    [Export] MeshInstance3D meshNode;
    [Export] public int dissolveSeed = 0;
    [Export] public int hueSeed = 0;

    public override void _Ready()
    {
        material = (ShaderMaterial)meshNode.GetSurfaceOverrideMaterial(0);

        if (dissolveSeed != 0)
        {
            dissolveSeed = new Random().Next();
        }
        if (hueSeed != 0)
        {
            hueSeed = new Random().Next();
        }

        CreateNoiseTextures();
    }

    private void CreateNoiseTextures()
    {
        // Tekstura dissolve noise
        var dissolveNoise = new FastNoiseLite();
        dissolveNoise.Seed = dissolveSeed;
        dissolveNoise.Frequency = 0.1f;
        dissolveNoise.NoiseType = FastNoiseLite.NoiseTypeEnum.Simplex;

        var dissolveNoiseTexture3D = new NoiseTexture3D();
        dissolveNoiseTexture3D.Noise = dissolveNoise;
        dissolveNoiseTexture3D.Width = 64;
        dissolveNoiseTexture3D.Height = 64;
        dissolveNoiseTexture3D.Depth = 64;

        // Tekstura hue noise
        var hueNoise = new FastNoiseLite();
        hueNoise.Seed = hueSeed;
        hueNoise.Frequency = 0.05f;
        hueNoise.NoiseType = FastNoiseLite.NoiseTypeEnum.Perlin;

        var hueNoiseTexture3D = new NoiseTexture3D();
        hueNoiseTexture3D.Noise = hueNoise;
        hueNoiseTexture3D.Width = 32;
        hueNoiseTexture3D.Height = 32;
        hueNoiseTexture3D.Depth = 32;

        material.SetShaderParameter("dissolve_noise_texture", dissolveNoiseTexture3D);
        material.SetShaderParameter("hue_noise_texture", hueNoiseTexture3D);
    }

    public override void _Process(double delta)
    {
        material.SetShaderParameter("cube_position", cubeNode.GlobalPosition);
    }
}