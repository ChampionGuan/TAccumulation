using System;
using Framework;
using PapeGames.X3;
using UnityEditor;
using UnityEngine;
using UnityEngine.Serialization;
using X3Battle;
using X3Game;
using EventType = X3Battle.EventType;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    [XLua.CSharpCallLua]
    [MonoSingletonAttr(true, "SdkMgr", true)]
    public class AirAutoTest : MonoSingleton<AirAutoTest>
    {
        private bool _isBegin = false;
        private bool _isEnd = false; 
        private OfflineBattleFramework _battleFramework;
        private int _index = 0;
        private string PATH = Application.persistentDataPath + "/";
        public static readonly string FILE_NAME = "TestAB_Index=";
        public static void Initialize()
        {
            AirAutoTest.CreateInstance();
        }
        public void BeginTest()
        {
            // 监听战斗的启动流程完成回调
            BattleClient.OnStartupFinished.RemoveListener(_OnBattleStart);
            BattleClient.OnStartupFinished.AddListener(_OnBattleStart);
            _isBegin = true;
            _index = 0;
            _AutoBattle();
        }

        private void _AutoBattle()
        {
            _index++;
            //开启AB测试
            GameMgr.TestMarkAB(true);
            //开始战斗
            X3Battle.Debugger.Utils.TestStartBattle(10352,200011,1,210101,2101, 71010);
        }
        private void Update()
        {
            if (!_isBegin)
            {
                return;
            }


            if (_isEnd)
            {
                _AutoBattle();
                _isEnd = false;
            }
        }
    
        private void _OnBattleStart()
        {
            if (BattleClient.Instance.battle != null)
            {
                BattleClient.Instance.battle.eventMgr.RemoveListener<ECEventDataBase>(EventType.OnLevelStart, _OnBattleStart);
                BattleClient.Instance.battle.eventMgr.AddListener<ECEventDataBase>(EventType.OnLevelStart, _OnBattleStart, "_OnBattleStart");
                
                //监听battle的战斗结束
                BattleClient.Instance.battle.eventMgr.RemoveListener<EventBattleEnd>(EventType.OnBattleEnd, _OnBattleEnd);
                BattleClient.Instance.battle.eventMgr.AddListener<EventBattleEnd>(EventType.OnBattleEnd,  _OnBattleEnd, "_OnBattleEnd");

                BattleClient.Instance.SetUnityTimescale(2);
            }
        }
        private void _OnBattleStart(ECEventDataBase arg)
        {
            if (CheckModel())
            {
                _isEnd = false;
                _isBegin = false;
            }
            if (Battle.Instance.actorMgr.girl == null || Battle.Instance.actorMgr.boy == null)
            {
                return;
            }

            Battle.Instance.actorMgr.girl.attributeOwner.SetAttrValue(AttrType.PhyAttack, 100000);
        }
        
        private void _OnBattleEnd(EventBattleEnd arg)
        {
            //存入AB信息
            GameMgr.TestMarkAB(false, PATH + FILE_NAME + _index + ".json");
            _isEnd = true;
            if (CheckModel())
            {
                _isEnd = false;
                _isBegin = false;
            }
        }

        /// <summary>
        /// 检查有没有出问题
        /// </summary>
        /// <returns></returns>
        public bool CheckModel()
        {
            if (Battle.Instance.actorMgr.girl == null || Battle.Instance.actorMgr.boy == null)
            {
                return false;
            }
            
            //捏脸检查
            var modelGraph = PlayableAnimationManager.Instance()?.FindPlayGraph(Battle.Instance.actorMgr.girl.GetDummy().gameObject);
            var fallbackAnim = modelGraph?.GetFallBackAnimation();
            if (null != modelGraph && modelGraph.Active)
            {
                Debug.LogError("检查出错：保底动画没初始化 出错场次 = " + _index);
                Battle.Instance.SetWorldEnable(false);
                return true;
            }
            else if(fallbackAnim != null && !fallbackAnim.cachedPlayableGraph.IsValid())
            {
                Debug.LogError("检查出错：保底动画Graph失效 出错场次 = " + _index);
                Battle.Instance.SetWorldEnable(false);
                return true;
            }
            
            //检查rander
            var girlModel = Battle.Instance.actorMgr.girl.GetDummy();
            var girlRenders = girlModel.GetComponentsInChildren<SkinnedMeshRenderer>();
            if (_CheckRender(girlRenders) == false)
            {
                Battle.Instance.SetWorldEnable(false);
                return true;
            }
            var boyModel = Battle.Instance.actorMgr.boy.GetDummy();
            var boyRenders = boyModel.GetComponentsInChildren<SkinnedMeshRenderer>();
            if (_CheckRender(boyRenders) == false)
            {
                Battle.Instance.SetWorldEnable(false);
                return true;
            }

            return false;
        }

        private bool _CheckRender(SkinnedMeshRenderer[] renders)
        {
            foreach (var meshRenderer in renders)
            {
                if (meshRenderer.sharedMesh == null)
                {
                    Debug.LogError("检查出错：Mesh丢失 丢失的部位 = " + meshRenderer.gameObject.transform.name + "出错场次 = " + _index);
                    return false;
                }

                foreach (var material in meshRenderer.sharedMaterials)
                {
                    if (material == null)
                    {
                        Debug.LogError("检查出错：material丢失 丢失的部位 = " + meshRenderer.gameObject.transform.name + "出错场次 = " + _index);
                        return false;
                    }

                    if (material.shader.name.IndexOf("error", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        Debug.LogError("检查出错：shader错判 丢失的部位 = " + meshRenderer.gameObject.transform.name + "出错场次 = " + _index);
                        return false;
                    }
                }
            }

            return true;
        }

        public void DoDisconnection()
        {
            BattleEnv.LuaBridge.DoDisconnection();
        }
    }
}


