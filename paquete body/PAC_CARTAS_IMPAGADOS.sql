--------------------------------------------------------
--  DDL for Package Body PAC_CARTAS_IMPAGADOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARTAS_IMPAGADOS" 
AS
/******************************************************************************
  NOMBRE:      pac_cartas_impagados
  PROPÓSITO: Funciones para la impresión de cartas de impagos

  REVISIONES:
  Ver        Fecha        Autor  Descripción
  ---------  ----------  ------  ------------------------------------
  1.0        08/06/2009   JTS     1.0 Creación del package
  2.0        23/04/2012   JMF    0022030: MDP_A001-Devoluciones: impresion y gestion de cartas
******************************************************************************/

   /*************************************************************************
      Obtiene el codigo de plantilla a imprimir para una carta de impago dada
      param in psgescarta  : Código de carta
      param out pccodplan  : Código de plantilla
      return               : Number 0.- OK Otro.- KO
   *************************************************************************/
   FUNCTION f_get_codplantilla (psgescarta IN NUMBER, pccodplan OUT VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      SELECT p.ccodplan
        INTO pccodplan
        FROM prod_plant_cab p,
             codiplantillas cp,
             seguros s,
             gescartas gc,
             tiposcarta tc
       WHERE gc.sgescarta = psgescarta
         AND s.sseguro = gc.sseguro
         AND gc.ctipcar = tc.ctipcar
         AND tc.ccodplan = p.ccodplan
         AND p.sproduc = s.sproduc
         AND f_sysdate BETWEEN fdesde AND NVL (fhasta, f_sysdate)
         AND p.ctipo = 20
         AND p.ccodplan = cp.ccodplan;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 9001775;
      WHEN OTHERS
      THEN
         p_tab_error
               (f_sysdate,
                f_user,
                   'PAC_CARTAS_IMPAGADOS.f_get_codplantilla - psgescarta = '
                || psgescarta,
                1,
                SQLCODE,
                SQLERRM
               );
         RETURN SQLCODE;
   END f_get_codplantilla;

   /*************************************************************************
      Marca la carta de impago como impresa
      param in psgescarta  : Código de carta
      param in p_sdevolu   : ID. devolucion
      return               : Number 0.- OK Otro.- KO
      -- Bug 0022030 - 23/04/2012 - JMF
   *************************************************************************/
   FUNCTION f_marcar_gescarta (psgescarta IN NUMBER, p_sdevolu IN NUMBER)
      RETURN NUMBER
   IS
      vobj    VARCHAR2 (200) := 'PAC_CARTAS_IMPAGADOS.f_marcar_gescarta';
      vpar    VARCHAR2 (200) := 'ges=' || psgescarta || ' dev=' || p_sdevolu;
      vpas    NUMBER (5)     := 0;
      pinfo   t_iax_info;
   BEGIN
      IF p_sdevolu IS NOT NULL
      THEN
         vpas := 100;

         UPDATE gescartas
            SET cestado = 2,
                nimpres = nimpres + 1,
                fimpres = f_sysdate,
                usuimp = f_user
          WHERE sdevolu = p_sdevolu AND cestado != 3;
      ELSIF psgescarta IS NOT NULL
      THEN
         vpas := 110;

         UPDATE gescartas
            SET cestado = 2,
                nimpres = nimpres + 1,
                fimpres = f_sysdate,
                usuimp = f_user
          WHERE sgescarta = psgescarta AND cestado != 3;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN SQLCODE;
   END f_marcar_gescarta;
END pac_cartas_impagados;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARTAS_IMPAGADOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARTAS_IMPAGADOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARTAS_IMPAGADOS" TO "PROGRAMADORESCSI";
