--------------------------------------------------------
--  DDL for Package Body PAC_AYUDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_AYUDA" AS
   /*************************************************************************
      Para la ayuda de AXIS, se encargará de de retornar el contenido de la
      tabla AXIS_AYUDA
      param in  AYUDACURSOR    : Cursor con todos los valores de la tabla
                                  AXIS_AYUDA
      param out mensajes       : mensajes de error
      return    NUMBER         : 0 -> Finaliza correctamente.
                               : 1 -> Finaliza con error.
   *************************************************************************/
   FUNCTION f_get_ayuda(ayudacursor OUT sys_refcursor, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_sel          VARCHAR2(4000);
   BEGIN
      --Retorna toda la tabla de AXIS_AYUDA, todos sus campos, más un campo calculado de la clave
      v_sel := 'select UPPER(CFORM) as CFORM ,UPPER(CITEM) as CITEM,CIDIOMA,TITEM,TAYUDA, '
               || '(CIDIOMA ||''__''|| UPPER(CFORM) ||''__''|| UPPER(CITEM))     '
               || ' as AYUDA from AXIS_AYUDA order by CIDIOMA, CFORM, CITEM';
      ayudacursor := pac_iax_listvalores.f_opencursor(v_sel, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF ayudacursor%ISOPEN THEN
            CLOSE ayudacursor;
         END IF;

         RETURN 1;
   END f_get_ayuda;

   FUNCTION f_get_ayuda(
      cidioma IN NUMBER,
      cform IN VARCHAR2,
      ayudacursor OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_sel          VARCHAR2(4000);
   BEGIN
      --Retorna toda la tabla de AXIS_AYUDA, todos sus campos, más un campo calculado de la clave
      v_sel := 'select UPPER(CFORM) CFORM,TAYUDA from AXIS_AYUDA_FORM WHERE CFORM=''' || cform
               || ''' and cidioma= ' || cidioma;
      ayudacursor := pac_iax_listvalores.f_opencursor(v_sel, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF ayudacursor%ISOPEN THEN
            CLOSE ayudacursor;
         END IF;

         RETURN 1;
   END f_get_ayuda;
END pac_ayuda;

/

  GRANT EXECUTE ON "AXIS"."PAC_AYUDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AYUDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AYUDA" TO "PROGRAMADORESCSI";
