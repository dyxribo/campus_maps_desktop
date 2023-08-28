package net.blaxstar.io {
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.utils.ByteArray;

  import thirdparty.org.osflash.signals.Signal;
  import flash.display.Bitmap;
  import flash.display.LoaderInfo;

  /**
   * an elite loader for loading all kinds of content.
   * @author Deron Decamp (decamp.deron@gmail.com)
   *
   */

  public class XLoader {
    public const ON_ERROR:Signal = new Signal(String, String);
    public const ON_PROGRESS:Signal = new Signal(Number);
    public const ON_COMPLETE:Signal = new Signal(URL, Object);

    private var mData:Vector.<ByteArray>;
    private var mURLs:Vector.<URL>;
    private var _totalLoaded:Number;
    private var _overallTotal:Number;

    public function XLoader() {
      mData = new Vector.<ByteArray>;
      mURLs = new Vector.<URL>;
    }

    public function queue_files(urlVector:Vector.<URL>):void {
      if (mURLs.length > 0) {
        for (var i:uint = 0; i < urlVector.length; i++) {
          mURLs.push(urlVector[i]);
          _overallTotal += urlVector[i].bytesTotal;
        }
      }
      else {
        mURLs = urlVector;
        _totalLoaded = 0;
        for (i = 0; i < mURLs.length; i++) {
          _overallTotal += mURLs[i].bytesTotal;
        }
        loadNext();
      }
    }

    private function loadNext():void {
      var currentItem:URL = mURLs[0];

      if (currentItem.expected_data_type !== URL.GRAPHICS) {
        currentItem.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        currentItem.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
        currentItem.addEventListener(ProgressEvent.PROGRESS, onProgress);
        currentItem.addEventListener(Event.COMPLETE, onComplete);
        currentItem.dataFormat = currentItem.expected_data_type;
        currentItem.connect();
      }
      else {
        IOUtil.loadExternalDisplayObject(currentItem.host, onComplete, onProgress, onIOError);
      }
    }

    private function dispatchOverallProgress():void {
      if (_overallTotal != 0) {
        ON_PROGRESS.dispatch(_totalLoaded / _overallTotal);
      }
    }

    public function getData(name:String):ByteArray {
      for (var i:uint = 0; i < mURLs.length; i++) {
        if (mURLs[i].name == name)
          return mData[i];
      }
      return null;
    }

    protected function get dataVector():Vector.<ByteArray> {
      return mData;
    }

    private function nullCurrentLoaderItem(targetID:uint):void {
      mData[targetID] = null;
      mURLs[targetID].close();
      mURLs[targetID] = null;

      dispatchOverallProgress();
    }

    private function onIOError(e:IOErrorEvent):void {
      var target:URL = e.target as URL;

      ON_ERROR.dispatch(target.name, e.text);
      // TODO: refactor this func to use something other than id
      // nullCurrentLoaderItem(target.id);
    }

    private function onSecurityError(e:SecurityErrorEvent):void {
      var target:URL = e.target as URL;

      ON_ERROR.dispatch(target.name, e.text);
      // nullCurrentLoaderItem(target.id);
    }

    private function onProgress(e:ProgressEvent):void {
      var target:LoaderInfo = e.currentTarget as LoaderInfo;
      _totalLoaded += target.bytesLoaded - _totalLoaded;
      dispatchOverallProgress();
    }

    private function onComplete(e:Event):void {
      if (e.target is LoaderInfo) {
        // graphics
        var url:URL = mURLs[0];
        url.data = (e.target.content as Bitmap);
        ON_COMPLETE.dispatch(url, url.data);
      }
      else {
        var target:URL = e.target as URL;
        target.close();

        if (target.expected_data_type == URL.TEXT) {
          var ba:ByteArray = new ByteArray();
          ba.writeUTFBytes(target.data);
          ba.position = 0;
          target.data = ba;
          _totalLoaded += target.bytesLoaded;
          ON_COMPLETE.dispatch(target, target.data);
        }
      }

      mURLs.removeAt(0);
      dispatchOverallProgress();
      if (mURLs.length > 0)
        loadNext();
    }

  }
}
