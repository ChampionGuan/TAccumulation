using System;
#if UNITY_EDITOR
    using UnityEditor;
    using UnityEditor.Timeline;
#endif

namespace UnityEngine.Timeline
{
    public class PhysicsWindGizmosHelper : MonoBehaviour
    {
        // 检查并添加GizmosObject
        public static void EvalDrawGizmosObject()
        {
#if UNITY_EDITOR
            var helperObject = GameObject.Find("TimelineDrawGizmos");
            if (helperObject == null)
            {
                helperObject = new GameObject("TimelineDrawGizmos");
            }

            var com = helperObject.GetComponent<PhysicsWindGizmosHelper>();
            if (com == null)
            {
                helperObject.AddComponent<PhysicsWindGizmosHelper>();
            }
#endif
        }

#if UNITY_EDITOR

        private void DrawPhysicsParam(PhysicsWindParam param)
        {
            if (param == null)
            {
                return;
            }

            if (param.attachObject == null)
            {
                return;    
            }

            var trans = param.attachObject.transform;
            var oldColor = Handles.color;
            // 空气场绘制
            Handles.color = Color.cyan;
            var transPos = param.attachObject.transform.position;
            var airPos = new Vector3(transPos.x, 1, transPos.z);
            var airRotation = trans.rotation * Quaternion.Euler(param.airParam.euler);
            if (param.airParam.isWorldMode)
            {
                airRotation = Quaternion.Euler(param.airParam.euler);
            }
            Handles.ArrowCap(0, airPos, airRotation, param.airParam.physicsData.strength);
            // 体积场绘制
            if (param.volumeParams != null)
            {
                foreach (var volume in param.volumeParams)
                {
                    var parameter = volume.physicsData;
                    Handles.color = Color.gray;
                    Vector3 pos = parameter.position;
                    Handles.DrawWireDisc(pos, new Vector3(0.0f, 1.0f, 0.0f), parameter.attenuation[1]);
                    Handles.DrawWireDisc(pos, new Vector3(1.0f, 0.0f, 0.0f), parameter.attenuation[1]);
                    Handles.DrawWireDisc(pos, new Vector3(0.0f, 0.0f, 1.0f), parameter.attenuation[1]);

                    Handles.color = Color.yellow;
                    Handles.DrawWireDisc(pos, new Vector3(0.0f, 1.0f, 0.0f), parameter.attenuation[0]);
                    Handles.DrawWireDisc(pos, new Vector3(1.0f, 0.0f, 0.0f), parameter.attenuation[0]);
                    Handles.DrawWireDisc(pos, new Vector3(0.0f, 0.0f, 1.0f), parameter.attenuation[0]);

                    Handles.color = Color.gray;
                    Vector3 tempp0 = pos;
                    Vector3 tempp1 = pos;
                    tempp0.x += parameter.attenuation[0];
                    tempp1.x += parameter.attenuation[1];
                    Handles.DrawLine(tempp0, tempp1);

                    tempp0 = pos;
                    tempp1 = pos;
                    tempp0.y += parameter.attenuation[0];
                    tempp1.y += parameter.attenuation[1];
                    Handles.DrawLine(tempp0, tempp1);

                    tempp0 = pos;
                    tempp1 = pos;
                    tempp0.z += parameter.attenuation[0];
                    tempp1.z += parameter.attenuation[1];
                    Handles.DrawLine(tempp0, tempp1);

                    tempp0 = pos;
                    tempp1 = pos;
                    tempp0.x -= parameter.attenuation[0];
                    tempp1.x -= parameter.attenuation[1];
                    Handles.DrawLine(tempp0, tempp1);

                    tempp0 = pos;
                    tempp1 = pos;
                    tempp0.y -= parameter.attenuation[0];
                    tempp1.y -= parameter.attenuation[1];
                    Handles.DrawLine(tempp0, tempp1);


                    tempp0 = pos;
                    tempp1 = pos;
                    tempp0.z -= parameter.attenuation[0];
                    tempp1.z -= parameter.attenuation[1];
                    Handles.DrawLine(tempp0, tempp1);
                    
                    Handles.color = Color.yellow;
                    var volRotation = trans.rotation * Quaternion.Euler(volume.euler);
                    if (param.airParam.isWorldMode)
                    {
                        volRotation = Quaternion.Euler(volume.euler);
                    }
                    Handles.ArrowCap(0, pos,volRotation, parameter.strength);
                }   
            }
            Handles.color = oldColor;
        }
        
        private void OnDrawGizmos()
        {
            var selectObjs = Selection.objects;
            for (int i = 0; i < selectObjs.Length; i++)
            {
                var selectObj = selectObjs[i];
                if (selectObj == null)
                {
                    return;
                }

                if (selectObj is EditorClip)
                {
                    var innerAsset = (selectObj as EditorClip).clip.asset;
                    if (innerAsset is PhysicsWindPlayableAsset)
                    {
                        var behaviour = (innerAsset as PhysicsWindPlayableAsset).behaviour;
                        var windPlayable = (innerAsset as PhysicsWindPlayableAsset).Wind;
                        if (behaviour != null || windPlayable != null)
                        {
                            var lerpParam = behaviour?.GetLerpParam() ?? windPlayable?.GetLerpParam();
                            if (lerpParam != null)
                            {
                                DrawPhysicsParam(lerpParam);
                            }
                            else
                            {
                                var windParam = behaviour?.GetWinParam() ?? windPlayable?.GetWinParam(); 
                                DrawPhysicsParam(windParam);
                            }
                        }
                    }
                    else if (innerAsset is PhysicsWindDynamicClip physicsWindDynamicClip)
                    {
                        var behaviour = physicsWindDynamicClip.behaviour;
                        var windPlayable = physicsWindDynamicClip.Wind;
                        
                        if (behaviour != null || windPlayable != null)
                        {
                            var lerpParam = behaviour?.GetLerpParam() ?? windPlayable?.GetLerpParam();
                            if (lerpParam != null)
                            {
                                DrawPhysicsParam(lerpParam);
                            }
                            else
                            {
                                var windParam = behaviour?.GetWinParam() ?? windPlayable?.GetWinParam();
                                DrawPhysicsParam(windParam);
                            }
                        }
                    }

                }
                else if (selectObj is PhysicsWindParamAsset)
                {
                    DrawPhysicsParam((selectObj as PhysicsWindParamAsset).physicsWindParam);
                }    
            }
        }
#endif
    }
}