--------------------------------------------------------
--  DDL for Package Body PAC_DESCVALORES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_DESCVALORES" IS
/******************************************************************************
   NOMBRE:       PAC_DESCVALORES
   PROPÓSITO: Funciones para retornar descripciones
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        30/04/2009   DCT             1.Creación paquete
   2.0        27/04/2010   AMC             2. Bug 14284 Se añade la función f_desgarant
   3.0        29/12/2010   JMP             3. Bug 16092: Se añade la función ff_desactivi
   4.0        24/01/2011   DRA             4. 0016576: AGA602 - Parametrització de reemborsaments per veterinaris
   5.0        06/06/2012   ETM             5.0021404: MDP - PER - Validación de documentos en función del tipo de sociedad
******************************************************************************/
   FUNCTION f_desctipocuenta(
      pctipban IN NUMBER,
      pcidioma IN NUMBER,
      pttipo OUT tipos_cuentades.ttipo%TYPE)
      RETURN NUMBER IS
   BEGIN
      SELECT ttipo
        INTO pttipo
        FROM tipos_cuentades
       WHERE ctipban = pctipban
         AND cidioma = pcidioma;

      RETURN 0;   --No hay error
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error
            (f_sysdate, f_user, 'PAC_DESCVALORES', 1,
             'f_desctipocuenta.Error al buscar la descripción de tipo o formato de cuenta ccc',
             SQLERRM);
         RETURN 180928;   --Error al buscar la descripción de tipo o formato de cuenta ccc
      WHEN OTHERS THEN
         p_tab_error
            (f_sysdate, f_user, 'PAC_DESCVALORES', 1,
             'f_desctipocuenta.Error Imprevisto obteniendo la descripción de tipo o formato de cuenta ccc',
             SQLERRM);
         RETURN 103212;   --Error al ejecutar la consulta
   END f_desctipocuenta;

      /*******************************************************
      Función que devuelve la descripción de una garantía
      PARAM IN pcgarant : codigo de la garantía
      PARAM IN pcidioma : código de idioma
      PARAM OUT ptgarant : descripción de la garantía
      RETURN NUMBER
      Bug 14284 - 27/04/2010 - AMC
   *******************************************************/
   FUNCTION f_descgarant(pcgarant IN NUMBER, pcidioma IN NUMBER, ptgarant OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      ptgarant := ff_desgarantia(pcgarant, pcidioma);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_descvalores.f_desgarant', 1,
                     'error no controlado', SQLERRM);
   END f_descgarant;

   FUNCTION ff_desactivi(p_cactivi IN NUMBER, p_cramo IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2
/*************************************************************************
   FUNCTION FF_DESACTIVI
   Devuelve la descripción de una actividad de un ramo
     param in p_cactivi : código de la actividad
     param in p_cramo   : código del ramo
     param in p_cidioma : código del idioma
     return             : la descripción de la actividad
*************************************************************************/
   IS
      v_error        NUMBER;
      v_tactivi      activisegu.tactivi%TYPE;
   BEGIN
      v_error := f_desactivi(p_cactivi, p_cramo, p_cidioma, v_tactivi);
      RETURN v_tactivi;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END ff_desactivi;

   -- BUG16576:DRA:24/01/2011:Inici
   /*********************************************************************************
        F_DESACTO: Función que devuelve la descripción del acto.
   ********************************************************************************/
   FUNCTION ff_desacto(
      pcacto IN VARCHAR2,
      pcgarant IN NUMBER,
      pagr_salud IN VARCHAR2,
      pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      --
      vtacto         desactos.tacto%TYPE;
   BEGIN
      BEGIN
         SELECT d.tacto
           INTO vtacto
           FROM desactos d, actos_garanpro g
          WHERE d.cacto = UPPER(pcacto)   -- BUG10631:DRA:06/07/2009
            AND d.cidioma = pcidioma
            AND g.cacto = d.cacto
            AND g.cgarant = pcgarant
            AND g.agr_salud = pagr_salud
            AND TRUNC(g.fvigencia) <= TRUNC(f_sysdate)
            AND(TRUNC(g.ffinvig) > TRUNC(f_sysdate)
                OR g.ffinvig IS NULL);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vtacto := NULL;
      END;

      RETURN vtacto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_descvalores.f_desacto', 1,
                     'error no controlado, pcacto=' || pcacto || ', pcgarant=' || pcgarant
                     || ', pagr_salud=' || pagr_salud || ', pcidioma=' || pcidioma,
                     SQLERRM);
         RETURN NULL;
   END ff_desacto;

-- BUG16576:DRA:24/01/2011:Inici

   --bug 21404--ETM-- 06/06/2012
   /*************************************************************************
       Recupera la descripción del tipo de sociedad
       param in pnnumide     : nubero de nif/cif
       return              : descripción del tipo de sociedad
    *************************************************************************/
   FUNCTION f_get_descsociedad(pnnumide IN VARCHAR2)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      v_descsoci     VARCHAR2(1000);
      vobject        VARCHAR2(200) := 'PAC_DESCVALORES.f_get_descsociedad';
      vparam         VARCHAR2(250) := 'pnnumide= ' || pnnumide;
      v_letra        VARCHAR2(1);

   BEGIN
      --OBTENER LA LETRA Y DAR LA DESCRIPCION
      v_letra := UPPER(SUBSTR(pnnumide, 1, 1));

      BEGIN
         SELECT d.ttipsdad
           INTO v_descsoci
           FROM codsociedad c, descsociedad d
          WHERE c.ctipsdad = v_letra
            AND c.ctipsdad = d.ctipsdad
            AND d.cidioma = pac_md_common.f_get_cxtidioma;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_descsoci := NULL;
         WHEN OTHERS THEN
            v_descsoci := NULL;
      END;

      RETURN v_descsoci;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_descvalores.f_get_descsociedad', 1,
                     'error no controlado, pnnumide= ' || pnnumide, SQLERRM);
         RETURN NULL;
   END f_get_descsociedad;
--FIN bug 21404--ETM-- 06/06/2012
END pac_descvalores;

/

  GRANT EXECUTE ON "AXIS"."PAC_DESCVALORES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DESCVALORES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DESCVALORES" TO "PROGRAMADORESCSI";
