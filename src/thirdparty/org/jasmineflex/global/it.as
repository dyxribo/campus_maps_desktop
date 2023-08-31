package thirdparty.org.jasmineflex.global
{
	import thirdparty.org.jasmineflex.jasmine;

	public function it(desc:String, func:Function):* {
		return jasmine.getEnv().it(desc, func);
	};
}