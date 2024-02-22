using System.Collections.Generic;
using UnityEngine;

[XLua.LuaCallCSharp]
public class ColorBarHelper
{
    private static ColorBarHelper _instance;
    public static ColorBarHelper Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = new ColorBarHelper();
            }
            return _instance;
        }
    }

    private Color[] _fullColorGroup = new Color[] { new Color(1, 0, 0), new Color(1, 1, 0), new Color(0, 1, 0), new Color(0, 1, 1), new Color(0, 0, 1), new Color(1, 0, 1), new Color(1, 0, 0) };
    public ColorBar TryGetColorBar(GameObject gameObject)
    {
        ColorBar _colorBar = null;
        if (gameObject != null)
        {
            _colorBar = gameObject.GetComponent<ColorBar>();
            if (_colorBar == null) _colorBar = gameObject.AddComponent<ColorBar>();
        }
        return _colorBar;
    }

    public ColorBar TryGetColorBar(Component component)
    {
        if (component == null) return null;
        return TryGetColorBar(component.gameObject);
    }

    private List<Color> _cacheColors = new List<Color>();
    private const int MIN_HUE_VALUE = 0;
    private const int MAX_HUE_VALUE = 360;
    private const int PER_HUE_UNIT = 60;
    public void SetHueRange(ColorBar colorBar, int hueMinValue = MIN_HUE_VALUE, int hueMaxValue = MAX_HUE_VALUE)
    {
        if (colorBar == null) return;

        if (hueMinValue == MIN_HUE_VALUE && hueMaxValue == MAX_HUE_VALUE)
        {
            colorBar.SetColors(_fullColorGroup);
            return;
        }

        int startIndex = hueMinValue / PER_HUE_UNIT + 1;
        if (startIndex > _fullColorGroup.Length - 1) startIndex = _fullColorGroup.Length - 1;

        int endIndex = hueMaxValue / PER_HUE_UNIT;
        if (hueMaxValue % PER_HUE_UNIT == 0) --endIndex;
        if (endIndex < 0) endIndex = 0;

        _cacheColors.Clear();
        _cacheColors.Add(Color.HSVToRGB((float)hueMinValue / MAX_HUE_VALUE, 1, 1));
        for (int i = startIndex; i <= endIndex; i++)
        {
            _cacheColors.Add(_fullColorGroup[i]);
        }
        _cacheColors.Add(Color.HSVToRGB((float)hueMaxValue / MAX_HUE_VALUE, 1, 1));
        colorBar.SetColors(_cacheColors);
        return;
    }
}