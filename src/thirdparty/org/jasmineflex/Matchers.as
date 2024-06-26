
package thirdparty.org.jasmineflex
{
	public dynamic class Matchers
	{
		 /**
		 * @constructor
		 * @param {jasmine.Env} env
		 * @param actual
		 * @param {jasmine.Spec} spec
		 */
		//jasmine.Matchers = function(env, actual, spec, opt_isNot) {
		public function Matchers(env, actual, spec, opt_isNot = null)
		{
		  this.env = env;
		  this.actual = actual;
		  this.spec = spec;
		  this.isNot = opt_isNot || false;
		  this.reportWasCalled_ = false;
		};

		public static function apply(thisObject, args) {
			return new Matchers(args[0], args[1], args[2], args.length >= 4 ? args[3] : null);
		}
		
		jasmine.Matchers = Matchers;
		
		// todo: @deprecated as of Jasmine 0.11, remove soon [xw]
		jasmine.Matchers.pp = function(str) {
		  throw new Error("jasmine.Matchers.pp() is no longer supported, please use jasmine.pp() instead!");
		};
		
		// todo: @deprecated Deprecated as of Jasmine 0.10. Rewrite your custom matchers to return true or false. [xw]
		jasmine.Matchers.prototype.report = function(result, failing_message, details) {
		  throw new Error("As of jasmine 0.11, custom matchers must be implemented differently -- please see jasmine docs");
		};
		
		jasmine.Matchers.wrapInto_ = function(prototype, matchersClass) {
		  for (var methodName in prototype) {
		    if (methodName == 'report') continue;
		    var orig = prototype[methodName];
		    matchersClass.prototype[methodName] = jasmine.Matchers.matcherFn_(methodName, orig);
		  }
		};
		
		jasmine.Matchers.matcherFn_ = function(matcherName, matcherFunction) {
		  return function() {
		    var matcherArgs = jasmine.util.argsToArray(arguments);
		    var result = matcherFunction.apply(this, arguments);
		
		    if (this.isNot) {
		      result = !result;
		    }
		
		    if (this.reportWasCalled_) return result;
		
		    var message;
		    if (!result) {
		      if (this.message) {
		        message = this.message.apply(this, arguments);
		        if (jasmine.isArray_(message)) {
		          message = message[this.isNot ? 1 : 0];
		        }
		      } else {
		        var englishyPredicate = matcherName.replace(/[A-Z]/g, function(s) { return ' ' + s.toLowerCase(); });
		        message = "Expected " + jasmine.pp(this.actual) + (this.isNot ? " not " : " ") + englishyPredicate;
		        if (matcherArgs.length > 0) {
		          for (var i = 0; i < matcherArgs.length; i++) {
		            if (i > 0) message += ",";
		            message += " " + jasmine.pp(matcherArgs[i]);
		          }
		        }
		        message += ".";
		      }
		    }
		    var expectationResult = new jasmine.ExpectationResult({
		      matcherName: matcherName,
		      passed: result,
		      expected: matcherArgs.length > 1 ? matcherArgs : matcherArgs[0],
		      actual: this.actual,
		      message: message
		    });
		    this.spec.addMatcherResult(expectationResult);
		    return jasmine.undefined;
		  };
		};
		
		
		
		
		/**
		 * toBe: compares the actual to the expected using ===
		 * @param expected
		 */
		jasmine.Matchers.prototype.toBe = function(expected) {
		  return this.actual === expected;
		};
		
		/**
		 * toNotBe: compares the actual to the expected using !==
		 * @param expected
		 * @deprecated as of 1.0. Use not.toBe() instead.
		 */
		jasmine.Matchers.prototype.toNotBe = function(expected) {
		  return this.actual !== expected;
		};
		
		/**
		 * toEqual: compares the actual to the expected using common sense equality. Handles Objects, Arrays, etc.
		 *
		 * @param expected
		 */
		jasmine.Matchers.prototype.toEqual = function(expected) {
		  return this.env.equals_(this.actual, expected);
		};
		
		/**
		 * toNotEqual: compares the actual to the expected using the ! of jasmine.Matchers.toEqual
		 * @param expected
		 * @deprecated as of 1.0. Use not.toNotEqual() instead.
		 */
		jasmine.Matchers.prototype.toNotEqual = function(expected) {
		  return !this.env.equals_(this.actual, expected);
		};
		
		/**
		 * Matcher that compares the actual to the expected using a regular expression.  Constructs a RegExp, so takes
		 * a pattern or a String.
		 *
		 * @param expected
		 */
		jasmine.Matchers.prototype.toMatch = function(expected) {
		  return new RegExp(expected).test(this.actual);
		};
		
		/**
		 * Matcher that compares the actual to the expected using the boolean inverse of jasmine.Matchers.toMatch
		 * @param expected
		 * @deprecated as of 1.0. Use not.toMatch() instead.
		 */
		jasmine.Matchers.prototype.toNotMatch = function(expected) {
		  return !(new RegExp(expected).test(this.actual));
		};
		
		/**
		 * Matcher that compares the actual to jasmine.undefined.
		 */
		jasmine.Matchers.prototype.toBeDefined = function() {
		  return (this.actual !== jasmine.undefined);
		};
		
		/**
		 * Matcher that compares the actual to jasmine.undefined.
		 */
		jasmine.Matchers.prototype.toBeUndefined = function() {
		  return (this.actual === jasmine.undefined);
		};
		
		/**
		 * Matcher that compares the actual to null.
		 */
		jasmine.Matchers.prototype.toBeNull = function() {
		  return (this.actual === null);
		};
		
		/**
		 * Matcher that boolean not-nots the actual.
		 */
		jasmine.Matchers.prototype.toBeTruthy = function() {
		  return !!this.actual;
		};
		
		
		/**
		 * Matcher that boolean nots the actual.
		 */
		jasmine.Matchers.prototype.toBeFalsy = function() {
		  return !this.actual;
		};
		
		
		/**
		 * Matcher that checks to see if the actual, a Jasmine spy, was called.
		 */
		jasmine.Matchers.prototype.toHaveBeenCalled = function() {
		  if (arguments.length > 0) {
		    throw new Error('toHaveBeenCalled does not take arguments, use toHaveBeenCalledWith');
		  }
		
		  if (!jasmine.isSpy(this.actual)) {
		    throw new Error('Expected a spy, but got ' + jasmine.pp(this.actual) + '.');
		  }
		
		  this.message = function() {
		    return [
		      "Expected spy " + this.actual.identity + " to have been called.",
		      "Expected spy " + this.actual.identity + " not to have been called."
		    ];
		  };
		
		  return this.actual.wasCalled;
		};
		
		/** @deprecated Use expect(xxx).toHaveBeenCalled() instead */
		jasmine.Matchers.prototype.wasCalled = jasmine.Matchers.prototype.toHaveBeenCalled;
		
		/**
		 * Matcher that checks to see if the actual, a Jasmine spy, was not called.
		 *
		 * @deprecated Use expect(xxx).not.toHaveBeenCalled() instead
		 */
		jasmine.Matchers.prototype.wasNotCalled = function() {
		  if (arguments.length > 0) {
		    throw new Error('wasNotCalled does not take arguments');
		  }
		
		  if (!jasmine.isSpy(this.actual)) {
		    throw new Error('Expected a spy, but got ' + jasmine.pp(this.actual) + '.');
		  }
		
		  this.message = function() {
		    return [
		      "Expected spy " + this.actual.identity + " to not have been called.",
		      "Expected spy " + this.actual.identity + " to have been called."
		    ];
		  };
		
		  return !this.actual.wasCalled;
		};
		
		/**
		 * Matcher that checks to see if the actual, a Jasmine spy, was called with a set of parameters.
		 *
		 * @example
		 *
		 */
		jasmine.Matchers.prototype.toHaveBeenCalledWith = function() {
		  var expectedArgs = jasmine.util.argsToArray(arguments);
		  if (!jasmine.isSpy(this.actual)) {
		    throw new Error('Expected a spy, but got ' + jasmine.pp(this.actual) + '.');
		  }
		  this.message = function() {
		    if (this.actual.callCount === 0) {
		      // todo: what should the failure message for .not.toHaveBeenCalledWith() be? is this right? test better. [xw]
		      return [
		        "Expected spy to have been called with " + jasmine.pp(expectedArgs) + " but it was never called.",
		        "Expected spy not to have been called with " + jasmine.pp(expectedArgs) + " but it was."
		      ];
		    } else {
		      return [
		        "Expected spy to have been called with " + jasmine.pp(expectedArgs) + " but was called with " + jasmine.pp(this.actual.argsForCall),
		        "Expected spy not to have been called with " + jasmine.pp(expectedArgs) + " but was called with " + jasmine.pp(this.actual.argsForCall)
		      ];
		    }
		  };
		
		  return this.env.contains_(this.actual.argsForCall, expectedArgs);
		};
		
		/** @deprecated Use expect(xxx).toHaveBeenCalledWith() instead */
		jasmine.Matchers.prototype.wasCalledWith = jasmine.Matchers.prototype.toHaveBeenCalledWith;
		
		/** @deprecated Use expect(xxx).not.toHaveBeenCalledWith() instead */
		jasmine.Matchers.prototype.wasNotCalledWith = function() {
		  var expectedArgs = jasmine.util.argsToArray(arguments);
		  if (!jasmine.isSpy(this.actual)) {
		    throw new Error('Expected a spy, but got ' + jasmine.pp(this.actual) + '.');
		  }
		
		  this.message = function() {
		    return [
		      "Expected spy not to have been called with " + jasmine.pp(expectedArgs) + " but it was",
		      "Expected spy to have been called with " + jasmine.pp(expectedArgs) + " but it was"
		    ];
		  };
		
		  return !this.env.contains_(this.actual.argsForCall, expectedArgs);
		};
		
		/**
		 * Matcher that checks that the expected item is an element in the actual Array.
		 *
		 * @param {Object} expected
		 */
		jasmine.Matchers.prototype.toContain = function(expected) {
		  return this.env.contains_(this.actual, expected);
		};
		
		/**
		 * Matcher that checks that the expected item is NOT an element in the actual Array.
		 *
		 * @param {Object} expected
		 * @deprecated as of 1.0. Use not.toNotContain() instead.
		 */
		jasmine.Matchers.prototype.toNotContain = function(expected) {
		  return !this.env.contains_(this.actual, expected);
		};
		
		jasmine.Matchers.prototype.toBeLessThan = function(expected) {
		  return this.actual < expected;
		};
		
		jasmine.Matchers.prototype.toBeGreaterThan = function(expected) {
		  return this.actual > expected;
		};
		
		/**
		 * Matcher that checks that the expected exception was thrown by the actual.
		 *
		 * @param {String} expected
		 */
		jasmine.Matchers.prototype.toThrow = function(expected) {
		  var result = false;
		  var exception;
		  if (typeof this.actual != 'function') {
		    throw new Error('Actual is not a function');
		  }
		  try {
		    this.actual();
		  } catch (e) {
		    exception = e;
		  }
		  if (exception) {
		    result = (expected === jasmine.undefined || this.env.equals_(exception.message || exception, "message" in expected ? expected.message : expected));
		  }
		
		  var not = this.isNot ? "not " : "";
		
		  this.message = function() {
		    if (exception && (expected === jasmine.undefined || !this.env.equals_(exception.message || exception, "message" in expected ? expected.message : expected))) {
		      return ["Expected function " + not + "to throw", expected ? ("message" in expected ? expected.message : expected) : "an exception", ", but it threw", exception.message || exception].join(' ');
		    } else {
		      return "Expected function to throw an exception.";
		    }
		  };
		
		  return result;
		};
		
		jasmine.Matchers.Any = function(expectedClass) {
		  this.expectedClass = expectedClass;
		};
		
		jasmine.Matchers.Any.prototype.matches = function(other) {
		  if (this.expectedClass == String) {
		    return typeof other == 'string' || other instanceof String;
		  }
		
		  if (this.expectedClass == Number) {
		    return typeof other == 'number' || other instanceof Number;
		  }
		
		  if (this.expectedClass == Function) {
		    return typeof other == 'function' || other instanceof Function;
		  }
		
		  if (this.expectedClass == Object) {
		    return typeof other == 'object';
		  }
		
		  return other instanceof this.expectedClass;
		};
		
		jasmine.Matchers.Any.prototype.toString = function() {
		  return '<jasmine.any(' + this.expectedClass + ')>';
		};
	}
}
