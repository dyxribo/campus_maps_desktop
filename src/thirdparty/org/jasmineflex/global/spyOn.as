package thirdparty.org.jasmineflex.global
{
	import thirdparty.org.jasmineflex.jasmine;

	public function spyOn(obj:*, methodName:String):* {
		return jasmine.getEnv().currentSpec.spyOn(obj, methodName);
	};
}