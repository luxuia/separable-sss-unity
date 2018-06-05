using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class SubsurfaceScatterPostProcess : MonoBehaviour {
    [Range(0, 3)]
    public float Scaler = 0.1f;
    public Color MainColor;
    public Color Falloff;

    Camera renderCamera;
    CommandBuffer buffer;
    Material material;
    List<Vector4> KernelArray = new List<Vector4>();

    static int SceneColorID = Shader.PropertyToID("_SceneColor");
    static int Kernel = Shader.PropertyToID("_Kernel");
    static int SSSScaler = Shader.PropertyToID("_SSSScale");

	void OnEnable() {
        renderCamera = GetComponent<Camera>();
        material = new Material(Shader.Find("PostProcess/SeparableSubsurfaceScatter"));

        buffer = new CommandBuffer();
        buffer.name = "Separable Subsurface Scatter";
        renderCamera.clearStencilAfterLightingPass = true;
        renderCamera.AddCommandBuffer(CameraEvent.AfterForwardOpaque, buffer);
    }

    void  OnDisable() {
        ClearBuffer();
    }

    void OnPreRender() {
        UpdateSubsurface();
    }

    //流程参考 https://github.com/iryoku/separable-sss 
    //和 https://github.com/haolange/UnityCharacterRender_SeparableSubsurfaceScatter
    void UpdateSubsurface() {
        Vector3 SSSC = Vector3.Normalize(new Vector3(MainColor.r, MainColor.g, MainColor.b));
        Vector3 SSSFC = Vector3.Normalize(new Vector3(Falloff.r, Falloff.g, Falloff.b));
        KernelCalculate.CalculateKernel(KernelArray, 25, SSSC, SSSFC);
        material.SetVectorArray(Kernel, KernelArray);
        material.SetFloat(SSSScaler, Scaler);

        buffer.Clear();
        buffer.GetTemporaryRT(SceneColorID, renderCamera.pixelWidth, renderCamera.pixelHeight, 0, FilterMode.Trilinear, RenderTextureFormat.DefaultHDR);
        buffer.BlitStencil(BuiltinRenderTextureType.CameraTarget, SceneColorID, BuiltinRenderTextureType.CameraTarget, material, 0);
        buffer.BlitSRT(SceneColorID, BuiltinRenderTextureType.CameraTarget, material, 1);
    }

    void ClearBuffer() {
        buffer.ReleaseTemporaryRT(SceneColorID);
        renderCamera.RemoveCommandBuffer(CameraEvent.AfterForwardOpaque, buffer);
        buffer.Release();
        buffer.Dispose();
    }
}
