--------------------------------------------------------
--  DDL for Package Body PAC_MNTCAMPANYAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MNTCAMPANYAS" AS
/******************************************************************************
    NOMBRE:      PAC_MNTCAMPANYAS
    PROPÓSITO:   Funciones para la gestión de campañas

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------  ------------------------------------
    1.0        08/05/2013   AMC       1. Creación del package. Bug 26615/143210
******************************************************************************/

   /**********************************************************************************************
      Función para recuperar campanyas
      param in pccampanya:    codigo campaña
      param in ptcampanya:    descripción de campaña

      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_campanyas(
      pccampanya IN NUMBER,   -- codigo campaña
      ptcampanya IN VARCHAR2,   -- Deripción de la campaña
      pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      vobject        VARCHAR2(500) := 'pac_mntcampanyas.f_get_campanyas';
      vparam         VARCHAR2(550)
         := 'parámetros - pccampanya:' || pccampanya || ',ptcampanya:' || ptcampanya
            || ',pcidioma:' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vtexto         VARCHAR2(1000);
   BEGIN
      vtexto := 'select ccampanya,tcampanya,cidioma' || ' from descampanyas'
                || ' where cidioma = ' || pcidioma;

      IF pccampanya IS NOT NULL THEN
         vtexto := vtexto || ' and ccampanya = ' || pccampanya;
      END IF;

      IF ptcampanya IS NOT NULL THEN
         vtexto := vtexto || ' and upper(tcampanya) like ' || CHR(39) || '%'
                   || UPPER(ptcampanya) || '%' || CHR(39);
      END IF;

      RETURN vtexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_campanyas;

   /**********************************************************************************************
      Función para recuperar campanyas
      param in pccampanya:    codigo campaña
      param in ptodo: Recupera todos los idiomas o solo los informados

      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_campanya(pccampanya IN NUMBER,   -- codigo campaña
                                                ptodo IN NUMBER)
      RETURN VARCHAR2 IS
      vobject        VARCHAR2(500) := 'pac_mntcampanyas.f_get_campanya';
      vparam         VARCHAR2(550) := 'parámetros - pccampanya:' || pccampanya;
      vpasexec       NUMBER(5) := 1;
      vtexto         VARCHAR2(1000);
   BEGIN
      vtexto := 'select d.ccampanya,d.tcampanya,i.cidioma,i.tidioma'
                || ' from descampanyas d, idiomas i';

      IF ptodo = 0 THEN
         vtexto := vtexto || ' where d.ccampanya = ' || NVL(pccampanya, -1)
                   || ' and d.cidioma = i.cidioma';
      ELSE
         vtexto := vtexto || ' where d.ccampanya(+) = ' || NVL(pccampanya, -1)
                   || ' and d.cidioma(+) = i.cidioma';
      END IF;

      vtexto := vtexto || ' order by i.cidioma';
      RETURN vtexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_campanya;

    /**********************************************************************************************
      Función para guardar campanyas
      param in pccampanya:    codigo campaña
      param in ptcampanya:    descripción de campaña
      param in pcidioma: código de idioma

      Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_set_campanya(
      pccampanya IN NUMBER,   -- codigo campaña
      ptcampanya IN VARCHAR2,   -- Deripción de la campaña
      pcidioma IN NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_mntcampanyas.f_set_campanya';
      vparam         VARCHAR2(550)
         := 'parámetros - pccampanya:' || pccampanya || ' ptcampanya:' || ptcampanya
            || ' pcidioma:' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vtexto         VARCHAR2(1000);
   BEGIN
      BEGIN
         INSERT INTO codcampanyas
                     (ccampanya)
              VALUES (pccampanya);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
      END;

      BEGIN
         INSERT INTO descampanyas
                     (ccampanya, cidioma, tcampanya)
              VALUES (pccampanya, pcidioma, ptcampanya);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE descampanyas
               SET tcampanya = ptcampanya
             WHERE ccampanya = pccampanya
               AND cidioma = pcidioma;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_campanya;

    /**********************************************************************************************
       Función para borrar campanyas
       param in pccampanya:    codigo campaña

       Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_campanya(pccampanya IN NUMBER   -- codigo campaña
                                               )
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_mntcampanyas.f_del_campanya';
      vparam         VARCHAR2(550) := 'parámetros - pccampanya:' || pccampanya;
      vpasexec       NUMBER(5) := 1;
      vtexto         VARCHAR2(1000);
      vcount         NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO vcount
        FROM coddtosespeciales
       WHERE ccampanya = pccampanya;

      IF vcount > 0 THEN
         RETURN 9905632;
      END IF;

      DELETE      descampanyas
            WHERE ccampanya = pccampanya;

      DELETE      codcampanyas
            WHERE ccampanya = pccampanya;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_del_campanya;

      /**********************************************************************************************
       Función para borrar una descriccion de la campanya
       param in pccampanya:    codigo campaña
       param in pcidioma: código de idioma

       Bug 26615/143210 - 08/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_campanya_lin(pccampanya IN NUMBER,   -- codigo campaña
                                                    pcidioma IN NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_mntcampanyas.f_del_campanya_lin';
      vparam         VARCHAR2(550)
                       := 'parámetros - pccampanya:' || pccampanya || ' pcidioma:' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vtexto         VARCHAR2(1000);
   BEGIN
      DELETE      descampanyas
            WHERE ccampanya = pccampanya
              AND cidioma = pcidioma;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_del_campanya_lin;
END pac_mntcampanyas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MNTCAMPANYAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MNTCAMPANYAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MNTCAMPANYAS" TO "PROGRAMADORESCSI";
