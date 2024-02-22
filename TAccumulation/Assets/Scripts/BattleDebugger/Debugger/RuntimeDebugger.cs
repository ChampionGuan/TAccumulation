#if DEBUG_GM || UNITY_EDITOR
namespace X3Battle.Debugger
{
    public class RuntimeDebugger : IDebugger
    {
        public string name => "真机调试";

        public void OnEnter()
        {
        }

        public void OnExit()
        {
        }

        public void OnGUI()
        {
        }
    }
}
#endif