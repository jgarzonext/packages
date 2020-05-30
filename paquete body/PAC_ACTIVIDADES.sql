--------------------------------------------------------
--  DDL for Package Body PAC_ACTIVIDADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_ACTIVIDADES" AS
/******************************************************************************
   NOMBRE:       PAC_ACTIVIDADES
   PROPÓSITO:  Mantenimiento actividades. gestión

   REVISIONES:
   Ver   Fecha        Autor            Descripción
   ----  ----------  ---------------  ------------------------------------
   1.0   29/12/2008   XCG              1. Creación del package. con una única función: F_GET_ACTIVIRAMO (BUG 8510)
 ******************************************************************************/
/**************************************************************************
        Función que se retorna las actividades definidas de un ramo
        PARAM IN PCRAMO      : Código del Ramo
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM OUT PRETCURSOR :SYS_REFCURSOR
        PARAM OUT NERROR     : Código de error
        PARAM OUT mensaje    : Código de error (0: operación correcta sino 1)
   *************************************************************************/
   FUNCTION f_get_activiramo(pcramo IN NUMBER, nerror OUT NUMBER)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_actividades.f_get_activiramo';
      vparam         VARCHAR2(500) := 'parámetros - pcramo: ' || pcramo;
      vpasexec       NUMBER := 1;
   BEGIN
      OPEN v_cursor FOR
         SELECT   tactivi, cactivi
             FROM activisegu
            WHERE cramo = pcramo
              AND cidioma = pac_md_common.f_get_cxtidioma
         ORDER BY cactivi;

      nerror := 0;
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                     SQLERRM || ' ' || SQLCODE);

         IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
         END IF;

         nerror := 101144;   /*Error al modificar en la taula ACTIVISEGU*/
         RETURN v_cursor;
   END f_get_activiramo;
END pac_actividades;

/

  GRANT EXECUTE ON "AXIS"."PAC_ACTIVIDADES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ACTIVIDADES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ACTIVIDADES" TO "PROGRAMADORESCSI";
