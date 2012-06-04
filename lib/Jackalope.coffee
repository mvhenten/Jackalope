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
        
exports.Jackalope = Jackalope
