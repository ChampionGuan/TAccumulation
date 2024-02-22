using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine.Playables;
using X3.Character;
using X3Battle;

namespace UnityEngine.Timeline
{
    public class ChangeWeaponBehaviour : InterruptBehaviour
    {
        // 静态数据
        private string _targetPartName;
        
        // 动态数据
        private List<string> _curWeaponList = new List<string>(8);
        private Dictionary<string, bool> _curWeaponStates = new Dictionary<string, bool>(8);
        private GameObject _bindObj;
        private bool _containTargetPart; 
            
        public void SetData(string weaponPartName)
        {
            _targetPartName = weaponPartName;
        }
        
        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            // TODO 临时处理一下，后面要改preload方式才能彻底解决
            if (Application.isPlaying && X3Battle.Battle.Instance.sequencePlayer.isPreLoading)
            {
                return;
            }
            
            _Reset();
            
            _bindObj = playerData as GameObject;
            if (_CheckParamValid())
            {
                CharacterMgr.GetPartNamesWithPartType(_bindObj, (int)PartType.Weapon, _curWeaponList);
                foreach (var curPartName in _curWeaponList)
                {
                    var oldVisible = CharacterMgr.GetPartVisibility(_bindObj, curPartName);
                    _curWeaponStates.Add(curPartName, oldVisible);
                    
                    if (curPartName == _targetPartName)
                    {
                        // 含有则标记一下
                        _containTargetPart = true;
                        if (!oldVisible)
                        {
                            // 之前隐藏的话就把它打开
                            CharacterMgr.HidePart(_bindObj, curPartName, false);   
                        }
                    }
                    else
                    {
                        // 不同则直接隐藏
                        CharacterMgr.HidePart(_bindObj, curPartName, true);
                    }
                }

                if (!_containTargetPart)
                {
                    // 不含有添加新的
                    BattleCharacterMgr.AddPart(_bindObj, _targetPartName, false, autoSyncLod: false);
                }
            }
        }
                                                              
        protected override void OnStop()
        {
            // TODO 临时处理一下，后面要改preload方式才能彻底解决
            if (Application.isPlaying && X3Battle.Battle.Instance.sequencePlayer.isPreLoading)
            {
                return;
            }
            
            if (_CheckParamValid())
            {
                foreach (var curPartName in _curWeaponList)
                {
                    if (_curWeaponStates.ContainsKey(curPartName))
                    {
                        CharacterMgr.HidePart(_bindObj, curPartName, !_curWeaponStates[curPartName]);     
                    }
                }

                if (!_containTargetPart)
                {
                    // 不含有需要移除
                    // CharacterMgr.RemovePart(_bindObj, _targetPartName);
                    // 不含有需要隐藏
                    CharacterMgr.HidePart(_bindObj, _targetPartName, true);    
                }
            }
        }

        private bool _CheckParamValid()
        {
            return _bindObj != null;
        }

        private void _Reset()
        {
            _curWeaponList.Clear();
            _curWeaponStates.Clear();
            _bindObj = null;
            _containTargetPart = false;
        }
    }
}