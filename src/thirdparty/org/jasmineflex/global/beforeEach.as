package thirdparty.org.jasmineflex.global
{
	import thirdparty.org.jasmineflex.jasmine;

	public function beforeEach(beforeEachFunction:Function):void {
		jasmine.getEnv().beforeEach(beforeEachFunction);
	};
}