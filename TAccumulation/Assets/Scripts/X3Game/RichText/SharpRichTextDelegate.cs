using UnityEngine;
using PapeGames.X3;
using PapeGames.X3UI;

namespace X3Game
{
    public class SharpRichTextDelegate : IRichTextDelegate
    {
        public RichTextItem GetRichItem(RichText parent, RichText.TagItem tagItem)
        {
            GameObject ins = X3AssetInsProvider.Instance.GetInsWithAssetPath(tagItem.TagMatch.Pattern.PrefabPath);
            if (!Res.Inited || ins == null)
            {
                var path = tagItem.TagMatch.Pattern.PrefabPath;
                var prefab = Resources.Load<GameObject>(System.IO.Path.GetFileNameWithoutExtension(path));
                ins = GameObject.Instantiate<GameObject>(prefab);
            }

            RichTextItem ri = null;
            if (ins == null || (ri = ins.GetComponent<RichTextItem>()) == null)
            {
                X3Debug.LogErrorFormat("Failed to get rich item ins or invalid ins.");
                return null;
            }
            ri.transform.localPosition = Vector3.zero;
            return ri;
        }

        public bool ReleaseRichItem(RichText parent, RichTextItem ri)
        {
            if (ri == null)
                return false;
            bool ret = true;
            X3AssetInsProvider.Instance.ReleaseIns(ri.gameObject);
            return ret;
        }
    }
}
