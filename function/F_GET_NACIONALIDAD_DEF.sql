--------------------------------------------------------
--  DDL for Function F_GET_NACIONALIDAD_DEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_GET_NACIONALIDAD_DEF" (
        psperson in per_personas.sperson%type,
        pcempres in empresas.cempres%type,
        pcagente in agentes.cagente%type
   )return number IS

v_cpais per_nacionalidades.cpais%type;
BEGIN
  select cpais
  into v_cpais
  from nacionalidades
  where  sperson = psperson  AND
        cdefecto = 1;

  return v_cpais;
   EXCEPTION
      WHEN OTHERS THEN        -- Si llego aquí o bien no hay valores con valor defecto a 1
                              -- o bien hay más de uno
         p_tab_error (f_sysdate,
                      f_user,
                      'F_GET_NACIONALIDAD_DEF',
                      1,
                      'F_GET_NACIONALIDAD_DEF. Error. No existe país por defecto, o hay varios ',
                      SQLERRM
                     );
         RETURN NULL;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_GET_NACIONALIDAD_DEF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_GET_NACIONALIDAD_DEF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_GET_NACIONALIDAD_DEF" TO "PROGRAMADORESCSI";
