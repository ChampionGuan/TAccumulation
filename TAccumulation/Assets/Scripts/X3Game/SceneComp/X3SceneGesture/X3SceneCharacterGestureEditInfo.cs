using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace X3Game.SceneGesture
{
    public class X3SceneCharacterGestureEditInfo : MonoBehaviour
    {
        public List<GameObject> CharacterCutscenes = new List<GameObject> {null, null};
        public List<Vector3> Positions = new List<Vector3> {Vector3.zero, Vector3.zero};
    }
}