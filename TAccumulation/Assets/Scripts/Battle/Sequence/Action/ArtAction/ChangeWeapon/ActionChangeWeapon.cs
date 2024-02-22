using System.Collections.Generic;
using PapeGames;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using X3.Character;
using X3Battle;

namespace X3Battle
{
    public class ActionChangeWeapon : BSAction
    {
        // 静态数据
        private string _targetPartName;
        
        // 动态数据
        private List<string> _curWeaponList = new List<string>(8);
        private Dictionary<string, bool> _curWeaponStates = new Dictionary<string, bool>(8);
        private GameObject _bindObj;
        private bool _containTargetPart; 
            
        protected override void _OnInit()
        {
            base._OnInit();
            var clipAsset = GetClipAsset<ChangeWeaponClip>();
            
            _targetPartName = clipAsset.weaponPartName;
        }

        protected override void _OnEnter()
        {
            base._OnEnter();
            // TODO 临时处理一下，后面要改preload方式才能彻底解决
            if (Application.isPlaying && X3Battle.Battle.Instance.sequencePlayer.isPreLoading)
            {
                return;
            }
            
            _Reset();
            
            _bindObj = GetTrackBindObj<GameObject>();
            if (_bindObj == null)
            {
                return;
            }
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

        protected override void _OnExit()
        {
            base._OnExit();
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