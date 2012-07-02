class TypeConstraints
    @check_type: ( value, name, args ) =>
        if @[args.isa]
            return @[args.isa]( value, name, args )

        @__Instance( value, name, args )


    @assert: ( ok, value, name, args ) =>
        if not ok
            throw "Assertion failed for " +
                "'#{name}', '#{value}' is not a #{args.isa}"
                
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
        @assert  value instanceof args.isa, value, name, args

exports.TypeConstraints = TypeConstraints
