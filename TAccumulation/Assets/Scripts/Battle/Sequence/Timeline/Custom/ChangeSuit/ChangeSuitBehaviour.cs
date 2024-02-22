using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using X3Battle;

namespace PapeGames
{
    public class ChangeSuitBehaviour : InterruptBehaviour
    {
        private const int CAPACITY = 8;
        
        private bool _useOriginal;  // 是否使用origin的形象
        private int _targetSuitID;  // 目标suitID
        private int _bindSuitID;  // 绑定的suitID

        // 动态数据
        private GameObject _bindObject;
        private readonly HashSet<string> _hideParts = new HashSet<string>();  // 隐藏了哪些部件
        private readonly HashSet<string> _showParts = new HashSet<string>();  // 显示了哪些部件
        private readonly List<string> _allParts = new List<string>(CAPACITY);
        private readonly HashSet<string> _allPartSet = new HashSet<string>();
        private readonly List<string> _weaponParts = new List<string>(CAPACITY);
        private readonly HashSet<string> _weaponPartSet = new HashSet<string>();
        private readonly HashSet<string> _targetPartSet = new HashSet<string>();
        
        public void Init(bool useOriginal, int targetSuitID, int bindSuitID)
        {
            _useOriginal = useOriginal;
            _targetSuitID = targetSuitID;
            _bindSuitID = bindSuitID;
            // 运行时扩容一下HashSet
            if (Application.isPlaying)
            {
                using (zstring.Block())
                {
                    for (int i = 0; i < CAPACITY; i++)
                    {
                        var strs = (zstring)i;
                        _hideParts.Add(strs);
                        _showParts.Add(strs);
                        _allPartSet.Add(strs);
                        _weaponPartSet.Add(strs);
                        _targetPartSet.Add(strs);
                    }   
                }   
                _Clear();
            }
        }

        private void _Clear()
        {
            _bindObject = null;
            _hideParts.Clear();
            _showParts.Clear();
            _allParts.Clear();
            _allPartSet.Clear();
            _weaponParts.Clear();
            _weaponPartSet.Clear();
            _targetPartSet.Clear();
        }
        
        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            _Clear();
            _bindObject = playerData as GameObject;
            
            // 获取当前人物所有的部件列表
            CharacterMgr.GetAllParts(_bindObject, _allParts);
            foreach (var partName in _allParts)
            {
                _allPartSet.Add(partName);
            }

            // 获取当前人物武器部件列表
            CharacterMgr.GetPartNamesWithPartType(_bindObject, (int)PartType.Weapon, _weaponParts);
            foreach (var partName in _weaponParts)
            {
                _weaponPartSet.Add(partName);
            }

            // 获取目标suitID的部件列表
            var targetSuitID = ChangeSuitUtil.GetUsingSuitID(_useOriginal, _targetSuitID, _bindSuitID);
            BattleCharacterMgr.GetBase2PartKeysBySuitID(targetSuitID, out var destPartKeys, out var _);
            if (destPartKeys != null)
            {
                foreach (var partName in destPartKeys)
                {
                    _targetPartSet.Add(partName);
                }
            }

            // 找出哪些需要隐藏，哪些需要添加
            foreach (var partName in _allParts)
            {
                // 只处理非武器部件
                if (!_weaponPartSet.Contains(partName))
                {
                    var visible = CharacterMgr.GetPartVisibility(_bindObject, partName);
                    if (_targetPartSet.Contains(partName) && !visible)
                    {
                        // 目标需要有，但是却不可见，标记为需要显示
                        _showParts.Add(partName);
                    }
                    else if (!_targetPartSet.Contains(partName) && visible)
                    {
                        // 目标不需要，但是却可见，标记为需要隐藏
                        _hideParts.Add(partName);
                    }
                }
            }

            // 显隐设置一波
            foreach (var partName in _showParts)
            {
                CharacterMgr.HidePart(_bindObject, partName, false);
            }

            foreach (var partName in _hideParts)
            {
                CharacterMgr.HidePart(_bindObject, partName, true);       
            }

            // 没有的，全新添加的需要加入，并且标记为显示
            foreach (var partName in _targetPartSet)
            {
                if (!_allPartSet.Contains(partName))
                {
                    BattleCharacterMgr.AddPart(_bindObject, partName, false, autoSyncLod: false);
                    _showParts.Add(partName);
                }
            }
        }

        protected override void OnStop()
        {
            // 结束时把改过显隐的部件还原
            foreach (var partName in _showParts)
            {
                CharacterMgr.HidePart(_bindObject, partName, true);   
            }

            foreach (var partName in _hideParts)
            {
                CharacterMgr.HidePart(_bindObject, partName, false);        
            }
        }
    }
}