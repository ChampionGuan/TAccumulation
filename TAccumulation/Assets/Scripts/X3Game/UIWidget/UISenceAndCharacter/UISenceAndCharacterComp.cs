using PapeGames.X3;
using System.Collections;
using System.Collections.Generic;
using PapeGames.CutScene;
using UnityEngine;
using XLua;
using X3;
using PapeGames.Rendering;
using X3Game;

[LuaCallCSharp]
public class UISenceAndCharacterComp : MonoBehaviour
{
    public GameObject goLeftChraceterRoot;
    public GameObject goCenterChraceterRoot;
    public GameObject goRightChraceterRoot;
    public GameObject goRightShadow = null;
    public EasingFunction.Ease moveCamerCurve = EasingFunction.Ease.EaseInSine;
    public float moveCamerSpeed = 4;
    public float MoveRoleSpeed = 30;
    public PostProcessVolume ppv;

    private GameObject leftIns = null;
    private GameObject centerIns = null;
    private GameObject rightIns = null;
    private GameObject currLoadModel;
    private IX3CharacterWave characterWave = null;
    private Vector3 defaultRotate = Vector3.zero;
    private BlurWeightModifier blurModifier; //用于控制背景模糊

    void Start()
    {
        if (goRightShadow != null)
        {
            goRightShadow.SetActive(false);
        }

        RenderActor renderActor = GetComponentInChildren<RenderActor>();

        if (renderActor != null)
            blurModifier = (BlurWeightModifier)renderActor.GetModifierByType(PropertyModifier.ModifierType.BlurWeight);
    }

    public GameObject GetCurModel()
    {
        return currLoadModel;
    }

    public Transform GetCenterTransform()
    {
        return goCenterChraceterRoot != null ? goCenterChraceterRoot.transform : null;
    }

    public Transform GetLeftTransform()
    {
        return goLeftChraceterRoot != null ? goLeftChraceterRoot.transform : null;
    }

    public Transform GetRightTransform()
    {
        return goRightChraceterRoot != null ? goRightChraceterRoot.transform : null;
    }

    public void InitLeftRole(GameObject ins, Vector3 mpos, Vector3 rotate, string strAnimName, IX3CharacterWave wave)
    {
        if (leftIns == ins) return;
        ClearRootObject(goLeftChraceterRoot);

        leftIns = ins;

        if (ins == null) return;

        LoadRole(ins, goLeftChraceterRoot.transform, mpos, rotate, strAnimName, wave);
    }

    public void ClearLeftRole()
    {
        ClearRootObject(goLeftChraceterRoot);
        leftIns = null;
        currLoadModel = null;
        characterWave = null;
    }

    public void InitCenterRole(GameObject ins, Vector3 mpos, Vector3 rotate, string strAnimName, IX3CharacterWave wave)
    {
        //if (ins == centerIns) return;
        ClearAllRootObject();

        centerIns = ins;

        if (ins == null) return;

        defaultRotate = rotate;
        LoadRole(ins, goCenterChraceterRoot.transform, mpos, rotate, strAnimName, wave);
    }

    public void ClearCenterRole()
    {
        ClearRootObject(goCenterChraceterRoot);
        centerIns = null;
        currLoadModel = null;
        characterWave = null;
    }

    public void InitRightRole(GameObject ins, Vector3 mpos, Vector3 rotate, string strAnimName, IX3CharacterWave wave)
    {
        if (rightIns == ins) return;
        ClearRootObject(goRightChraceterRoot);

        rightIns = ins;
        if (ins == null) return;
        LoadRole(ins, goRightChraceterRoot.transform, mpos, rotate, strAnimName, wave);
    }

    public void ClearRightRole()
    {
        if (goRightShadow != null)
            goRightShadow.SetActive(true);
        ClearRootObject(goRightChraceterRoot);
        rightIns = null;
        currLoadModel = null;
        characterWave = null;
    }

    public void SetX3AnimatorRotate(bool isX3AnimatorRotate)
    {
        GetGestureComp().SetX3AnimatorRotate(isX3AnimatorRotate);
    }

    public bool GetX3AnimatorRotate()
    {
        return GetGestureComp().GetX3AnimatorRotate();
    }

    private GameObject LoadRole(GameObject ins, Transform parent, Vector3 mpos, Vector3 rotate, string strAnimName = "",
        IX3CharacterWave wave = null)
    {
        //Avatar_Bone01_st

        var go = ins;
        if (go == null) return null;
        go.transform.SetParent(parent, false);
        go.transform.localScale = Vector3.one;
        go.transform.localPosition = mpos;
        go.transform.localEulerAngles = rotate;
        currLoadModel = go;
        characterWave = wave;
        go.SetActive(true);

        return go;
    }

    public void ClearCenterMonster()
    {
        ClearRootObject(goCenterChraceterRoot);
        centerIns = null;
        currLoadModel = null;
        characterWave = null;
    }

    public void ClearAllRootObject()
    {
        ClearRootObject(goLeftChraceterRoot);
        ClearRootObject(goCenterChraceterRoot);
        ClearRootObject(goRightChraceterRoot);

        leftIns = null;
        centerIns = null;
        rightIns = null;
    }

    private void ClearRootObject(GameObject goRoot)
    {
        for (int i = 0; i < goRoot.transform.childCount; i++)
        {
            Destroy(goRoot.transform.GetChild(i).gameObject);
        }
    }

    List<Renderer> _cacheList = new List<Renderer>();

    //设置所有renderer--layer
    public void SetLayer(int layerID)
    {
        if (currLoadModel != null)
        {
            currLoadModel.GetComponentsInChildren(true, _cacheList);
            foreach (Renderer r in _cacheList)
            {
                r.gameObject.layer = layerID;
            }

            _cacheList.Clear();
        }
    }

    public CtsHandle PlayLeftCutScene(string cutSceneName, bool isLoop, bool isAutoPause,
        PapeGames.CutScene.CutScenePlayMode playMode = PapeGames.CutScene.CutScenePlayMode.Crossfade)
    {
        //if (goRightShadow != null)
        //    goRightShadow.SetActive(true);
        return PlayCutScene(goLeftChraceterRoot.transform, cutSceneName, isLoop, isAutoPause, playMode);
    }

    public CtsHandle PlayCenterCutScene(string cutSceneName, bool isLoop, bool isAutoPause,
        PapeGames.CutScene.CutScenePlayMode playMode = PapeGames.CutScene.CutScenePlayMode.Crossfade)
    {
        //if (goRightShadow != null)
        //    goRightShadow.SetActive(false);
        return PlayCutScene(goCenterChraceterRoot.transform, cutSceneName, isLoop, isAutoPause, playMode);
    }

    public CtsHandle PlayRightCutScene(string cutSceneName, bool isLoop, bool isAutoPause,
        PapeGames.CutScene.CutScenePlayMode playMode = PapeGames.CutScene.CutScenePlayMode.Crossfade)
    {
        if (goRightShadow != null)
            goRightShadow.SetActive(false);
        return PlayCutScene(goRightChraceterRoot.transform, cutSceneName, isLoop, isAutoPause, playMode);
    }


    /// <summary>
    /// 播放cutScene
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="assetId"></param>
    /// <param name="modelName"></param>
    /// <param name="cutSceneName"></param>
    /// <param name="isLoop"></param>
    /// <param name="isAutoPause"></param>
    private CtsHandle PlayCutScene(Transform parent, string cutSceneName, bool isLoop, bool isAutoPause,
        PapeGames.CutScene.CutScenePlayMode playMode = PapeGames.CutScene.CutScenePlayMode.Crossfade)
    {
        var Loop = UnityEngine.Playables.DirectorWrapMode.Hold;
        if (isLoop)
        {
            Loop = UnityEngine.Playables.DirectorWrapMode.Loop;
        }
        else
        {
            Loop = UnityEngine.Playables.DirectorWrapMode.Hold;
        }

        var item = PapeGames.CutScene.X3CutSceneManager.PlayX3(cutSceneName, playMode, Loop, 0, 0, isAutoPause, parent,
            this.GetInstanceID());
        m_PlayId = item.PlayId;
        return item;
    }

    private int m_PlayId = 0;

    public void Stop()
    {
        PapeGames.CutScene.CutSceneManager.StopWithPlayId(m_PlayId);
        m_PlayId = 0;
    }

    public void Resume()
    {
        PapeGames.CutScene.CutSceneManager.ResumeWithPlayId(m_PlayId);
    }

    public void Pause()
    {
        PapeGames.CutScene.CutSceneManager.PauseWithPlayId(m_PlayId);
    }


    //开启相机移动
    public void OpenCameraLook(bool controllable = true)
    {
        StopMoveAct();
        var comp = GetGestureComp();
        if (comp != null)
        {
            comp.SetTarget(currLoadModel ? currLoadModel.transform : null, characterWave);
            comp.MoveIn(-1, controllable);
        }
    }

    public void ResetPinchNearPlaneTargetY()
    {
        StopMoveAct();
        var comp = GetGestureComp();
        if (comp != null)
            comp.ResetPinchNearPlaneTargetY();
    }


    //关闭相机移动

    public void QuitCameraLook(bool controllable = false)
    {
        StopMoveAct();
        var comp = GetGestureComp();
        if (comp != null)
            comp.MoveOut(-1, controllable);
    }

    public void RestCameraPos()
    {
        var comp = GetGestureComp();
        if (comp != null)
            comp.RestCameraPos();
    }

    public void QuitFreedomView()
    {
        var comp = GetGestureComp();
        if (comp != null)
            comp.Controllable = false;
    }

    public void OpenFreedomView()
    {
        var comp = GetGestureComp();
        if (comp != null)
        {
            comp.SetTarget(currLoadModel ? currLoadModel.transform : null, characterWave);
            comp.Controllable = true;
        }
    }

    X3Game.X3CharacterGesture m_GestureComp = null;

    private X3Game.X3CharacterGesture GetGestureComp()
    {
        if (m_GestureComp == null)
            m_GestureComp = GetComponent<X3Game.X3CharacterGesture>();
        return m_GestureComp;
    }


    private Coroutine changePos = null;
    private Vector3 movePos = Vector3.zero;
    private Vector3 moveRot = Vector3.zero;

    public void SetCameraPos(Vector3 newPos, Vector3 newRot, bool isRotateRole, bool imdiate, int effectValue)
    {
        movePos = newPos;
        moveRot = newRot;
        var comp = GetGestureComp();
        if (comp == null) return;

        var camera = comp.GetCamera();
        if (changePos != null)
            StopCoroutine(changePos);

        if (imdiate)
        {
            camera.transform.localPosition = movePos;
            camera.transform.localRotation = Quaternion.Euler(newRot);
            return;
        }

        changePos = StartCoroutine(ExeChangePos(camera.transform, movePos, moveRot, isRotateRole, effectValue));
    }

    private void StopMoveAct()
    {
        if (changePos == null) return;
        StopCoroutine(changePos);
        changePos = null;
        //停止相机移动时，要把相机的位置设置到对应位置，保存相机的坐标,角色设置到初始位置 恢复手势旋转
        var comp = GetGestureComp();
        if (comp != null)
        {
            var camera = comp.GetCamera();
            camera.transform.localPosition = movePos;
            RoleRotateToInit(1);
            comp.RefreshCamPoint(camera.transform.position,
                moveRot);
        }

        isRoteRole = true;
    }

    IEnumerator ExeChangePos(Transform tfcamera, Vector3 tarPos, Vector3 tarRot, bool isRotateRole = true,
        int targetValue = 0)
    {
        //镜头移动过程中，停用手势旋转，以镜头移动，角色复位为第一优先级
        isRoteRole = false;
        var comp = GetGestureComp();
        float duration = Vector3.Distance(tfcamera.localPosition, tarPos) / moveCamerSpeed;
        //增加角色的旋转时间,取最大的数值
        Transform tfrole = GetRoleTransform();
        if (tfrole != null)
        {
            var durationOfRole = Quaternion.Angle(GetTargetLocalRotation(), Quaternion.Euler(defaultRotate)) /
                                 MoveRoleSpeed;
            duration = Mathf.Max(durationOfRole, duration);
        }

        if (duration <= 0)
        {
            tfcamera.localPosition = tarPos;
        }
        else
        {
            float t = 0;
            var easeFunc = EasingFunction.GetEasingFunction(moveCamerCurve);
            while (t < duration)
            {
                yield return null;
                t += Time.deltaTime;
                float p = easeFunc(0, 1, Mathf.Clamp01(t / duration));
                Quaternion rot = Quaternion.Lerp(tfcamera.localRotation, Quaternion.Euler(tarRot), p);
                Vector3 pos = Vector3.Lerp(tfcamera.localPosition, tarPos, p);
                tfcamera.localPosition = pos;
                tfcamera.localRotation = rot;
                if (isRotateRole)
                {
                    RoleRotateToInit(p);

                    SetVagueRadius(p, targetValue);
                }
            }

            if (comp != null) comp.RefreshCamPoint(tfcamera.position, moveRot);

            changePos = null;
        }

        isRoteRole = true;
    }

    private void RoleRotateToInit(float time)
    {
        Quaternion rot = Quaternion.Lerp(GetTargetLocalRotation(), Quaternion.Euler(defaultRotate), time);
        SetTargetLocalRotation(rot.eulerAngles);
    }

    private Transform GetRoleTransform()
    {
        return currLoadModel ? currLoadModel.transform : null;
    }

    private void SetTargetLocalRotation(Vector3 rotation)
    {
        GetGestureComp().SetTargetLocalRotation(rotation);
    }

    private Quaternion GetTargetLocalRotation()
    {
        return GetGestureComp().GetTargetLocalRotation();
    }

    private Vector3 GetTargetLocalEulerAngles()
    {
        return GetGestureComp().GetTargetLocalEulerAngles();
    }

    #region

    public void RoteRole(bool isRote)
    {
        var comp = GetGestureComp();
        if (comp != null && isRoteRole != isRote)
        {
            isRoteRole = isRote;

            if (!isRote)
                StopMoveAct();
        }
    }

    private void Detect()
    {
        if (!isRoteRole || !InputComponent.IsGlobalTouchEnabled)
            return;
        if (!m_IsDragging && X3CharacterGesture.IsTouchOnUI())
            return;
        GetGestureComp().SetTarget(currLoadModel ? currLoadModel.transform : null, characterWave);
#if UNITY_EDITOR
        RotateRoleOnEditor();
#else
            RotateRoleOnMobile();
#endif
    }


    private bool isRoteRole = false;
    private bool m_IsDragging = false;
    private Vector2 m_PrevTouch1Pos;
    private Vector2 m_Touch1Pos;
    private Vector2 m_DragDelta;
    private Coroutine m_DragInertial;

    private void RotateRoleOnEditor()
    {
        if (Input.GetMouseButtonDown(0) && !m_IsDragging)
        {
            m_PrevTouch1Pos = Input.mousePosition;
            m_Touch1Pos = m_PrevTouch1Pos;
            m_DragDelta = m_Touch1Pos - m_PrevTouch1Pos;
            m_IsDragging = true;
            StopDragInertial();
        }

        if (Input.GetMouseButton(0) && m_IsDragging)
        {
            m_PrevTouch1Pos = m_Touch1Pos;
            m_Touch1Pos = Input.mousePosition;
            m_DragDelta = m_Touch1Pos - m_PrevTouch1Pos;
            GetGestureComp().ExeDrag(m_DragDelta, m_Touch1Pos, false);
        }

        if (Input.GetMouseButtonUp(0) && m_IsDragging)
        {
            m_IsDragging = false;

            StartDragInertial(m_DragDelta, m_Touch1Pos);
        }
    }

    private void StartDragInertial(Vector2 m_DragDelta, Vector2 m_Touch1Pos)
    {
        StopDragInertial();

        GetGestureComp().SetDragExternalState(true);
        m_DragInertial = StartCoroutine(GetGestureComp().ExeDragInertialForExternal(m_DragDelta, m_Touch1Pos));
    }

    private void StopDragInertial()
    {
        //镜头移动过程中，停用手势旋转，以镜头移动，角色复位为第一优先级 
        // //收按下的时候,停止人物旋转
        // if (changePos != null)
        //     StopCoroutine(changePos);
        //
        // if (m_DragInertial == null) return;
        //
        // GetGestureComp().SetDragExternalState(false);
        // StopCoroutine(m_DragInertial);
        // m_DragInertial = null;
    }

    private void RotateRoleOnMobile()
    {
        //单指滑动
        if (Input.touchCount == 1 && Input.GetTouch(0).phase == TouchPhase.Began && !m_IsDragging)
        {
            Debug.Log("RotateRoleOnMobile TouchPhase.Began");
            m_PrevTouch1Pos = Input.GetTouch(0).position;
            m_Touch1Pos = m_PrevTouch1Pos;
            m_DragDelta = m_Touch1Pos - m_PrevTouch1Pos;
            m_IsDragging = true;
            StopDragInertial();
        }

        if (m_IsDragging)
        {
            if (Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Moved)
            {
                Debug.Log("RotateRoleOnMobile TouchPhase.Moved");
                m_PrevTouch1Pos = m_Touch1Pos;
                m_Touch1Pos = Input.GetTouch(0).position;
                m_DragDelta = m_Touch1Pos - m_PrevTouch1Pos;
                GetGestureComp().ExeDrag(m_DragDelta, m_Touch1Pos, false);
            }

            if (Input.touchCount > 1 || Input.touchCount == 0 || Input.GetTouch(0).phase == TouchPhase.Ended)
            {
                Debug.Log("RotateRoleOnMobile TouchPhase.Ended");
                m_IsDragging = false;
                StartDragInertial(m_DragDelta, m_Touch1Pos);
            }
        }
    }

    #endregion


    private bool ppvEffect = false;

    public void EnablePPVEffect(bool isEnable)
    {
        if (ppv != null)
            ppv.gameObject.SetActive(isEnable);

        CloseUpBlurBfg blur = ppv.GetFeature(BlendableFeatureGroup.FeatureType.BFG_CloseUpBlur) as CloseUpBlurBfg;
        blur.BlurLerp = 0;
        blur.Apply();

        ppvEffect = isEnable;
    }

    public void SetCameraLayer(int layer)
    {
        var comp = GetGestureComp();
        if (comp != null)
        {
            var camera = comp.GetCamera();
            camera.gameObject.layer = layer;
        }
    }

    public void SetVagueRadius(float range, float targetValue)
    {
        /*if (ppv == null) return;

        CloseUpBlurBfg blur = ppv.GetFeature(typeof(CloseUpBlurBfg)) as CloseUpBlurBfg;

        if (blur.BlurLerp == targetValue) return;

        if (targetValue < range)
            range = 1 - range;

        blur.BlurLerp = range;
        blur.Apply();
        */

        if (blurModifier == null) return;

        if (targetValue < range)
            range = 1 - range;

        blurModifier.BlurValue = range;
    }

    private void Update()
    {
        Detect();
    }
}