--------------------------------------------------------
--  DDL for Function F_PROD_AGENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PROD_AGENTE" (psproduc IN NUMBER, pcagente IN NUMBER) RETURN NUMBER IS

/*********************************************************************************
 Función que nos retorna un 1 en el caso que el agente pueda contratar el producto.
 --DESARROLLO PENDIENTE:
    En el caso de que la delegación del agente esté activa y tenga el campo subagen =1
    , los agentes de la delegación tambien tendrán el producto activo.
**********************************************************************************/
 v_resultado   NUMBER;
 vuserbd       VARCHAR2(50);
 verror        NUMBER;
 vtipousuario  NUMBER;
BEGIN

      vuserbd := f_os_user;
	  verror := pac_ctrl_acceso_mv.tipo_usuario(vuserbd, vtipousuario);
 IF vtipousuario = 0 THEN
   RETURN 1;--{como es de central no miramos la tabla producto_agente, siempre activo}
 END IF;
  -- Miramos si está activo en la tabla
  SELECT count(1)
    INTO v_resultado
    FROM producto_agente
   WHERE cagente = pcagente
     AND sproduc = psproduc;


 RETURN v_resultado;
END f_prod_agente;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_PROD_AGENTE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PROD_AGENTE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PROD_AGENTE" TO "PROGRAMADORESCSI";
