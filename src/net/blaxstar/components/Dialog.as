package net.blaxstar.components {
  import flash.display.DisplayObject;
  import flash.display.DisplayObjectContainer;
  import flash.events.Event;
  import flash.geom.Rectangle;
  import flash.geom.Rectangle;
  import thirdparty.org.osflash.signals.Signal;

  /**
   * ...
   * @author Deron Decamp
   */
  public class Dialog extends Component {
    static public const OPTION_EMPHASIS_LOW:uint = 0;
    static public const OPTION_EMPHASIS_HIGH:uint = 1;
    
    protected var _titlePT:PlainText;
    protected var _messagePT:PlainText;
    private var _titleString:String;
    private var _messageString:String;
    private var _textContainer:VerticalBox;
    private var _dialogCard:Card;
    private var _prevParent:DisplayObjectContainer;
    private var _onClose:Signal;

    public function Dialog(parent:DisplayObjectContainer = null, title:String = 'TITLE', message:String = 'THIS IS A MESSAGE. DO YOU AGREE?') {
      _titleString = title;
      _messageString = message;
      _onClose = new Signal();
      addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
      super(parent);
    }

    /** INTERFACE net.blaxstar.components.IComponent ===================== */

    /**
     * initializes the component by adding all the children
     * and committing the visual changes to be written on the next frame.
     * created to be overridden.
     */
    override public function init():void {

      super.init();
    }

    /**
     * initializes and adds all required children of the component.
     */
    override public function addChildren():void {

      _dialogCard = new Card(this, 0, 0, false);
      _textContainer = new VerticalBox(null, PADDING, PADDING);
      _dialogCard.addChildNative(_textContainer);
      _titlePT = new PlainText(_textContainer, 0, 0, _titleString);
      _titlePT.enabled = false;
      _messagePT = new PlainText(_textContainer, 0, 0, _messageString);
      _dialogCard.onResize.add(draw);
      _dialogCard.draggable = true;
    }

    /**
     * (re)draws the component and applies any pending visual changes.
     */
    override public function draw(e:Event = null):void {
      _width_ = _dialogCard.width;
      _height_ = _dialogCard.height;
      componentContainer.move(PADDING, _textContainer.y + _textContainer.height + PADDING);
      optionContainer.move(PADDING, _height_ - optionContainer.height);
      move((stage.nativeWindow.width / 2) - (_width_ / 2), (stage.nativeWindow.height / 2) - (_width_ / 2));
      super.draw(e);
    }

    /** END INTERFACE ===================== */

    public function addComponent(val:DisplayObject):DisplayObject {
      return _dialogCard.addChildToContainer(val);
    }

    public function set title(val:String):void {
      _titlePT.text = (val.length > 0) ? val : _titlePT.text;
    }

    public function set message(val:String):void {
      _messagePT.text = (val.length > 0) ? val : _messagePT.text;
    }

    public function get onClose():Signal {
      return _onClose;
    }

    public function set viewableItems(val:uint):void {
      _dialogCard.viewableItems = val;
    }

    public function set maskThreshold(val:Number):void {
      _dialogCard.maskThreshold = val;
    }

    public function addOption(name:String, action:Function = null, emphasis:uint = OPTION_EMPHASIS_LOW):Button {
      var b:Button = new Button(_dialogCard.optionContainer, 0, 0, name);
      if (action != null)
        b.addClickListener(action);
      if (emphasis == OPTION_EMPHASIS_LOW) {
        b.style = Button.DEPRESSED;
      }
      else if (emphasis == OPTION_EMPHASIS_HIGH) {
        b.style = Button.GROUNDED;
      }

      commit();
      return b;
    }

    public function close():void {
      parent.removeChild(this);
      _onClose.dispatch();
    }

    public function open():void {
      if (_prevParent != null) {
        _prevParent.addChild(this);
      }
    }

    public function removeOptions():void {
      _dialogCard.optionContainer.removeChildren();
    }

    public function get componentContainer():VerticalBox {
      return _dialogCard.componentContainer;
    }

    public function get optionContainer():HorizontalBox {
      return _dialogCard.optionContainer;
    }

    private function onAddedToStage(e:Event):void {
      _prevParent = parent;
    }
  }

}
