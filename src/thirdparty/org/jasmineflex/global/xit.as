package thirdparty.org.jasmineflex.global
{
	import thirdparty.org.jasmineflex.jasmine;

	public function xit(desc:String, func:Function):* {
		return jasmine.getEnv().xit(desc, func);
	};
}