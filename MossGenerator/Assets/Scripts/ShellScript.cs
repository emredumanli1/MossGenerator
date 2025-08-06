using UnityEngine;

public class ShellScript : MonoBehaviour
{

    public Shader shellShader;

    public Texture2D noiseText;

    public Color shellColor;


    [Tooltip("Number of shells/layers to generate")]
    [Range(0, 128)]
    public int shellCount = 8;

    [Range(0f, 0.5f)]
    [Tooltip("Offset distance between shells")]
    public float shellOffset = 0.01f;



    [Range(0.0f, 1.0f)]
    public float shellLength = 0.15f;


    [Range(1.0f, 1000.0f)]
    public float density = 100.0f;

    [Range(0.0f, 1.0f)]
    public float noiseMin = 0.0f;

    [Range(0.0f, 1.0f)]
    public float noiseMax = 1.0f;

    [Range(0.0f, 10.0f)]
    public float thickness = 1.0f;

    private GameObject[] shells;
    private Material mossMaterial;




    private void OnEnable()
    {
        mossMaterial = new Material(shellShader);

        shells = new GameObject[shellCount];

        Mesh originalMesh = GetComponent<MeshFilter>().sharedMesh;

        for (int i = 0; i < shellCount; i++)
        {
            // Create a new GameObject for each shell
            GameObject shell = new GameObject("MossShell_" + i);
            shell.transform.parent = this.transform;
            shell.transform.localPosition = Vector3.zero;
            shell.transform.localRotation = Quaternion.identity;
            shell.transform.localScale = Vector3.one;

            // Add MeshFilter and MeshRenderer
            MeshFilter mf = shell.AddComponent<MeshFilter>();
            MeshRenderer mr = shell.AddComponent<MeshRenderer>();

            // Assign the original mesh
            mf.sharedMesh = originalMesh;

            // Instantiate a new material for this shell to set unique properties
            Material matInstance = new Material(mossMaterial);

            matInstance.SetTexture("_MossTex", noiseText);
            
            matInstance.SetColor("_ShellColor",shellColor);

            matInstance.SetFloat("_ShellIndex", i);
            matInstance.SetFloat("_ShellCount", shellCount);
            matInstance.SetFloat("_ShellOffset", shellOffset);


            matInstance.SetFloat("_ShellLength", shellLength);
            matInstance.SetFloat("_Density", density);
            matInstance.SetFloat("_Thickness", thickness);
            mr.material = matInstance;

            shells[i] = shell;
        }

        // Hide the original mesh (optional)
        //MeshRenderer originalMR = GetComponent<MeshRenderer>();
        //if (originalMR != null) originalMR.enabled = false;
    }
}
