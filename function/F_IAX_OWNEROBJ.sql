--------------------------------------------------------
--  DDL for Function F_IAX_OWNEROBJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IAX_OWNEROBJ" RETURN SYS_REFCURSOR IS
/******************************************************************************
   NOMBRE:       F_IAX_OWNEROBJ
   PROPÓSITO: Devuelve los type propietario del usuario

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        28/03/2008   ACC                1. Creación de la función.
******************************************************************************/
    cur sys_refcursor;
    mensajes T_IAX_MENSAJES;
    vpasexec NUMBER(8):=1;
    vparam VARCHAR2(1):=NULL;
    vobject VARCHAR2(200):='F_IAX_OWNEROBJ';
BEGIN

    OPEN cur for SELECT OBJECT_NAME FROM ALL_OBJECTS WHERE owner = USER and OBJECT_TYPE='TYPE' ORDER BY 1;

    RETURN cur;
EXCEPTION WHEN OTHERS THEN
    PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
            1000001,vpasexec,vparam,null,sqlcode,sqlerrm);
    IF cur%isopen THEN CLOSE cur; END IF;
    RETURN cur;
END F_IAX_OWNEROBJ;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_IAX_OWNEROBJ" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IAX_OWNEROBJ" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IAX_OWNEROBJ" TO "PROGRAMADORESCSI";
