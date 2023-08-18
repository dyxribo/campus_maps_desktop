package net.blaxstar.components {
  import flash.display.DisplayObject;
  import flash.display.DisplayObjectContainer;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.utils.Dictionary;

  import net.blaxstar.style.Style;

  /**
   * ...
   * @author Deron Decamp
   */
  public class List extends Component {
    private const PADDING:uint = 7;

    private var _listWidth:uint;
    private var _itemHeight:uint;
    private var _items:Vector.<ListItem>;
    private var _itemsCache:Dictionary;
    private var _itemContainer:VerticalBox;
    private var _maxVisible:uint;
    private var _selectionIndicator:Sprite;
    private var _selectedItem:ListItem;
    private var _useSelectionIndicator:Boolean;
    private var _alternatingColors:Boolean;
    private var _customDelegates:Vector.<Function>;

    public function List(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, altColors:Boolean = false) {
      super(parent, xpos, ypos);
      _alternatingColors = altColors;
    }

    override public function init():void {
      _width_ = _listWidth = 200;
      _height_ = _itemHeight = 35;
      _items = new Vector.<ListItem>();
      super.init();
    }

    /**
     * initializes and adds all required children of the component.
     */
    override public function addChildren():void {
      _itemContainer = new VerticalBox();
      _itemContainer.spacing = 0;
      super.addChild(_itemContainer);
      super.addChildren();
    }

    /**
     * (re)draws the component and applies any pending visual changes.
     */
    override public function draw(e:Event = null):void {
      if (_itemContainer.numChildren > 0)
        _itemContainer.removeChildren();

      for (var i:uint; i < _items.length; i++) {
        _itemContainer.addChild(_items[i]);
        if (_alternatingColors) {
          if (i % 2 == 0)
            _items[i].alternateColor = true;
        }
        _width_ = Math.max(_listWidth, _items[i].labelComponent.width + 10);

      }
      _height_ = _itemContainer.height;
      resetListBG();
      super.draw();
    }

    private function resetListBG():void {
      graphics.clear();
      graphics.beginFill(Style.SURFACE.value);
      graphics.drawRoundRect(0, 0, _width_, _height_, 7);
      graphics.endFill();
      applyShadow();
    }

    override public function addChild(child:DisplayObject):DisplayObject {
      if (child is ListItem) {
        addItem(child as ListItem);
      }
      return child;
    }

    override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
      if (child is ListItem) {
        addItemAt(child as ListItem, index);
      }
      return child;
    }

    public function addItem(li:ListItem):List {
      if (!_itemsCache)
        _itemsCache = new Dictionary();
      if (li != null) {
        if (_itemsCache[li.linkageid]) {
          _items.push(li);
        }
        else {
          _itemsCache[li.linkageid] = li;
          _items.push(li);
          li.setSize(_listWidth + (PADDING * 2), _itemHeight);
          li.onResize.add(onItemResize);
          li.onRollOver.add(onItemRollOver);
          li.onRollOut.add(onItemRollOut);
          li.onClick.add(onItemClick);
          if (_customDelegates) {
            for (var j:uint = 0; j < _customDelegates.length; j++) {
              li.onClick.add(_customDelegates[j]);
            }
          }
          _itemContainer.addChild(li);
        }
        draw();
      }
      return this;
    }

    public function getCachedItemByID(id:uint):ListItem {
      var li:ListItem;
      for (var item:String in _itemsCache) {
        if (_itemsCache[item].linkageid == id) {
          li = _itemsCache[item] as ListItem;
          break;
        }
      }
      return li;
    }

    public function hideList(e:MouseEvent = null):void {
      this.visible = false;
    }

    public function setSelection(itemIndex:uint):void {
      selectItem(_itemContainer.getChildAt(itemIndex) as ListItem);
    }

    public function addClickDelegate(func:Function):void {
      _customDelegates ||= new Vector.<Function>();
      _customDelegates.push(func);
      for (var i:uint; i < _items.length; i++) {
        _items[i].onClick.add(func);
      }
    }

    public function removeClickDelegate(func:Function):void {
      for (var i:uint; i < _items.length; i++) {
        _items[i].onClick.remove(func);
      }
    }

    private function onItemRollOut(e:MouseEvent):void {
      resetListBG();
    }

    private function onItemRollOver(e:MouseEvent = null):void {
      var li:ListItem = (e.currentTarget as ListItem);
      resetListBG();
      selectItem(li);
    }

    private function selectItem(li:ListItem):void {
      graphics.beginFill((Style.CURRENT_THEME == Style.DARK) ? Style.GLOW.value : Style.GLOW.tint().value);
      graphics.drawRoundRect(li.x, li.y, _listWidth, li.height + PADDING, 7);
      graphics.endFill();
      applyShadow();
    }

    public function clear():void {
      _items.length = 0;
      draw();
    }

    public function get numItems():uint {
      return _itemContainer.numChildren;
    }

    override public function set width(value:Number):void {
      _listWidth = value;
      super.width = value;
    }

    public function set itemHeight(val:Number):void {
      if (val > 0)
        _itemHeight = val;
      draw();
    }

    private function onItemClick(e:MouseEvent):void {
      _selectedItem = e.currentTarget as ListItem;
      hideList();
    }

    private function onItemResize(e:Event = null):void {
      draw();
    }

    private function addSelectionIndicatorListeners():void {
      for (var i:uint = 0; i < _items.length; i++) {
        _items[i].onClick.add(onItemClick);
      }
    }

    private function removeSelectionIndicatorListeners():void {
      for (var i:uint = 0; i < _items.length; i++) {
        _items[i].onClick.remove(onItemClick);
      }
    }

    public function addItemAt(li:ListItem, index:uint = 0):List {
      if (li) {
        _items.splice(index, 0, li);
        commit;
      }
      return this;
    }

    public function get selectedItem():ListItem {
      return _selectedItem;
    }

    public function set useSelectionIndicator(val:Boolean):void {
      _useSelectionIndicator = val;
      if (_useSelectionIndicator)
        addSelectionIndicatorListeners();
      else
        removeSelectionIndicatorListeners();
    }

    override public function destroy(e:Event = null):void {
      super.destroy(e);

      for (var i:uint = 0; i < _itemContainer.numChildren; i++) {
        var child:ListItem = ListItem(_itemContainer.getChildAt(i));
        child.onResize.remove(onItemResize);
        child.onClick.remove(onItemClick);
      }
    }

    public function getItemAt(itemIndex:uint):ListItem {
      return _items[itemIndex];
    }
  }

}