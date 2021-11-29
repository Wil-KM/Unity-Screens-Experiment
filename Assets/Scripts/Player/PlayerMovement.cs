using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    private CharacterController controller;
    private Camera playerCam;

    // Only used to track y velocity for gravity & jumps
    private Vector3 playerVelocity;
    private bool groundedPlayer;
    private float playerSpeed = 4.0f;
    private float jumpHeight = 2.0f;
    private float gravityValue = -9.81f;
    private float cameraPitch;
    private float cameraYaw;
    private float lookSpeedH = 1.0f;
    private float lookSpeedV = 1.0f;

    private void Start()
    {
        controller = gameObject.GetComponent<CharacterController>();
        playerCam = gameObject.GetComponentInChildren<Camera>();
    }

    void Update()
    {
        move();
        look();
    }

    private void move()
    {
        // Are we on the floor?
        groundedPlayer = controller.isGrounded;

        // If we're touching the floor and not going up, we stay stationary in y
        if (groundedPlayer && playerVelocity.y < 0)
            playerVelocity.y = 0f;

        // Get movement direction based on arrow keys, and move player in that direction
        Vector3 move = Input.GetAxis("Horizontal") * transform.right + Input.GetAxis("Vertical") * transform.forward;
        controller.Move(move * Time.deltaTime * playerSpeed);

        // If on the floor and we jump, add to y velocity
        if (Input.GetButtonDown("Jump") && groundedPlayer)
            playerVelocity.y += Mathf.Sqrt(jumpHeight * -3.0f * gravityValue);

        // Add gravity and move player in y axis
        playerVelocity.y += gravityValue * Time.deltaTime;
        controller.Move(playerVelocity * Time.deltaTime);
    }

    private void look()
    {
        // Convert mouse position to camera orientation
        cameraYaw += lookSpeedH * Input.GetAxis("Mouse X");
        cameraPitch += lookSpeedV * -Input.GetAxis("Mouse Y");

        // Stop us looking to far up or down we flip over
        cameraPitch = Mathf.Clamp(cameraPitch, -70f, 70f);

        // Rotate the player to match the horizontal facing and the camera to match the vertical facing
        playerCam.transform.localRotation = Quaternion.Euler(new Vector3(cameraPitch, 0f, 0f));
        transform.localRotation = Quaternion.Euler(new Vector3(0f, cameraYaw, 0f));
    }
}
