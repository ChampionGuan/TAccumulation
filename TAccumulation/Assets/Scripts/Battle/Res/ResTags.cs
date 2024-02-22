using System;
using System.Collections.Generic;
using ParadoxNotion;
using UnityEngine;

namespace X3Battle
{
    public class ResTags
    {
        private Dictionary<BattleResTag, HashSet<ResDesc>> _tagRes;
        private List<BattleResTag> _listTags;
        private Dictionary<BattleResType, HashSet<String>> _allAnalyzedRes;
        public bool isInit => _tagRes.Count > 0;
        
        public ResTags()
        {
            _tagRes = new Dictionary<BattleResTag, HashSet<ResDesc>>();
            var tags = Enum.GetValues(typeof(BattleResTag));
            _listTags = new List<BattleResTag>();
            foreach (var value in tags)
            {
                var tag = (BattleResTag)value;
                if (tag != BattleResTag.Default)
                {
                    _listTags.Add(tag);
                }
            }
            _allAnalyzedRes = new Dictionary<BattleResType, HashSet<string>>();
        }

        // lua端调用,时机：资源分析阶段完成后，立即Init.
        public void Init(ResModule resModule)
        {
            if (resModule == null)
                return;
            HashSet<ResModule> result = new HashSet<ResModule>(); 
            GetResModuleHaveTags(resModule, result);
            var resultInfos = new Dictionary<BattleResType, Dictionary<string, ResDesc>>();
            foreach (var resModuleItem in result)
            {
                ResAnalyzeUtil.GetResult(resultInfos, resModuleItem);
            }

            foreach (var resultInfo in resultInfos)
            {
                foreach (var resDesc in resultInfo.Value)
                {
                    AddTagRes(resDesc.Value);
                }
            }

            if (Application.isEditor)
            {
                WriteAnalyzedResToLocal();
            }
        }
        
        public HashSet<ResDesc> GetDependRes(BattleResTag tag)
        {
            if (_tagRes == null)
                return null;
            _tagRes.TryGetValue(tag, out var listRes);
            return listRes;
        }

        public bool IsResAnalyzed(BattleResType type, string relativePath)
        {
            if (_allAnalyzedRes.TryGetValue(type, out var hashSetStrs))
            {
                return hashSetStrs.Contains(relativePath);
            }
            return false;
        }

        private void AddTagRes(ResDesc resDesc)
        {
            if (resDesc.IsHaveTag(BattleResTag.Analyzed))
            {
                if (!_allAnalyzedRes.TryGetValue(resDesc.type, out var hashSetStrs))
                {
                    hashSetStrs = new HashSet<string>();
                    _allAnalyzedRes[resDesc.type] = hashSetStrs;
                }
                hashSetStrs.Add(resDesc.path);
            }
            
            foreach (var tag in _listTags)
            {
                if (!resDesc.IsHaveTag(tag))
                {
                    continue;
                }

                if (!_tagRes.TryGetValue(tag, out var hashSetRes))
                {
                    hashSetRes = new HashSet<ResDesc>();
                    _tagRes[tag] = hashSetRes;
                }
                hashSetRes.Add(resDesc);
            }
        }

        private void GetResModuleHaveTags(ResModule resModule, HashSet<ResModule> result)
        {
            if (resModule == null)
                return;
            if (resModule.tags == BattleResTag.Default)
                return;
            
            result?.Add(resModule); 
            foreach (var child in resModule.children)
            {
                GetResModuleHaveTags(child, result);
            }
        }

        public void WriteAnalyzedResToLocal()
        {
            string fullPath = UnityEngine.Application.persistentDataPath + "/AllAnalyzedResInfo.csv";
            using (System.IO.StreamWriter writer = new System.IO.StreamWriter(fullPath, false))
            {
                var HeadInfo = "资源类型,资源相对路径";
                writer.WriteLine(HeadInfo);
                foreach (var item in _allAnalyzedRes)
                {
                    foreach (var resPath in item.Value)
                    {
                        writer.WriteLine("{0},{1}",item.Key, resPath);
                    }
                }
            }
            PapeGames.X3.LogProxy.LogFormat("分析过的资源信息写入本地成功，位置：{0}", fullPath);
        }
    }
}