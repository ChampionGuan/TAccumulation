namespace X3Game
{
    public static class GameDefines
    {
        public const string APPINFO_FILE_NAME = @"AppInfo.json";
        public const string APPINFO_PLAIN_FILE_NAME = @"AppInfoPlain.json";
        public const string APPINFO_AES_KEY = "x3isperfect";
        public const string APPINFO_AES_IV = "x3isperfect";
    }

    public enum RegionType
    {
        /// <summary>
        /// 中国大陆
        /// </summary>
        ChinaMainland = 1,

        /// <summary>
        /// 港澳台
        /// </summary>
        ChinaOther = 2,

        /// <summary>
        /// 欧美、东南亚
        /// </summary>
        AmericaEuropeAsia = 3,

        /// <summary>
        /// 日本
        /// </summary>
        Japan = 4,

        /// <summary>
        /// 韩国
        /// </summary>
        SouthKorea = 5,
    }
}