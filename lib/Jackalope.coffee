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
        
    @has: (name, args)->
        @prototype.__meta__ ?= { attributes: {} }
        @prototype.__meta__.attributes[name] = args
        
        Jackalope.Meta.__create_accessor @prototype,
            name, args

    constructor: (ctor_args...)->
        for name, config of @attributes()
            value = ctor_args[0]?[name]
            
            continue unless value or config.required
        
            if config.required
               throw "#{name} is required!" unless value
        
            Jackalope.Meta.__write_value.call this,
                name, value, config

    attributes: ()->
        return @__attributes ?=
            Jackalope.Meta.__construct_attributes.call( this )




        
Jackalope.Meta =
    attributes: ( proto )->
        collect = {}

        for key, value of proto.__meta__.attributes
            collect[key] = value

        return collect

    __create_accessor: ( proto, name, args )->
        proto[name] = ( value ) ->
            Jackalope.Meta.__construct_default.call( this, name, args ) unless @__values?[name]
            Jackalope.Meta.__construct_lazy.call( this, name, args ) unless @__values?[name]
    
            return @__values?[name]
    
        Jackalope.Meta.__create_writer( proto, name, args ) if args.writer

    __create_writer: ( proto, name, args )->
        proto[args.writer] = ( value )->
            Jackalope.Meta.__write_value.call( this, name, value, args )

    __write_value: ( name, value, args )->
        TypeConstraints.check_type( value, name, args )

        @__values ?= {}
        @__values[name] = value
        
    __construct_default: ( name, args )->
        return unless args.default
        Jackalope.Meta.__write_value.call( this, name, args.default, args )

    __construct_attributes: ()->
        collect = {}

        for key, value of @__meta__.attributes
            collect[key] = value

        return collect;
    
    __construct_lazy: ( name, args )->
        return unless args.lazy_build
        Jackalope.Meta.__validate_config_build.call this, name, args
        Jackalope.Meta.__write_value.call( this, name, @["_build_#{name}"](), args )

    __validate_config_build: ( name, args )->
        if args.lazy_build?
            throw "method _build_#{name} not found" unless @["_build_#{name}"]?

extend = ( inst )->
    inst.has = Jackalope.has
    
    inst.prototype.attributes = Jackalope.prototype.attributes
    inst.prototype.constructor = Jackalope.prototype.constructor


# intermediate: prototypical inheritance
class Jackalope.Base
    # but with mixin
    extend this
    
            
exports.Jackalope = Jackalope.Base
exports.extend = ( klass )->
    console.log Jackalope 'extend'
    throw 'done'
    for name, fn in Jackalope
        do ()->
            console.log name, 'setting'
            klass.prototype[name] = fn
