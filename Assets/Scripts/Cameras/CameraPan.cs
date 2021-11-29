using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraPan : MonoBehaviour
{
    private float panSpeed = 10.0f;
    private float maxAngle = 30.0f;
    private int dir = 1;
    private float angle;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        float delta = panSpeed * Time.deltaTime * dir;

        transform.Rotate(new Vector3(0f, delta, 0f));
        angle += delta;

        if (angle > maxAngle || angle < -maxAngle)
            dir *= -1;
    }
}