using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    private CharacterController controller;

    // Only used to track y velocity for gravity & jumps
    private Vector3 playerVelocity;
    private bool groundedPlayer;
    private float playerSpeed = 2.0f;
    private float jumpHeight = 1.0f;
    private float gravityValue = -9.81f;

    private void Start()
    {
        controller = gameObject.GetComponent<CharacterController>();
    }

    void Update()
    {
        // Are we on the floor?
        groundedPlayer = controller.isGrounded;

        Debug.Log(groundedPlayer);

        // If we're touching the floor and not going up, we stay stationary in y
        if (groundedPlayer && playerVelocity.y < 0)
            playerVelocity.y = 0f;

        // Get movement direction based on arrow keys, and move player in that direction
        Vector3 move = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));
        controller.Move(move * Time.deltaTime * playerSpeed);

        // If on the floor and we jump, add to y velocity
        if (Input.GetButtonDown("Jump") && groundedPlayer)
            playerVelocity.y += Mathf.Sqrt(jumpHeight * -3.0f * gravityValue);

        // Add gravity and move player in y axis
        playerVelocity.y += gravityValue * Time.deltaTime;
        controller.Move(playerVelocity * Time.deltaTime);
    }
}
