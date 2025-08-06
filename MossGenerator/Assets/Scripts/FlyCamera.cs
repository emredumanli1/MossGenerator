using UnityEngine;

public class FlyCamera : MonoBehaviour
{
    public float moveSpeed = 10f;
    public float fastMoveMultiplier = 2f;
    public float lookSpeed = 2f;

    private bool isLooking = false;
    private Vector2 rotation = Vector2.zero;

    void Update()
    {
        // Toggle mouse look on right mouse button
        if (Input.GetMouseButtonDown(1))
        {
            isLooking = true;
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
        else if (Input.GetMouseButtonUp(1))
        {
            isLooking = false;
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
        }

        if (isLooking)
        {
            // Mouse look
            rotation.x += Input.GetAxis("Mouse X") * lookSpeed;
            rotation.y -= Input.GetAxis("Mouse Y") * lookSpeed;
            rotation.y = Mathf.Clamp(rotation.y, -90f, 90f);
            transform.rotation = Quaternion.Euler(rotation.y, rotation.x, 0f);
        }

        // Movement
        float currentSpeed = moveSpeed * (Input.GetKey(KeyCode.LeftShift) ? fastMoveMultiplier : 1f);
        Vector3 move = new Vector3(
            Input.GetAxis("Horizontal"),
            (Input.GetKey(KeyCode.E) ? 1 : 0) - (Input.GetKey(KeyCode.Q) ? 1 : 0),
            Input.GetAxis("Vertical")
        );

        transform.Translate(move * currentSpeed * Time.deltaTime, Space.Self);
    }
}
