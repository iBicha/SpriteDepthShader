using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
public class DepthMapper : MonoBehaviour {

	public ComputeShader depthMapperComputeShader;
	public Material depthMaterial;

	private int kernelIndex;

	private uint threadGroupSizeX;
	private uint threadGroupSizeY;
	private uint threadGroupSizeZ;

	private Texture depthMap;
	private RenderTexture depthMapOut;

	private Vector4 _RotationAngle;
	private Vector4 _RotationCenter;
	private Vector4 _FillColor;

	private bool IsDepthMapDirty = true;

	void Start() {
		Setup ();
	}

	void Update () {
		ReadMaterialParameters ();
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
		depthMapOut = new RenderTexture(depthMap.width, depthMap.height, 24);
		depthMapOut.enableRandomWrite = true;
		depthMapOut.Create ();
		//pass it to compute shader
		depthMapperComputeShader.SetTexture (0, "depthMapOut", depthMapOut);
		//pass it also the material
		depthMaterial.SetTexture ("_DepthTex2", depthMapOut);
	}

	private void ReadMaterialParameters() {
		RotationAngle = depthMaterial.GetVector ("_RotationAngle");
		RotationCenter = depthMaterial.GetVector ("_RotationCenter");
		FillColor = depthMaterial.GetVector ("_RotationCenter");
		if (IsDepthMapDirty) {
			PrepareDepthMap ();
		}
	}

	private void PrepareDepthMap() {
		//todo: call with thread groups
		depthMapperComputeShader.Dispatch (kernelIndex, 1, 1, 1);

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

}
