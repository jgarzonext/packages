--------------------------------------------------------
--  DDL for Package Body PAC_AGE_PROPIEDADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_AGE_PROPIEDADES" IS
   /******************************************************************************
        NOMBRE:       PAC_AGE_PROPIEDADES
        PROPÃ“SITO: Funciones para gestionar los parametros de los agentes

        REVISIONES:
        Ver        Fecha        Autor             DescripciÃ³n
        ---------  ----------  ---------------  ------------------------------------
        1.0        08/03/2012  AMC               1. Creación del package.

     ******************************************************************************/

   /*************************************************************************
   Inserta el paràmetre per agent
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   param in pnvalpar   : Resposta numérica
   param in ptvalpar   : Resposta text
   param in pfvalpar   : Resposta data
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_ins_paragente(
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      pnvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
      num_err        NUMBER;
   BEGIN
      SELECT ctipo
        INTO vctipo
        FROM codparam
       WHERE cparam = pcparam;

      IF vctipo = 1
         AND ptvalpar IS NOT NULL
         AND pnvalpar IS NULL
         AND pfvalpar IS NULL THEN
         INSERT INTO age_paragentes
                     (cagente, cparam, tvalpar)
              VALUES (pcagente, pcparam, ptvalpar);
      ELSIF vctipo IN(2, 4)
            AND ptvalpar IS NULL
            AND pnvalpar IS NOT NULL
            AND pfvalpar IS NULL THEN
         INSERT INTO age_paragentes
                     (cagente, cparam, nvalpar)
              VALUES (pcagente, pcparam, pnvalpar);
      ELSIF vctipo = 3
            AND ptvalpar IS NULL
            AND pnvalpar IS NULL
            AND pfvalpar IS NOT NULL THEN
         INSERT INTO age_paragentes
                     (cagente, cparam, fvalpar)
              VALUES (pcagente, pcparam, pfvalpar);
      ELSE
         RETURN 9001781;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            IF vctipo = 1
               AND ptvalpar IS NOT NULL
               AND pnvalpar IS NULL
               AND pfvalpar IS NULL THEN
               UPDATE age_paragentes
                  SET tvalpar = ptvalpar
                WHERE cparam = pcparam
                  AND cagente = pcagente;
            ELSIF vctipo IN(2, 4)
                  AND ptvalpar IS NULL
                  AND pnvalpar IS NOT NULL
                  AND pfvalpar IS NULL THEN
               UPDATE age_paragentes
                  SET nvalpar = pnvalpar
                WHERE cparam = pcparam
                  AND cagente = pcagente;
            ELSIF vctipo = 3
                  AND ptvalpar IS NULL
                  AND pnvalpar IS NULL
                  AND pfvalpar IS NOT NULL THEN
               UPDATE age_paragentes
                  SET fvalpar = pfvalpar
                WHERE cparam = pcparam
                  AND cagente = pcagente;
            ELSE
               RETURN 9001781;
            END IF;

            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_age_propiedades.f_ins_paragente', 1,
                           'when others pcparam =' || pcparam, SQLERRM);
               RETURN 9001781;
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_age_propiedades.f_ins_paragente', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 9001781;
   END f_ins_paragente;

   /*************************************************************************
    Esborra el paràmetre per agent
    param in psperson   : Codi agent
    param in pcparam    : Codi parametre
    return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_del_paragente(pcagente IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF pcparam IS NOT NULL
         AND pcagente IS NOT NULL THEN
         DELETE FROM age_paragentes
               WHERE cparam = pcparam
                 AND cagente = pcagente;

         RETURN 0;
      ELSIF pcagente IS NOT NULL THEN
         DELETE FROM age_paragentes
               WHERE cagente = pcagente;
      ELSE
         RETURN 9001781;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_age_propiedades.f_del_paragente', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 9001781;
   END f_del_paragente;

    /*************************************************************************
   Obté la select amb els paràmetres per agent
   param in pcagente   : Codi agent
   param in pidioma    : Codi idioma
   param in ptots      : 0.- Només retorna els paràmetres contestats
                         1.- Retorna tots els paràmetres
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_paragente(
      pcagente IN NUMBER,
      pidioma IN NUMBER,
      ptots IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
   BEGIN
      IF pcagente IS NOT NULL THEN
         vsquery :=
            'SELECT c.cutili, c.cparam, c.ctipo, d.tparam, cp.tvisible,  r.tvalpar, r.nvalpar, r.fvalpar,'
            || ' (select det.tvalpar from detparam det where det.cparam = c.cparam and det.cidioma = d.cidioma and det.cvalpar = r.nvalpar) resp'
            || ' FROM codparam c, desparam d, codparam_age cp, age_paragentes r '
            || ' WHERE c.cutili = 10' || ' AND d.cparam = c.cparam'
            || ' AND cp.cparam = c.cparam' || ' AND d.cidioma = ' || pidioma;

         IF ptots = 0 THEN
            vsquery := vsquery || ' AND r.cparam = cp.cparam AND r.cagente = ' || pcagente;
         ELSE
            vsquery := vsquery || ' AND r.cparam(+) = cp.cparam AND r.cagente(+) = '
                       || pcagente;
         END IF;
      ELSE
         vsquery :=
            'SELECT c.cutili, c.cparam, c.ctipo, d.tparam, cp.cvisible, null, null,null ,'
            || ' null resp' || ' FROM codparam c, desparam d, codparam_age cp '
            || ' WHERE c.cutili = 10' || ' AND d.cparam = c.cparam'
            || ' AND cp.cparam = c.cparam ' || ' AND d.cidioma = ' || pidioma;
      END IF;

      vsquery := vsquery || ' order by d.tparam';
      psquery := vsquery;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_age_propiedades.f_get_paragente', 1, SQLCODE,
                     SQLERRM);
         RETURN SQLCODE;
   END f_get_paragente;

   /*************************************************************************
   Obté la select amb els paràmetres per agent
      pcparam IN NUMBER,
      pcidioma in number,
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_obparagente(pcparam IN VARCHAR2, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
   BEGIN
      vsquery :=
         'SELECT c.cutili, c.cparam, c.ctipo, d.tparam, cp.tvisible, null, null,null ,'
         || ' null resp' || ' FROM codparam c, desparam d, codparam_age cp '
         || ' WHERE c.cutili = 10  AND d.cparam = c.cparam'
         || ' AND cp.cparam = c.cparam and c.cparam = ''' || pcparam || ''' AND d.cidioma = '
         || pcidioma;
      psquery := vsquery;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_age_propiedades.f_get_obparagente', 1, SQLCODE,
                     SQLERRM);
         RETURN SQLCODE;
   END f_get_obparagente;

   /*************************************************************************
    Funcio per comprobar si una propietat es visible per l'agent
       pcagente IN NUMBER,
       pcvisible in texto, funcion para comprobar la visivilidad

    return              : 0.- No visible, 1.- Visible
    *************************************************************************/
   FUNCTION f_get_compvisible(pcagente IN NUMBER, pcvisible IN VARCHAR2)
      RETURN NUMBER IS
      lsentencia     VARCHAR2(500);
      vnumero        NUMBER;
   BEGIN
      lsentencia := 'begin :vnumero:= ' || pcvisible || ' (' || pcagente || '); end;';

      EXECUTE IMMEDIATE lsentencia
                  USING OUT vnumero;

      RETURN vnumero;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_age_propiedades.f_get_compvisible', 1, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_get_compvisible;
END pac_age_propiedades;

/

  GRANT EXECUTE ON "AXIS"."PAC_AGE_PROPIEDADES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AGE_PROPIEDADES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AGE_PROPIEDADES" TO "PROGRAMADORESCSI";
