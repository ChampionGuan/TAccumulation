namespace X3Battle
{
    /// <summary>
    /// buff添加前进行判断拦截
    /// </summary>
    public interface IBuffAddSection
    {
        bool InterceptBuffAdd(BuffCfg config);
    }
}

