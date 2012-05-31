class Jackalope
    @__create_accessor: ( proto, name, args )->
        proto[name] = ( value ) ->
            @__construct_default( name, args ) unless @__values?[name]
            @__construct_lazy( name, args ) unless @__values?[name]
    
            return @__values?[name]
    
        @__create_writer( proto, name, args ) if args.writer

    @__create_writer: ( proto, name, args )->
        proto[args.writer] = ( value )->
            @__write_value( name, value )
    
    @has: (name, args)->
        @prototype.__meta__ ?= { attributes: {} }
        @prototype.__meta__.attributes[name] = args
        @__create_accessor( @prototype, name, args )


    attributes: ()->
        return @__attributes ?= @__construct_attributes()

    __validate_config_build: ( name, args )->
        if args.lazy_build?
            throw "method _build_#{name} not found" unless @["_build_#{name}"]?

    __construct_attributes: ()->
        collect = {}

        for key, value of @__meta__.attributes
            collect[key] = value

        return collect;

    __construct_default: ( name, args )->
        return unless args.default
        @__write_value( name, args.default )

    __construct_lazy: ( name, args )->
        return unless args.lazy_build
        @__validate_config_build name, args
        @__write_value( name, @["_build_#{name}"]() )


    __write_value: ( name, value )->
        @__values ?= {}
        @__values[name] = value
        
class Jackalope.TypeConstraints
    @check_type: ( value, name, args ) =>
        if @[args.isa]
            return @[args.isa]( value, name, args )
        
        @__Instance( value, name, args )
        

    @assert: ( ok, value, name, args ) =>
        if not ok
            throw "Assertion failed for " +
                "#{name}, #{value} is not a #{args.isa}"
        return true

    @Str: ( value, name, args )=>
        @assert typeof value == 'string', value, name, args

    @Bool: ( value, name, args )=>
        @assert (typeof value == 'boolean'), value, name, args

    @Number: ( value, name, args )=>
        @assert typeof value == 'number', value, name, args

    @Int: ( value, name, args )=>
        @assert value % 1 == 0, value, name, args

    @Object: ( value, name, args )=>
        @assert typeof value == 'object', value, name, args

    @Function: ( value, name, args )=>
        @assert typeof value == 'function', value, name, args
        
    @__Instance: ( value, name, args )=>
        @Function( value, name, args )
        @assert  value instanceof args.isa, value, name, args


# minimal testing...

throws_ok = ( fn, message )->
    ok = false
    try
        fn()
    catch error
        console.log " ok: #{message}"
        ok = true
    throw " not ok: #{message}" unless ok

ok = ( fn, message )->
    throw " not ok: #{message}" unless fn()
    console.log " ok: #{message}"
    
test = ( name, fn )->
    if fn()
        console.log "Test OK: #{name}"

# simple tests...

test 'Boolean', ()->
    args = { isa: 'Bool' }

    cases =
        throws_ok: [ 1, 'true', {}, [] ]
        ok: [ true, false ]
            
    for value in cases.throws_ok
        do ( value )->
            throws_ok ()->
                Jackalope.TypeConstraints.check_type( value, '', args  )
            , "#{value} isnt a boolean"

    for value in cases.ok
        do ( value )->
            ok ()->
                Jackalope.TypeConstraints.check_type( value, '', args  )
            , "#{value} isa boolean"

test 'Number', ()->
    args = { isa: 'Number' }

    cases =
        throws_ok: [ '1', 'true', {}, [] ]
        ok: [ 1, 0.1, 1.2, 42 ]
            
    for value in cases.throws_ok
        do ( value )->
            throws_ok ()->
                Jackalope.TypeConstraints.check_type( value, '', args  )
            , "#{value} isnt a number"

    for value in cases.ok
        do ( value )->
            ok ()->
                Jackalope.TypeConstraints.check_type( value, '', args  )
            , "#{value} isa number"

test 'Int', ()->
    throws_ok ()->
        args = { isa: 'Int' }
        Jackalope.TypeConstraints.check_type( 'not int', 'test bool', args  )
    , 'not an int'
            
    ok ()->
        args = { isa: 'Int' }
        Jackalope.TypeConstraints.check_type( 1, 'test bool', args  )
    , 'is a int'

class Foo extends Jackalope

    @has 'ladida',
        default: 56
        writer: 'set_ladida'
        isa: 'Number'

    @has 'one',
        lazy_build: true
        isa: 'Number'

    _build_one: ()->
        return 98

    _build_ala: ()->
        #pass

n = new Foo()
throw 'Default must be expected as lazy' unless n.one() == 98

n = new Foo()
throw 'Default must be expected as default' unless n.ladida() == 56


n = new Foo()
m = new Foo()

n.set_ladida( 42 )
m.set_ladida( 60 )

throw 'Values cannot be the same after setter' unless m.ladida() != n.ladida()
throw 'Values must be as expected' unless m.ladida() == 60 and n.ladida() == 42
