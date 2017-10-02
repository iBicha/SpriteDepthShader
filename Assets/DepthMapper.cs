using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
public class DepthMapper : MonoBehaviour {

	public ComputeShader depthMapperComputeShader;
	public Material depthMaterial;

	public Material previewMaterial;

	private RenderTexture depthMapOut;

	private int kernelIndex;

	private uint threadGroupSizeX;
	private uint threadGroupSizeY;
	private uint threadGroupSizeZ;

	private Texture depthMap;

	private Vector4 _RotationAngle;
	private Vector4 _RotationCenter;
	private Vector4 _FillColor;
	private float _Speed;
	private float _Animate;
	private float _ToggleAnimation;

	private bool IsDepthMapDirty = true;

	void Start() {
		Setup ();
	}


	int frameCount;
	void Update () {
		if(frameCount++ % 1 == 0){
			ReadMaterialParameters ();
		}
		//Graphics.Blit (depthMap, depthMapOut, depthMaterial,0);
	}

	private void Setup() {
		//get kernel index
		kernelIndex = depthMapperComputeShader.FindKernel ("PrepareDepthMapMain");
		//get thread group sizes
		depthMapperComputeShader.GetKernelThreadGroupSizes (kernelIndex, out threadGroupSizeX, out threadGroupSizeY, out threadGroupSizeZ);
		//get initial depth map
		depthMap = depthMaterial.GetTexture ("_DepthTex");
		//create render texture of same size
		//We need to store depth.
		depthMapOut = GetRenderTexture();
		//pass it to the material
		depthMaterial.SetTexture ("_DepthTex2", depthMapOut);
		//also pass it to compute shader
		depthMapperComputeShader.SetTexture (kernelIndex, "depthMapOut", depthMapOut);

		previewMaterial.mainTexture = depthMapOut;
		//set size
		depthMapperComputeShader.SetFloat("width",depthMapOut.width);
		depthMapperComputeShader.SetFloat("height",depthMapOut.height);
		Debug.Log (string.Format ("Depth Map : {0}x{1}", depthMapOut.width, depthMapOut.height));
		//depth map in
		depthMapperComputeShader.SetTexture (0, "depthMap", depthMap);
	}

	private RenderTexture GetRenderTexture() {
		if (depthMapOut == null) {
			depthMapOut = new RenderTexture(depthMap.width, depthMap.height, 24);
			depthMapOut.enableRandomWrite = true;
			depthMapOut.Create ();
		}
		return depthMapOut;
	}

	private void ReadMaterialParameters() {
		RotationAngle = depthMaterial.GetVector ("_RotationAngle");
		RotationCenter = depthMaterial.GetVector ("_RotationCenter");
		FillColor = depthMaterial.GetVector ("_FillColor");
		Speed = depthMaterial.GetFloat ("_Speed");
		Animate = depthMaterial.GetFloat ("_Animate");
		if (depthMaterial.GetFloat ("_ToggleAnimation") > 0) {
			IsDepthMapDirty = true;
		}
		if (IsDepthMapDirty) {
			PrepareDepthMap ();
		}
	}

	private void PrepareDepthMap() {
		depthMapperComputeShader.Dispatch (kernelIndex, (int)threadGroupSizeX, (int)threadGroupSizeY, (int)threadGroupSizeZ);

		IsDepthMapDirty = false;
	}

	private Vector4 RotationAngle {
		get {
			return _RotationAngle;
		}
		set {
			if (_RotationAngle != value) {
				IsDepthMapDirty = true;
				depthMapperComputeShader.SetVector ("_RotationAngle", value);
			}
			_RotationAngle = value; 
		}
	}

	private Vector4 RotationCenter {
		get {
			return _RotationCenter;
		}
		set {
			if (_RotationCenter != value) {
				IsDepthMapDirty = true;
				depthMapperComputeShader.SetVector ("_RotationCenter", value);
			}
			_RotationCenter = value; 
		}
	}

	private Vector4 FillColor {
		get {
			return _FillColor;
		}
		set {
			if (_FillColor != value) {
				IsDepthMapDirty = true;
				depthMapperComputeShader.SetVector ("_FillColor", value);
			}
			_FillColor = value; 
		}
	}

	private float Speed {
		get {
			return _Speed;
		}
		set {
			if (_Speed != value) {
				IsDepthMapDirty = true;
				depthMapperComputeShader.SetFloat ("_Speed", value);
			}
			_Speed = value; 
		}
	}

	private float Animate {
		get {
			return _Animate;
		}
		set {
			if (_Animate != value) {
				IsDepthMapDirty = true;
				depthMapperComputeShader.SetFloat ("_Animate", value);
			}
			_Animate = value; 
		}
	}

	private float ToggleAnimation {
		get {
			return _ToggleAnimation;
		}
		set {
			if (_ToggleAnimation != value) {
				IsDepthMapDirty = true;
				depthMapperComputeShader.SetFloat ("_ToggleAnimation", value);
			}
			_ToggleAnimation = value; 
		}
	}

}
