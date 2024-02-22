using Mono.Data.Sqlite;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using UnityEngine;
using XLua;

[LuaCallCSharp]
[CSharpCallLua]
public class PaperDBManage
{
    private static PaperDBManage m_Instance = null;
    public static PaperDBManage Instance
    {
        get
        {
            if (m_Instance == null)
                m_Instance = new PaperDBManage();

            return m_Instance;
        }
    }


    private const string PATH_DATABASE = "PaperDB.db";
    /// <summary>
    /// 数据库连接
    /// </summary>
    private SqliteConnection SqlConnection;
    /// <summary>
    /// 数据库命令
    /// </summary>
    private SqliteCommand SqlCommand;

    private SqliteDataAdapter SqlDataAdapter;
    /// <summary>
    /// 数据库读取
    /// </summary>
    //private SqliteDataReader SqlDataReader;

    private Hashtable dataHashTable = new Hashtable();


    public PaperDBManage()
    {
        Open();
    }

    private string GetDataPath(string databasePath)
    {
#if UNITY_ANDROID
        return string.Concat("URI=file:", Application.persistentDataPath, "/", databasePath);
#endif
#if UNITY_IOS
        return string.Concat("data source=", Application.persistentDataPath, "/", databasePath);
#endif
        return string.Concat("data source=", Application.streamingAssetsPath, "/", databasePath);
    }

    public void Open()
    {
        try
        {
            SqlConnection = new SqliteConnection(GetDataPath(PATH_DATABASE));
            SqlConnection.Open();
            SqlCommand = SqlConnection.CreateCommand();
            SqlDataAdapter = new SqliteDataAdapter();
        }
        catch (System.Exception e)
        {
            PapeGames.X3.X3Debug.Log(e.ToString());
        }
    }

    public bool ExecuteSql(string command)
    {
        SqlCommand.CommandText = command;
        int mResult = SqlCommand.ExecuteNonQuery();
        return mResult > 0;
    }

    public object ExecuteScalar(string command)
    {
        SqlCommand.CommandText = command;
        object mResult = SqlCommand.ExecuteScalar();
        return mResult;
    }

    public DataTable QueryTable(string command)
    {
        SqlCommand.CommandText = command;
        PapeGames.X3.X3Debug.LogWarning("QueryTable The Sql is:" + command);
        SqliteDataReader dr = SqlCommand.ExecuteReader();
        DataTable mresult = CreateDataTable(dr);
        try
        {
            while (dr.Read())
            {
                DataRow row = mresult.NewRow();
                for (int i = 0; i < dr.FieldCount; i++)
                    row[i] = dr[i];
                mresult.Rows.Add(row);
            }
            dr.Close();
        }
        catch (System.Exception ex)
        {
            PapeGames.X3.X3Debug.LogWarning("ExcuteSql Has Exception :" + ex.Message);
            return null;
        }

        if (mresult.Rows.Count == 0) return null;

        return mresult;
    }

    private DataTable CreateDataTable(SqliteDataReader dr)
    {
        DataTable dt = new DataTable();
        for (int i = 0; i < dr.FieldCount; i++)
        {
            dt.Columns.Add(dr.GetName(i), dr.GetFieldType(i));
        }

        return dt;
    }


    /// <summary>
    /// 关闭数据库
    /// </summary>
    public void Close()
    {
        if (SqlCommand != null)
        {
            SqlCommand.Dispose();
            SqlCommand = null;
        }

        if (SqlConnection != null)
        {
            SqlConnection.Close();
            SqlConnection = null;
        }
    }

    public bool ExistTable(string tableName)
    {
        string strSql = string.Concat("SELECT COUNT(*) FROM sqlite_master where type='table' and name='", tableName, "';");

        SqlCommand.CommandText = strSql;
        int result = System.Convert.ToInt32(SqlCommand.ExecuteScalar());
        return (result > 0);
    }

    public void CreateTable(string tableName, params string[] colInfo)
    {
        string strCreateSql = "Create Table ";
        strCreateSql = string.Concat(strCreateSql, tableName, " (ID INTEGER PRIMARY KEY AUTOINCREMENT,");

        for (int i = 0; i < colInfo.Length; i += 2)
        {
            strCreateSql = string.Concat(strCreateSql,colInfo[i], " ", colInfo[i + 1]);
            if (i < colInfo.Length - 2)
            {
                strCreateSql = string.Concat(strCreateSql,",");
            }
        }

        strCreateSql = string.Concat(strCreateSql, " )");
        PaperDBManage.Instance.ExecuteSql(strCreateSql);
    }
}
