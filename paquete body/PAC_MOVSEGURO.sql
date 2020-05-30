--------------------------------------------------------
--  DDL for Package Body PAC_MOVSEGURO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MOVSEGURO" AS
   /*************************************************************
           F_NMOVIMI_ULT: Obtener el útlimo NMOVIMI
   **************************************************************/
   FUNCTION f_nmovimi_ult(psseguro IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'param - psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'pac_movseguro.f_nmovimi_ult';
      vnmovimi       NUMBER(8);
   BEGIN
      vnmovimi := NULL;

      SELECT MAX(nmovimi)
        INTO vnmovimi
        FROM movseguro
       WHERE sseguro = psseguro
         AND femisio IS NOT NULL;

      RETURN vnmovimi;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN -1;
   END f_nmovimi_ult;

   /*************************************************************
           F_NMOVIMI_VALIDO: Obtener el útlimo NMOVIMI válido
   **************************************************************/
   FUNCTION f_nmovimi_valido(psseguro IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'param - psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'pac_movseguro.f_nmovimi_valido';
      vnmovimi       NUMBER(8);
   BEGIN
      vnmovimi := NULL;

      SELECT MAX(nmovimi)
        INTO vnmovimi
        FROM movseguro
       WHERE sseguro = psseguro
         AND femisio IS NOT NULL
         AND cmovseg NOT IN(6, 52);

      RETURN vnmovimi;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN -1;
   END f_nmovimi_valido;

   /*************************************************************
           F_GET_CESTADOCOL: Obtener el valor del campo cestadocol
   **************************************************************/
-- Bug 24278 - APD - 05/12/2012
   FUNCTION f_get_cestadocol(psseguro IN NUMBER, pnmovimi IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                            := 'param - psseguro: ' || psseguro || '; pnmovimi = ' || pnmovimi;
      vobject        VARCHAR2(200) := 'pac_movseguro.f_get_cestadocol';
      vcestadocol    movseguro.cestadocol%TYPE := NULL;
   BEGIN
      SELECT m.cestadocol
        INTO vcestadocol
        FROM movseguro m
       WHERE m.sseguro = psseguro
         AND m.nmovimi = NVL(pnmovimi, (SELECT MAX(m2.nmovimi)
                                          FROM movseguro m2
                                         WHERE m.sseguro = m2.sseguro));

      RETURN vcestadocol;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN -1;
   END f_get_cestadocol;

   /*************************************************************
           F_SET_CESTADOCOL: Actualiza el valor del campo cestadocol
   **************************************************************/
-- Bug 24278 - APD - 05/12/2012
   FUNCTION f_set_cestadocol(
      psseguro IN NUMBER,
      pcestadocol IN NUMBER,
      pnmovimi IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'param - psseguro: ' || psseguro || '; pcestadocol = ' || pcestadocol
            || '; pnmovimi = ' || pnmovimi;
      vobject        VARCHAR2(200) := 'pac_movseguro.f_set_cestadocol';
      vcestadocol    movseguro.cestadocol%TYPE := NULL;
      vnmovimi       movseguro.nmovimi%TYPE;
   BEGIN
      IF pnmovimi IS NULL THEN
         SELECT MAX(nmovimi)
           INTO vnmovimi
           FROM movseguro
          WHERE sseguro = psseguro;
      ELSE
         vnmovimi := pnmovimi;
      END IF;

      UPDATE movseguro
         SET cestadocol = pcestadocol
       WHERE sseguro = psseguro
         AND nmovimi = vnmovimi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 105235;   -- Error al modificar en la tabla MOVSEGURO
   END f_set_cestadocol;

   /*************************************************************
           F_GET_FEFECTO: Obtener el valor del campo fefecto
   **************************************************************/
-- Bug 24278 - APD - 05/12/2012
   FUNCTION f_get_fefecto(psseguro IN NUMBER, pnmovimi IN NUMBER DEFAULT NULL)
      RETURN DATE IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                            := 'param - psseguro: ' || psseguro || '; pnmovimi = ' || pnmovimi;
      vobject        VARCHAR2(200) := 'pac_movseguro.f_get_fefecto';
      vfefecto       movseguro.fefecto%TYPE := NULL;
   BEGIN
      SELECT m.fefecto
        INTO vfefecto
        FROM movseguro m
       WHERE m.sseguro = psseguro
         AND m.nmovimi = NVL(pnmovimi, (SELECT MAX(m2.nmovimi)
                                          FROM movseguro m2
                                         WHERE m.sseguro = m2.sseguro));

      RETURN vfefecto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_fefecto;
END pac_movseguro;

/

  GRANT EXECUTE ON "AXIS"."PAC_MOVSEGURO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MOVSEGURO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MOVSEGURO" TO "PROGRAMADORESCSI";
