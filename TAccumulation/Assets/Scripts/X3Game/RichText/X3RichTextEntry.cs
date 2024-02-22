using System.Collections.Generic;
using PapeGames.X3UI;
#if UNITY_EDITOR
using UnityEditor;
using OfficeOpenXml;
using System.IO;
#endif

namespace X3Game
{
    [XLua.LuaCallCSharp]
    public static class X3RichTextEntry
    {
        static bool s_Inited = false;
        static Dictionary<string, string> s_EmojiFileNameDict = new Dictionary<string, string>();

        public static void Init()
        {
            if(s_Inited)
            {
                return;
            }
            ExeInit();
#if UNITY_EDITOR
            InitEmojiTagToFileNameInEditor();
#endif
            s_Inited = true;
        }

        static void ExeInit()
        {
            RichText.SetDelegate(new SharpRichTextDelegate());
            RichText.DebugMode = false;
            RichText.TagIgnoreCase = false;

            //图片
            var item = new RichText.TagPattern();
            {
                item.TagType = RichText.TagType.Img;
                item.Pattern = @"<img=.*?\s*/?>";
                item.Name = "img";
                item.PrefabPath = "Assets/Build/Res/GameObjectRes/RichText/Resources/UrlImg.prefab";
                item.AddAttr("src", @"(?<=img\=)[^\s]*?(?=(\s|/>|>))");
                item.AddAttr("dft", @"(?<=dft\=)[^\s]*?(?=(\s|/>|>))");
                item.AddAttr("width", @"(?<=width\=)[^\s]*?(?=(\s|/>|>))");
                item.AddAttr("height", @"(?<=height\=)[^\s]*?(?=(\s|/>|>))");
                item.AddAttr("valign", @"(?<=valign\=)[^\s]*?(?=(\s|/>|>))");
                item.Size = new UnityEngine.Vector2(60, 60);
                item.VAlign = RichText.VerticalAlignment.Bottom;
            }
            RichTextPatternRegistry.AddObjectPattern(item);

            //表情1
            item = new RichText.TagPattern();
            {
                item.TagType = RichText.TagType.Emoji;
                item.Pattern = @"\[表情：[^\]]*?\]";
                item.Name = "emoji";
                item.PrefabPath = "Assets/Build/Res/GameObjectRes/RichText/Resources/Emoji.prefab";
                item.Size = new UnityEngine.Vector2(60, 60);
                item.AdjustHeightByLine = true;
                item.VAlign = RichText.VerticalAlignment.Center;
                item.NeedTagString = true;
                item.PercentageFromLineHeight = 1.2f;
            }
            RichTextPatternRegistry.AddObjectPattern(item);

            //表情2
            item = new RichText.TagPattern();
            {
                item.TagType = RichText.TagType.Emoji;
                item.Pattern = @"\[p\:[^\]]*?\]";
                item.Name = "emoji";
                item.PrefabPath = "Assets/Build/Res/GameObjectRes/RichText/Resources/Emoji.prefab";
                item.Size = new UnityEngine.Vector2(60, 60);
                item.AdjustHeightByLine = true;
                item.VAlign = RichText.VerticalAlignment.Center;
                item.NeedTagString = true;
                item.PercentageFromLineHeight = 1.2f;
            }
            RichTextPatternRegistry.AddObjectPattern(item);

            //表情3
            item = new RichText.TagPattern();
            {
                item.TagType = RichText.TagType.Emoji;
                item.Pattern = @"\[金币[^\]]*?\]|\[钻石[^\]]*?\]|\[体力[^\]]*?\]|\[星钻[^\]]*?\]";
                item.Name = "emoji";
                item.PrefabPath = "Assets/Build/Res/GameObjectRes/RichText/Resources/Emoji.prefab";
                item.Size = new UnityEngine.Vector2(60, 60);
                item.AdjustHeightByLine = true;
                item.VAlign = RichText.VerticalAlignment.Center;
                item.NeedTagString = true;
                item.PercentageFromLineHeight = 1.2f;
            }
            RichTextPatternRegistry.AddObjectPattern(item);

            //表情4
            item = new RichText.TagPattern();
            {
                item.TagType = RichText.TagType.Emoji;
                item.Pattern = @"\[ItemID\:[^\]]*?\]";
                item.Name = "emoji";
                item.PrefabPath = "Assets/Build/Res/GameObjectRes/RichText/Resources/Emoji.prefab";
                item.Size = new UnityEngine.Vector2(60, 60);
                item.AdjustHeightByLine = true;
                item.VAlign = RichText.VerticalAlignment.Center;
                item.NeedTagString = true;
                item.PercentageFromLineHeight = 1.2f;
            }
            RichTextPatternRegistry.AddObjectPattern(item);
        }

        public static bool UpdateEmojiFileName(string tagName, string fileName)
        {
            if (string.IsNullOrEmpty(tagName) || string.IsNullOrEmpty(fileName))
                return false;
            s_EmojiFileNameDict[tagName] = fileName;
            return true;
        }

        public static string GetEmojiFileName(string tagName)
        {
            if (!s_EmojiFileNameDict.TryGetValue(tagName, out string fileName))
                return null;
            return fileName;
        }

        static X3RichTextEntry()
        {
            Init();
        }

#if UNITY_EDITOR
        [InitializeOnLoadMethod]
        static void InitInEditor()
        {
            Init();
        }

        static void InitEmojiTagToFileNameInEditor()
        {
            using (FileStream stream = File.Open(Path.Combine(UnityEngine.Application.dataPath, "../../Binaries/Tables/OriginTable/Emoji.xlsx"), FileMode.Open, FileAccess.Read))
            {
                ExcelPackage excelPackage = new ExcelPackage(stream);
                ExcelWorksheet excelWorksheet = excelPackage.Workbook.Worksheets[1];
                int rows = excelWorksheet.Cells.Rows;
                for (int i = 4; i <= rows; i++)
                {
                    string tagName = excelWorksheet.Cells[i, 3].Text;
                    if (string.IsNullOrEmpty(tagName) || string.IsNullOrWhiteSpace(tagName))
                        break;
                    if (!string.IsNullOrEmpty(tagName))
                        tagName = tagName.Trim();
                    string fileName = excelWorksheet.Cells[i, 4].Text;
                    if (!string.IsNullOrEmpty(fileName))
                        fileName = fileName.Trim();
                    UpdateEmojiFileName(tagName, fileName);
                }
            }
        }
#endif
    }
}
