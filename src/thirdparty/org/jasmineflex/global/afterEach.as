package thirdparty.org.jasmineflex.global
{
	import thirdparty.org.jasmineflex.jasmine;

	public function afterEach(afterEachFunction:Function):void {
		jasmine.getEnv().afterEach(afterEachFunction);
	};
}