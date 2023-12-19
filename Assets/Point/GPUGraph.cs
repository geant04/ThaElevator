using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GPUGraph : MonoBehaviour
{
    const int maxResolution = 30;

    [SerializeField, Range (10,maxResolution)]
    int resolution = 30;

    [SerializeField]
    FunctionLibrary.FunctionName function;

    ComputeBuffer positionsBuffer;

    [SerializeField]
    ComputeShader computeShader;

    // make the GPU draw the stuff
    [SerializeField]
    Material material;

    [SerializeField]
    Mesh mesh;

    static readonly int positionsId = Shader.PropertyToID("_Positions"),
         resolutionId = Shader.PropertyToID("_Resolution"),
         stepId = Shader.PropertyToID("_Step"),
         timeId = Shader.PropertyToID("_Time");
    
    void Awake() {
        positionsBuffer = new ComputeBuffer(maxResolution * maxResolution, 3 * 4);
    }

    void OnEnable() {
        positionsBuffer = new ComputeBuffer(maxResolution * maxResolution, 3 * 4);
    }

    void OnDisable() {
        positionsBuffer.Release();
        positionsBuffer = null;
    }

    void Update() {
        UpdateFunctionOnGPU();
    }

    void UpdateFunctionOnGPU() {
        float step = 2f / resolution;
        computeShader.SetInt(resolutionId, resolution);
        computeShader.SetFloat(stepId, step);
        computeShader.SetFloat(timeId, Time.time);

        var kernelIndex = (int)function;
        computeShader.SetBuffer(kernelIndex, positionsId, positionsBuffer);
 
        int groups = Mathf.CeilToInt(resolution / 8f);
        computeShader.Dispatch(kernelIndex, groups, groups, 1);
        
        material.SetBuffer(positionsId, positionsBuffer);
        material.SetFloat(stepId, step);

        var bounds = new Bounds(Vector3.zero, Vector3.one * (2f + 2f / resolution));
        Graphics.DrawMeshInstancedProcedural(
            mesh, 0, material, bounds, maxResolution * maxResolution
        );
    }
}
    
