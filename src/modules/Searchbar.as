package modules {
  import flash.display.Sprite;
  import net.blaxstar.starlib.components.InputTextField;
  import net.blaxstar.starlib.components.Card;
  import flash.events.Event;

  public class Searchbar extends Sprite {
    private var _search_card:Card;
    private var _search_input:InputTextField;
    private var _input_string:String;

    public function Searchbar () {
      init();
      // ! TODO: search box showing up too high, not centered to card
      // ! keep in mind that the input field is within the card's component container. may need to change that.
    }

    private function init():void {
      _search_card = new Card();
      _search_input = new InputTextField();

      _search_input.on_text_update.add(on_input_update);

      add_children();
    }

    private function add_children():void {
      addChild(_search_card);
      _search_card.add_child_to_container(_search_input);
    }

    private function draw():void {
      _search_card.component_container.move(10, 10);

    }

    //! delegate functions

    private function on_input_update(e:Event):void {
      _input_string = _search_input.text;
    }
  }
}
