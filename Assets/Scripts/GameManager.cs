using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public Material[] skyboxes;
    public GameObject elevatorMusic;
    public GameObject elevatorDing;
    public GameObject[] maps;
    public GameObject[] elevatorDoors;
    int currentMap = 1;
    float mapTime = 20.0f;
    float cycleTime;

    private IEnumerator coroutine;
    private IEnumerator gardenCoroutine;

    // Start is called before the first frame update
    void Start()
    {
        cycleTime = 2;
    }

    private IEnumerator Transition()  {
        // close doors
        Debug.Log("Closing doors and advancing map");
        float t = 0.0f;
        Vector3 delta = new Vector3(0, 0, 0);

        Vector3[] startPoses = new Vector3[2];
        startPoses[0] = elevatorDoors[0].transform.position;
        startPoses[1] = elevatorDoors[1].transform.position;

        elevatorDing.SetActive(true);

        while(t < 1)  {
            t += 1.0f * Time.deltaTime;
            for(int i=0; i<2; i++) {
                float dir = (i == 0) ? -1.1f : 1.1f;
                delta.x = dir;
                elevatorDoors[i].transform.position = Vector3.Lerp(elevatorDoors[i].transform.position, startPoses[i] + delta, t);
            }
            yield return null;
        }
        elevatorDing.SetActive(false);

        yield return new WaitForSeconds(0.4f);
        maps[currentMap].SetActive(false);
        elevatorMusic.SetActive(true);
        yield return new WaitForSeconds(4.6f);
        currentMap = (currentMap + 1) % maps.Length;
        RenderSettings.skybox= skyboxes[currentMap];
        maps[currentMap].SetActive(true);
        elevatorMusic.SetActive(false);
        Debug.Log("You got some new map");

        
        startPoses[0] = elevatorDoors[0].transform.position;
        startPoses[1] = elevatorDoors[1].transform.position;

        elevatorDing.SetActive(true);

        t = 0.0f;
        while(t < 1)  {
            t += 1.0f * Time.deltaTime;
            for(int i=0; i<2; i++) {
                float dir = (i == 0) ? 1.1f : -1.1f;
                delta.x = dir;
                elevatorDoors[i].transform.position = Vector3.Lerp(elevatorDoors[i].transform.position, startPoses[i] + delta, t);
            }
            yield return null;
        }
        
        elevatorDing.SetActive(false);

        cycleTime = mapTime;
        coroutine = null;
        // open doors
    }

    private IEnumerator Garden() {
        Debug.Log("Garden time");
        Vector3 original = maps[currentMap].transform.localScale;

        yield return new WaitForSeconds(5);

        float t = mapTime - 5.0f;
        float speed = 0.0f;
        float closeSpeed = 0.0f;

        while(t >= 0.0f)  {
            maps[currentMap].transform.localScale = original + new Vector3(0.0f, 0.0f, speed);
            speed += 1.12f * Time.deltaTime;
            closeSpeed += 0.02f * Time.deltaTime;
            t -= Time.deltaTime;
            yield return null;
        }

        yield return new WaitForSeconds(2);
        gardenCoroutine = null;
        maps[currentMap].transform.localScale = original;
    }

    

    // Update is called once per frame
    void Update()
    {
        if(coroutine == null)  {
            if(currentMap == 0 && gardenCoroutine == null) {
                gardenCoroutine = Garden();
                StartCoroutine(gardenCoroutine);
            }
            cycleTime -= Time.deltaTime;
        }
        if(cycleTime <= 0)  {
            if(coroutine == null)  {
                coroutine = Transition();
                StartCoroutine(coroutine);
            }
        }
    }
}
