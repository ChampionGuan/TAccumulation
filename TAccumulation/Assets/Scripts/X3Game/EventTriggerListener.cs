using UnityEngine;
using System.Collections;

using System;
using UnityEngine.EventSystems;
using System.Collections.Generic;
using PapeGames.X3UI;

[XLua.CSharpCallLua]
public class EventTriggerListener : UnityEngine.EventSystems.EventTrigger,UnityEngine.EventSystems.IDragHandler, IUIComponent
{
	public Action<GameObject, PointerEventData> onBeginDragEvent;
    public Action<GameObject, PointerEventData> onEndDragEvent;
    public Action<GameObject, BaseEventData> onCancelEvent;
	public Action<GameObject, BaseEventData> onDeselectEvent;
	public Action<GameObject, PointerEventData> onDragEvent;
	public Action<GameObject, PointerEventData> onDropEvent;
	public Action<GameObject, PointerEventData> onInitializePotentialDragEvent;
	public Action<GameObject, AxisEventData> onMoveEvent;
	public Action<GameObject, PointerEventData> onPointerClickEvent;
	public Action<GameObject, PointerEventData> onPointerDownEvent;
	public Action<GameObject, PointerEventData> onPointerEnterEvent;
	public Action<GameObject, PointerEventData> onPointerExitEvent;
	public Action<GameObject, PointerEventData> onPointerUpEvent;
	public Action<GameObject, PointerEventData> onScrollEvent;
	public Action<GameObject, BaseEventData> onSelectEvent;
	public Action<GameObject, BaseEventData> onSubmitEvent;
	public Action<GameObject, BaseEventData> onUpdateSelectedEvent;
    List<RaycastResult> results = new List<RaycastResult>();

    bool isPassEvent = false;
    Dictionary<Action<GameObject, PointerEventData>,bool> noPassEventDic = new Dictionary<Action<GameObject, PointerEventData>,bool>();


    static public EventTriggerListener Get (GameObject go)
	{
		EventTriggerListener listener = go.GetComponent<EventTriggerListener>();
		if (listener == null) listener = go.AddComponent<EventTriggerListener>();
		return listener;
	}

	public void SetEnablePassEvent(bool is_enable)
	{
		isPassEvent = is_enable;
	}

    /// <summary>
    /// 动态设置某个事件是否需要传递下去
    /// </summary>
    /// <param name="noPassEvent"></param>
    /// <param name="isNoPass"></param>
    public void  SetPassEvent(Action<GameObject, PointerEventData> passEvent,bool isNoPass = true)
    {
        if (passEvent == null) { return; }
        if (!noPassEventDic.ContainsKey(passEvent))
        {
            noPassEventDic.Add(passEvent, isNoPass);
        }
        else
        {
            noPassEventDic[passEvent] = isNoPass;
        }
    }

    bool CheckIfCanPass(Action<GameObject, PointerEventData> noPassEvent)
    {
        return isPassEvent && (noPassEvent==null || (noPassEvent!=null && (!noPassEventDic.ContainsKey(noPassEvent) || noPassEventDic[noPassEvent])));
    }

    public override void OnBeginDrag(PointerEventData eventData)
	{
		if(onBeginDragEvent != null)
		{
			onBeginDragEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onBeginDragEvent))
        {
            PassEvent(eventData, ExecuteEvents.beginDragHandler);
        }
    }

    public override void OnEndDrag(PointerEventData eventData)
    {
        if (onEndDragEvent != null)
        {
            onEndDragEvent(this.gameObject, eventData);
        }

        if (CheckIfCanPass(onEndDragEvent))
        {
            PassEvent(eventData, ExecuteEvents.endDragHandler);
        }
    }

    public override void OnCancel(BaseEventData eventData)
	{
		if(onCancelEvent != null)
		{
			onCancelEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onCancelEvent))
        {
            PassEvent(eventData, ExecuteEvents.cancelHandler);
        }
    }

	public override void OnDeselect(BaseEventData eventData)
	{
		if(onDeselectEvent != null)
		{
			onDeselectEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onDeselectEvent))
        {
            PassEvent(eventData, ExecuteEvents.deselectHandler);
        }
    }

	public override void OnDrag(PointerEventData eventData)
	{
		if(onDragEvent != null)
		{
			onDragEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onDragEvent))
        {
            PassEvent(eventData, ExecuteEvents.dragHandler);
        }
    }

	public override void OnDrop(PointerEventData eventData)
	{
		if(onDropEvent != null)
		{
			onDropEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onDropEvent))
        {
            PassEvent(eventData, ExecuteEvents.dropHandler);
        }
    }

	public override void OnInitializePotentialDrag(PointerEventData eventData)
	{
		if(onInitializePotentialDragEvent != null)
		{
			onInitializePotentialDragEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onInitializePotentialDragEvent))
        {
            PassEvent(eventData, ExecuteEvents.initializePotentialDrag);
        }
    }

	public override void OnMove(AxisEventData eventData)
	{
		if(onMoveEvent != null)
		{
			onMoveEvent(this.gameObject, eventData);
		}
    }

	public override void OnPointerClick(PointerEventData eventData)
	{
		if(onPointerClickEvent != null)
		{
			onPointerClickEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onPointerClickEvent))
        {
            PassEvent(eventData, ExecuteEvents.pointerClickHandler);
        }
    }

	public override void OnPointerDown(PointerEventData eventData)
	{
		if(onPointerDownEvent != null)
		{
			onPointerDownEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onPointerDownEvent))
        {
            PassEvent(eventData, ExecuteEvents.pointerDownHandler);
        }
    }

	public override void OnPointerEnter(PointerEventData eventData)
	{
		if(onPointerEnterEvent != null)
		{
			onPointerEnterEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onPointerEnterEvent))
        {
            PassEvent(eventData, ExecuteEvents.pointerEnterHandler);
        }

    }

	public override void OnPointerExit(PointerEventData eventData)
	{
		if(onPointerExitEvent != null)
		{
			onPointerExitEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onPointerExitEvent))
        {
            PassEvent(eventData, ExecuteEvents.pointerExitHandler);
        }
    }

	public override void OnPointerUp(PointerEventData eventData)
	{
		if(onPointerUpEvent != null)
		{
			onPointerUpEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onPointerUpEvent))
        {
            PassEvent(eventData, ExecuteEvents.pointerUpHandler);
        }
    }

	public override void OnScroll(PointerEventData eventData)
	{
		if(onScrollEvent != null)
		{
			onScrollEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onScrollEvent))
        {
            PassEvent(eventData, ExecuteEvents.scrollHandler);
        }
    }

	public override void OnSelect(BaseEventData eventData)
	{
		if(onSelectEvent != null)
		{
			onSelectEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onSelectEvent))
        {
            PassEvent(eventData, ExecuteEvents.selectHandler);
        }
    }

	public override void OnSubmit(BaseEventData eventData)
	{
		if(onSubmitEvent != null)
		{
			onSubmitEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onSubmitEvent))
        {
            PassEvent(eventData, ExecuteEvents.submitHandler);
        }
    }
	
	public override void OnUpdateSelected(BaseEventData eventData)
	{
		if(onUpdateSelectedEvent != null)
		{
			onUpdateSelectedEvent(this.gameObject, eventData);
		}
        if (CheckIfCanPass(onUpdateSelectedEvent))
        {
            PassEvent(eventData, ExecuteEvents.updateSelectedHandler);
        }
    }

	public void ResetStatus()
	{
		onBeginDragEvent = null;
		onEndDragEvent = null;
		onCancelEvent = null;
		onDeselectEvent = null;
		onDragEvent = null;
		onDropEvent = null;
		onInitializePotentialDragEvent = null;
		onMoveEvent = null;
		onPointerClickEvent = null;
		onPointerDownEvent = null;
		onPointerExitEvent = null;
		onPointerEnterEvent = null;
		onPointerUpEvent = null;
		onScrollEvent = null;
		onSelectEvent = null;
		onSubmitEvent = null;
		onUpdateSelectedEvent = null;
	}

    //把事件透下去
    void PassEvent<T>(PointerEventData data, ExecuteEvents.EventFunction<T> func)
        where T : IEventSystemHandler
    {
        results.Clear();
        EventSystem.current.RaycastAll(data, results);
        GameObject current = data.pointerCurrentRaycast.gameObject;
        if (current != gameObject)
        {
	        return;
        }
        for (int i = 0; i < results.Count; i++)
        {
            if (current != results[i].gameObject)
            {
	            if (PapeGames.X3LuaKit.GameObjectTransformUtility.IsParentOf(gameObject, results[i].gameObject))
		            continue;
                ExecuteEvents.ExecuteHierarchy(results[i].gameObject, data, func);
                break;
            }
        }
        results.Clear();
    }
    void PassEvent<T>(BaseEventData data, ExecuteEvents.EventFunction<T> func)
        where T : IEventSystemHandler
    {
        GameObject current = data.selectedObject;
        if (current == gameObject)
        {
            return;
        }
        ExecuteEvents.ExecuteHierarchy(current, data, func);
    }
}