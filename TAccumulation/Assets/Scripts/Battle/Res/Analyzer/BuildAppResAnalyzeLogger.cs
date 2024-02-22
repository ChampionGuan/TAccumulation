using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using PapeGames.X3;
using UnityEngine;
using Debug = UnityEngine.Debug;
using Object = UnityEngine.Object;

namespace X3Battle
{
    public class BuildAppResAnalyzeLogger : ILogHandler
    {
        private StringBuilder _sb = new StringBuilder(2048); 
        private StreamWriter _sw;
        private ILogHandler _unityDebugLog;
        private bool _previousEnableStack;
        private HashSet<string> _logWithTrace = new HashSet<string>();

        private string _logFilePath
        {
            get
            {
                string fileName = "BuildAppResAnalyzeLog.log";
                if (Application.isEditor)
                {
                    return Application.dataPath + "../../Library/ResourcesPacker/"+ $"{fileName}";
                }
                else
                {
                    return Application.persistentDataPath + $"/{fileName}";
                }
            }   
        }
        
        public void Register()
        {
            try
            {
                if (File.Exists(_logFilePath))
                    File.Delete(_logFilePath);
                _sw = new StreamWriter(File.OpenWrite(_logFilePath));
                _sw.AutoFlush = false;
            }
            catch (Exception e)
            {
                LogException(e, null);
                return;
            }
            
            Debug.LogWarning("BuildAppResAnalyzeLogger提示信息：Unity的logHandle将会被替换掉");
            _unityDebugLog = Debug.unityLogger.logHandler;
            Debug.unityLogger.logHandler = this;
            
            // 测试
            // LogProxy.LogFormat("BattleLogger测试：{0}", "log测试");
            // LogProxy.LogWarningFormat("BattleLogger测试：{0}", "warning测试");
            // LogProxy.LogErrorFormat("BattleLogger测试：{0}", "Error测试");
            // LogProxy.LogFatalFormat("BattleLogger测试：{0}", "Fatal测试");
        }
        
        public void UnRegister()
        {
            WriteToLocal(_sb);
            _sw?.Close();
            _logWithTrace = new HashSet<string>();
            
            if (_unityDebugLog != null)
            {
                Debug.unityLogger.logHandler = _unityDebugLog;
                Debug.LogWarning("BattleLog提示信息：还原Unity的logHandle, type:" + _unityDebugLog.GetType());
            }
            Debug.Log("BuildAppResAnalyzeLogger日志控制结束，log信息输出位置：" + _logFilePath);
        }
            
        public void LogFormat(LogType logType, Object context, string format, params object[] args)
        {
            switch (logType)
            {
                case LogType.Log:
                case LogType.Warning:
                    return;
                case LogType.Error:
                case LogType.Assert:
                case LogType.Exception:
                    break;
            }
            // 超过阈值，写入本地一次
            if (_sb.Length > _sb.Capacity * 0.8f)
            {
                WriteToLocal(_sb);
                _sb.Clear();
            }

            string str = string.Format(format, args);
            // 相同的Error信息不做重复打印
            if (!_logWithTrace.Add(str))
                return;
            _sb.AppendFormat(format, args);

            // 如果需要堆栈的，Console上也输出一下。 便于使用Error的自动通知
            _unityDebugLog?.LogFormat(logType, context, format, args);
        }
 
        public void LogException(Exception exception, Object context)
        {
            if (exception == null)
                throw new ArgumentNullException(nameof (exception));
            LogFormat(LogType.Exception, context, "{0}", exception.ToString());
        }

        private void WriteToLocal(StringBuilder sb)
        {
            try
            {
                if (_sw == null)
                    return;
                
                for (int i = 0; i < sb.Length; i++)
                    _sw.Write(sb[i]);
                _sw.Flush();
            }
            catch (Exception e)
            {
                LogException(e, null);
            }
        }
    }
}