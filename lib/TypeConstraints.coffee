class TypeConstraints
    @check_type: ( value, name, args ) =>
        throw "No 'isa' for #{name}" unless args.isa

        if @[args.isa]
            return @[args.isa]( value, name, args )

        if args.isa instanceof TypeConstraints.Type
            return args.isa.check_type( value, name )

        @__Instance( value, name, args )


    @assert: ( ok, value, name, args ) =>
        if not ok
            an = 'an' if ( typeof args.isa == 'string' and args.isa[0].match( /aeou/ ) ) or 'a'
            throw "Assertion failed for " +
                "'#{name}', '#{value}' is not #{an} #{args.isa}"

        return true

    @Str: ( value, name, args )=>
        @assert ( typeof value == 'string' || value instanceof String ),
            value, name, args

    @Bool: ( value, name, args )=>
        @assert (typeof value == 'boolean'), value, name, args

    @Number: ( value, name, args )=>
        @assert (typeof value == 'number' and not isNaN value),
            value, name, args

    @Int: ( value, name, args )=>
        @assert ( typeof value == 'number' and value % 1 == 0 ),
            value, name, args

    @Object: ( value, name, args )=>
        @assert ( typeof value == 'object' and value isnt null ),
            value, name, args

    @Array: ( value, name, args )=>
        @assert  value instanceof Array, value, name, args

    @Function: ( value, name, args )=>
        @assert typeof value == 'function', value, name, args

    @__Instance: ( value, name, args )=>
        @assert typeof value == 'object', value, name, { isa: "instance of something" }
        @assert  value instanceof args.isa, value, name, args


class TypeConstraints.Type extends TypeConstraints
    constructor: ( @isa )->
        # pass

    check_type: ( value, name, args )->
        TypeConstraints.check_type value, name, args


class TypeConstraints.Type.Maybe extends TypeConstraints.Type
    constructor: ( @isa )->
        # pass

    check_type: ( value, name )->
        return true unless value?
        super value, name, isa: @isa

TypeConstraints.Maybe = ( type )->
  return new TypeConstraints.Type.Maybe( type )

exports.TypeConstraints = TypeConstraints
