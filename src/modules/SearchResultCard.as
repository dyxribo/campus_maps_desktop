package modules
{
  import net.blaxstar.starlib.components.Card;
  import models.MapSearchResult;
  import net.blaxstar.starlib.components.PlainText;

  public class SearchResultCard extends Card {
    private var _result_object_cache:Vector.<PlainText>;

    public function SearchResultCard(){
      super();
    }

    public function add_search_result(result:MapSearchResult):void {
      if (!_result_object_cache) {
        _result_object_cache = new Vector.<PlainText>();
      }
      var result_object:PlainText;
      if (_result_object_cache.length > 0) {
        result_object = _result_object_cache.pop();
        result_object.text = result.label;
      } else {
        result_object = new PlainText(null,0,0,result.label);
      }

      add_child_to_container(result_object);

    }
  }
}
