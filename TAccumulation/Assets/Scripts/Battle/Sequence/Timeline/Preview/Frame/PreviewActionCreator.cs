using System;

namespace X3Battle.Timeline.Extension
{
    // 创建预览action的工厂属性类
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = true)]
    public class PreviewActionCreator : System.Attribute
    {
        private readonly Type _previewActionBaseType;
        
        public PreviewActionCreator(Type type)
        {
            _previewActionBaseType = type;
        }

        // 获取预览时的action
        public PreviewActionBase CreatePreviewAction(PreviewActionAsset runtimePreviewAction)
        {
            if (_previewActionBaseType == null)
            {
                return null;
            }

            if (Activator.CreateInstance(_previewActionBaseType) is PreviewActionBase previewAction)
            {
                previewAction.Init(runtimePreviewAction);
                return previewAction;
            }
            
            return null;
        }
    }
}