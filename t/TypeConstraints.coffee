Jackalope = require '../src/TypeConstraints'

[test, ok, throws_ok] = require('./lib/test')
    .export 'test','ok','throws_ok'

class Foo
    constructor: ()->
        # pass

cases =
    Boolean:
        isa: 'Bool'
        throws_ok: [ '' , 1, 'true', {}, [], undefined, null ]
        ok: [ true, false ]

    Number:
        isa: 'Number'
        throws_ok: [ '', '1', true, {}, [], NaN, undefined, null ]
        ok: [ 1, 0.1, 1.2, 42 ]

    Int:
        isa: 'Int'
        throws_ok: [ '', '1', true, {}, [], NaN, undefined, null ]
        ok: [ 1, 0 ]

    Str:
        isa: 'Str'
        throws_ok: [ 1, 0, true, {}, [], NaN, undefined, null ]
        ok: [ '', '1', ( new String('') ) ]

    Function:
        isa: 'Function'
        throws_ok: [ '', '1', true, {}, [], NaN, undefined, null, (new Object()) ]
        ok: [ (->) ]

    Object:
        isa: 'Object'
        throws_ok: [ '', '1', true, NaN, undefined, null ]
        ok: [ {}, ( new Object() ) ]

    Array:
        isa: 'Array'
        throws_ok: [ '', '1', true, {}, NaN, undefined, null, (new Object()) ]
        ok: [ [1,2], [null, 1, true], new Array() ]

    InstanceOf:
        isa: Foo
        throws_ok: [ '', '1', true, {}, [], NaN, undefined, null, (new Object()), (->) ]
        ok: [ (new Foo()) ]

nTests = ( cases )->
    n_tests = 0
    for key, value of cases
        continue if key is 'isa'
        n_tests = ( n_tests ? 0 ) + value.length

    return n_tests


runTestCase = ( name, testCase )->
    test "TypeConstraint #{name}", nTests( testCase ), ()->
        args = { isa: testCase.isa }

        console.log "  ## Testing throws_ok #{name}"
        for value in testCase.throws_ok
            do ( value )=>
                throws_ok ()->
                    Jackalope.TypeConstraints.check_type( value, 'isa', args  )
                , /is not a/

        console.log "  ## Testing ok #{name}"
        for value in testCase.ok
            do ( value )=>
                ok Jackalope.TypeConstraints.check_type( (value), 'isa', args  )
                , "#{value} isa \"#{args.isa}\""

runTestCase( name, test_case ) for name, test_case of cases

test 'Maybe', 7, ()->
    maybe_cases =
        Bool: true
        Number: 99.9
        Int: 10
        Str: 'a string'
        Function: ()->
        Object: { iam: 'object' }
        Array: ['an array']

    for type, value of maybe_cases
        args = { isa: Jackalope.TypeConstraints.Maybe "#{type}" }
        ok Jackalope.TypeConstraints.check_type( value, "Check #{type}:", args  )


runMaybeTestCase = ( name, testCase )->
    test "Maybe TypeConstraint #{name}", nTests( testCase ), ()->
        args = { isa: Jackalope.TypeConstraints.Maybe testCase.isa }

        console.log "  ## Testing throws_ok #{name}"
        for value in testCase.throws_ok
            do ( value )=>
                if value?
                    throws_ok ()->
                        Jackalope.TypeConstraints.check_type( value, 'isa', args  )
                    , /is not a/
                else
                    ok Jackalope.TypeConstraints.check_type( (value), 'isa', args  )
                    , "#{value} is ok for Maybe"

        console.log "  ## Testing ok #{name}"
        for value in testCase.ok
            do ( value )=>
                ok Jackalope.TypeConstraints.check_type( (value), 'isa', args  )
                , "#{value} isa \"#{args.isa}\""

runMaybeTestCase( name, test_case ) for name, test_case of cases
