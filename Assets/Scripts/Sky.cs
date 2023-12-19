using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sky : MonoBehaviour
{
    [SerializeField]
    Transform prefab;

    [SerializeField, Range(5, 50)]
    int cubes = 10;

    [SerializeField, Range(10, 100)]
    int range = 20;

    [SerializeField, Range(10, 120)]
    int yRange = 20;

    [SerializeField, Range(1, 100)]
    float speed = 5.0f;

    [SerializeField, Range(0, 5)]
    float size = 1.0f;

    [SerializeField, Range(5, 50)]
    int yBias = 10;

    Transform[] points;
    float[] rotateSpeeds;

    void Awake() {
        points = new Transform[cubes];
        rotateSpeeds = new float[cubes];

        for(int i=0; i<points.Length; i++) {
            Transform point = points[i] = Instantiate(prefab);
            point.localScale = Vector3.one * size;

            float randX = Random.Range(-range, range);
            float randY = Random.Range(0, yRange + 50);
            float randZ = Random.Range(-range, range);

            rotateSpeeds[i] = randX;

            point.localPosition = this.transform.position + new Vector3(randX, yBias + randY, randZ);
            point.SetParent(this.transform);
        }
    }

    void Update() {
        for(int i=0; i<points.Length; i++) {
            Transform point = points[i];
            point.localScale = Vector3.one * size;
            float rotateSpeed = rotateSpeeds[i];
            point.transform.Rotate(rotateSpeed * Time.deltaTime, rotateSpeed * Time.deltaTime, rotateSpeed * Time.deltaTime, Space.Self);

            Vector3 pos = point.localPosition;
            pos.y -= speed * Time.deltaTime;

            point.localPosition = pos;

            if(pos.y < -75) {
                rotateSpeeds[i] = Random.Range(-range, range);
                point.localPosition = this.transform.position + new Vector3(Random.Range(-range, range), yBias + Random.Range(0, yRange), Random.Range(-range, range));
            }
        }
    }
}
