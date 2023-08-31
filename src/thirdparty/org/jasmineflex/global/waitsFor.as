package thirdparty.org.jasmineflex.global
{
	import thirdparty.org.jasmineflex.jasmine;

	public function waitsFor(latchFunction:Function, optional_timeoutMessage:String = null, optional_timeout:* = null) {
		jasmine.getEnv().currentSpec.waitsFor.apply(jasmine.getEnv().currentSpec, arguments);
	};
}