using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public sealed class PaperMessageDB
{
    private static PaperMessageDB m_Instance = null;

    public static PaperMessageDB Instance
    {
        get
        {
            if (m_Instance == null)
                m_Instance = new PaperMessageDB();

            return m_Instance;
        }
    }


    //private string[] DBColType = { "INTEGER", "REAL", "TEXT" };
    private string tableName = "PhoneMessage";
    private string[] Cols = { "ContactID", "INTEGER", "MessageID", "INTEGER", "ProgressID", "INTEGER", "ReadID", "INTEGER" };

    public PaperMessageDB()
    {
        if (!PaperDBManage.Instance.ExistTable(tableName))
        {
            PaperDBManage.Instance.CreateTable(tableName, Cols);
        }
    }

    private long  hasRecord(int contactID, int messageID)
    {
        string str = "SELECT ID FROM " + tableName + " WHERE " + Cols[0] + " = " + contactID + " AND " + Cols[2] + " =" + messageID;

        object result = PaperDBManage.Instance.ExecuteScalar(str);
        if (result == null) return -1;
        return (long)result;
    }

    private void AddMessagePrograss(int contactID, int messageID, int mvalue)
    {
        string str = "INSERT INTO " + tableName + " VALUES(null," + contactID + ","+ messageID + ","+ mvalue + ",0)";
        PaperDBManage.Instance.ExecuteSql(str);
    }

    private void AddReadPrograss(int contactID, int messageID, int mvalue)
    {
        string str = "INSERT INTO " + tableName + " VALUES(null," + contactID + "," + messageID + ",0," + mvalue + ")";
        PaperDBManage.Instance.ExecuteSql(str);
    }

    private void UpdateDataPrograss(int contactID, int messageID, string col, int mvalue)
    {
        string str = "UPDATE " + tableName + " SET " + col + " = " + mvalue + " WHERE " + Cols[0] + " = " + contactID + " AND " + Cols[2] + " =" + messageID;
        PaperDBManage.Instance.ExecuteSql(str);
    }

    public void SaveMessagProgress(int contactID, int messageID,int conversationID)
    {
        long ID = hasRecord(contactID, messageID);
        if (ID != -1)
            UpdateDataPrograss(contactID, messageID, Cols[4], conversationID);
        else
            AddMessagePrograss(contactID, messageID, conversationID);
    }

    public void SaveReadProgress(int contactID, int messageID, int conversationID)
    {
        long ID = hasRecord(contactID, messageID);
        if (ID != -1)
            UpdateDataPrograss(contactID, messageID, Cols[6], conversationID);
        else
            AddReadPrograss(contactID, messageID, conversationID);
    }

    private int GetValue(string str)
    {
        object result = PaperDBManage.Instance.ExecuteScalar(str);
        if (result == null) return -1;
        return (int)result;
    }

    public int GetMessagProgress(int contactID, int messageID)
    {
        string str = "SELECT "+Cols[4]+" FROM " + tableName + " WHERE " + Cols[0] + " = " + contactID + " AND " + Cols[2] + " =" + messageID;
        return GetValue(str);
    }

    public int GetReadProgess(int contactID, int messageID)
    {
        string str = "SELECT " + Cols[6] + " FROM " + tableName + " WHERE " + Cols[0] + " = " + contactID + " AND " + Cols[2] + " =" + messageID;
        return GetValue(str);
    }
}
