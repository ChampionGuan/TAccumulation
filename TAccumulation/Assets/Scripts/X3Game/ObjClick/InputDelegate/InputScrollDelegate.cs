namespace X3Game
{
    [XLua.CSharpCallLua]
    public interface InputScrollDelegate : InputBaseDelegate
    {
        void OnBeginScrollWheel(float scrollWheel, float delta);
        void OnScrollWheel(float scrollWheel, float delta);
        void OnEndScrollWheel(float scrollWheel, float delta);
    }
}