using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using X3Battle;

namespace PapeGames
{
    public static class ChangeSuitUtil
    {
        // 通过参数获取目标SuitID
        public static int GetUsingSuitID(bool useOriginal, int targetSuitID, int bindSuitID)
        {
            if (Application.isPlaying)
            {
                if (useOriginal)
                {
                    var isGirl = BattleUtil.IsGirlSuit(bindSuitID);
                    if (isGirl)
                    {
                        return X3Battle.Battle.Instance.arg.girlSuitID;
                    }
                    else
                    {
                        return X3Battle.Battle.Instance.arg.boySuitID;
                    }
                }
                else
                {
                    return targetSuitID;
                }
            }
            else
            {
                return targetSuitID;
            }
        }

        // 预加载ChangeSuit（编辑器和运行时都可以用）
        private static readonly HashSet<int> _targetSuitIDSet = new HashSet<int>();
        private static readonly List<string> _allParts = new List<string>();
        private static readonly HashSet<string> _allPartSet = new HashSet<string>();
        private static readonly HashSet<string> _targetPartSet = new HashSet<string>();
        public static void PreloadChangeSuit(GameObject bindObj, ChangeSuitTrack track)
        {
            if (bindObj == null)
            {
                return;
            }
            
            var extData = track.extData;
            if (extData == null)
            {
                return;
            }  
            
            _targetSuitIDSet.Clear();
            _allParts.Clear();
            _allPartSet.Clear();
            _targetPartSet.Clear();
            
            // 收集需要加载的套装
            var clipsArray = track.GetClipsArray();
            foreach (var clip in clipsArray)
            {
                if (clip.asset is ChangeSuitClip suitClip)
                {
                    var suitID = GetUsingSuitID(suitClip.useOriginal, suitClip.targetSuitID, extData.bindSuitID);
                    _targetSuitIDSet.Add(suitID);
                } 
            }
            
            // 获取当前人物所有的部件列表
            CharacterMgr.GetAllParts(bindObj, _allParts);
            foreach (var partName in _allParts)
            {
                _allPartSet.Add(partName);
            }
            
            // 获取目标suitID的部件列表
            foreach (var targetSuitID in _targetSuitIDSet)
            {
                BattleCharacterMgr.GetBase2PartKeysBySuitID(targetSuitID, out var destPartKeys, out var _);   
                if (destPartKeys != null)
                {
                    foreach (var partName in destPartKeys)
                    {
                        _targetPartSet.Add(partName);
                    }
                }
            }
            
            // 没有的，全新添加的需要加入，并且隐藏掉
            foreach (var partName in _targetPartSet)
            {
                if (!_allPartSet.Contains(partName))
                {
                    BattleCharacterMgr.AddPart(bindObj, partName, false, autoSyncLod: false);
                    BattleCharacterMgr.HidePart(bindObj, partName, true);
                }
            }
        }
    }
}