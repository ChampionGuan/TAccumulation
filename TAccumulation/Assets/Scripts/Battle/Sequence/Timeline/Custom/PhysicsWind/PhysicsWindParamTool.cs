using System.Collections.Generic;
using Framework;
using X3.Character;

namespace UnityEngine.Timeline
{
    public static class PhysicsWindParamTool
    {
        // 使用gameObject创建数据
        public static PhysicsWindParam CreateByGameObject(GameObject target)
        {
            X3PhysicsWind wind = GetX3PhysicsWind(target);
            if (wind == null)
            {
                return null;
            }
            
            var data = new PhysicsWindParam();
            data.airParam = wind.GetAirData();
            data.volumeParams = wind.GetVolumeDatas();
            return data;
        }

        // 设置到GameObject上
        public static X3PhysicsWind SetToGameObject(PhysicsWindParam data, GameObject target)
        {
            X3PhysicsWind wind = GetX3PhysicsWind(target);
            if (wind == null)
            {
                return null;
            }

            if (data == null)
            {
                return null;
            }
            _SetVolumeIndividualFollow(data, target.transform);
            wind.SetAirData(data.airParam);
            wind.SetVolumeDatas(data.volumeParams);
            
            wind.SetFollowChildPath(data.followChildPath);

            // 编辑器并且非运行时，设置绑定对象为骨骼节点（timeline编辑器下人物不会动）
            // wind.SetFollowChildPath("Roots/Root_M");
#if UNITY_EDITOR
            // 编辑器下绘制范围辅助线
            PhysicsWindGizmosHelper.EvalDrawGizmosObject(); 
            data.AttachGameObject(wind.GetFollowGameObject());
#endif
            return wind;
        }
        
        // 设置到GameObject上（Lua层会调用过来）
        public static void SetToGameObjectWithParamAsset(PhysicsWindParamAsset asset, GameObject target)
        {
            if (asset == null)
            {
                return;   
            }

            SetToGameObject(asset.physicsWindParam, target);
        }

        
        // 从GameObject上获取X3PhysicsWind组件
        private static X3PhysicsWind GetX3PhysicsWind(GameObject target)
        {
            if (target == null)
            {
                return null;
            }

            X3Character character = target.GetComponent<X3Character>();
            if (character == null)
            {
                return null;
            }

            X3PhysicsWind wind = character.GetSubsystem(X3.Character.ISubsystem.Type.PhysicsWind) as X3PhysicsWind;
            return wind;
        }
        
        /// <summary>
        /// 根据体积场的path动态查它跟随的物体
        /// </summary>
        private static void _SetVolumeIndividualFollow(PhysicsWindParam windParam, Transform bindObjTrans)
        {
            if (windParam.volumeParams != null)
            {
                foreach (var volumeParam in windParam.volumeParams)
                {
                    Transform followTrans = null;
                    if (!string.IsNullOrEmpty(volumeParam.individualFollowPath))
                    {
                        followTrans = bindObjTrans?.Find(volumeParam.individualFollowPath);
                    }
                    volumeParam.individualFollow = followTrans?.gameObject;
                }
            }
        }
    }
}