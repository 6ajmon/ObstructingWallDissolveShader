using Godot;
using System;

public partial class CubeMovement : MeshInstance3D
{
    private float speed = 2.0f;
    private float amplitude = 2.0f;
    private float initialX;
    private float time = 0.0f;
    [Export] public bool move = true;
    public override void _Ready()
    {
        initialX = GlobalPosition.X;
    }
    public override void _Process(double delta)
    {
        if (!move) return;
        time += (float)delta;
        float newX = initialX + Mathf.Sin(time * speed) * amplitude;
        GlobalPosition = new Vector3(newX, GlobalPosition.Y, GlobalPosition.Z);
    }
}
