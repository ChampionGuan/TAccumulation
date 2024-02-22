using UnityEngine;
using System.Collections;
using DG.Tweening;
using System.Collections.Generic;

public class Gyroscope : MonoBehaviour
{
    public static List<Gyroscope> Gyroscopes = new List<Gyroscope>();

    private Transform theTarget;

    private Vector3 posOffset = Vector3.zero;
    private Vector3 rotOffset = Vector3.zero;
    private Vector3 scaleOffset = Vector3.zero;

    private Vector3 posAttitude = Vector3.zero;
    private Vector3 rotAttitude = Vector3.zero;
    private Vector3 scaleAttitude = Vector3.zero;

    public string gyroName = "gyroscope";

    public float posFactorX = 0;
    public float posFactorY = 0;
    public float rotFactorX = 0;
    public float rotFactorY = 0;
    public float scaleFactorX = 0;
    public float scaleFactorY = 0;

    public float lerpTime = 0.5f;

    void Awake()
    {
        theTarget = transform;
        posOffset = theTarget.localPosition;
        rotOffset = theTarget.localRotation.eulerAngles;
        scaleOffset = theTarget.localScale;

        GetAccelerationInfo();
        theTarget.DOLocalMove(posAttitude + posOffset, 0);
        theTarget.DOLocalRotate(rotAttitude + rotOffset, 0);
        theTarget.DOScale(scaleAttitude + scaleOffset, 0);

        Gyroscopes.Add(this);
    }

    void LateUpdate()
    {
        GetAccelerationInfo();
        theTarget.DOLocalMove(posAttitude + posOffset, lerpTime);
        theTarget.DOLocalRotate(rotAttitude + rotOffset, lerpTime);
        theTarget.DOScale(scaleAttitude + scaleOffset, lerpTime);
    }

    void GetAccelerationInfo()
    {
        posAttitude.z = 0;
        posAttitude.x = -posFactorX * Input.acceleration.x;
        posAttitude.y = -posFactorY * Input.acceleration.y;

        rotAttitude.z = 0;
        rotAttitude.x = -rotFactorX * Input.acceleration.x;
        rotAttitude.y = -rotFactorY * Input.acceleration.y;

        scaleAttitude.z = 0;
        scaleAttitude.x = -scaleFactorX * Input.acceleration.x;
        scaleAttitude.y = -scaleFactorY * Input.acceleration.y;
    }
}