TypeConstraints = require('./TypeConstraints').TypeConstraints
# TODO
# - predicate
# - init_arg
# - trigger
# - handles
# - native traits
# ...methods
# ...move attributes into separate namespace ( attribute namespace )
# ...separate real methods from attributes
#
class Jackalope    
    constructor: (ctor_args...)->
        for name, config of @attributes()
            value = ctor_args[0]?[name]
            
            continue unless value or config.required
        
            if config.required
               throw "#{name} is required!" unless value
        
            @__write_value( name, value, config )
        
    @has: (name, args)->
        @prototype.__meta__ ?= { attributes: {} }
        @prototype.__meta__.attributes[name] = args
        @__create_accessor( @prototype, name, args )

    attributes: ()->
        return @__attributes ?= @__construct_attributes()

    @__create_accessor: ( proto, name, args )->
        proto[name] = ( value ) ->
            @__construct_default( name, args ) unless @__values?[name]
            @__construct_lazy( name, args ) unless @__values?[name]
    
            return @__values?[name]
    
        @__create_writer( proto, name, args ) if args.writer

    @__create_writer: ( proto, name, args )->
        proto[args.writer] = ( value )->
            @__write_value( name, value, args )

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
        @__write_value( name, args.default, args )

    __construct_lazy: ( name, args )->
        return unless args.lazy_build
        @__validate_config_build name, args
        @__write_value( name, @["_build_#{name}"](), args )

    __write_value: ( name, value, args )->
        TypeConstraints.check_type( value, name, args )

        @__values ?= {}
        @__values[name] = value
            
exports.Jackalope = Jackalope
