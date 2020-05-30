--------------------------------------------------------
--  DDL for Package Body PAC_MNTUSER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MNTUSER" AS
/******************************************************************************
   NOMBRE:       PAC_MNTUSER
   PROPÓSITO:  Mantenimiento usuarios. gestión

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        30/08/2012   JTS                1. Creación del package.
******************************************************************************/

   /**************************************************************************
     Obtiene el cidcfg de cfg_form correspondiente. Si no existe, lo crea
     param in pcempres : Codigo de la empresa
     param in pcform   : Nombre de la pantalla
     param in pcmodo   : Modo
     param in pccfgform: Perfil
     param in psproduc : Producto
     param in pcidcfg  : ID de la cfg
   **************************************************************************/
   FUNCTION f_get_cidcfg(
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pccfgform IN VARCHAR2,
      psproduc IN NUMBER,
      pcidcfg OUT NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcempres IS NULL
         OR pcform IS NULL
         OR pcmodo IS NULL
         OR pccfgform IS NULL
         OR psproduc IS NULL THEN
         RETURN 107839;
      END IF;

      BEGIN
         SELECT cidcfg
           INTO pcidcfg
           FROM cfg_form
          WHERE cempres = pcempres
            AND cform = pcform
            AND cmodo = pcmodo
            AND ccfgform = pccfgform
            AND sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT MAX(cidcfg) + 1
              INTO pcidcfg
              FROM cfg_form;

            vnumerr := f_set_cfgform(pcempres, pcform, pcmodo, pccfgform, psproduc, pcidcfg);
      END;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 108953;
   END f_get_cidcfg;

   /**************************************************************************
     Inserta un nuevo registro en la tabla cfg_form. Si existe, lo actualiza
     param in pcempres : Codigo de la empresa
     param in pcform   : Nombre de la pantalla
     param in pcmodo   : Modo
     param in pccfgform: Perfil
     param in psproduc : Producto
     param in pcidcfg  : ID de la cfg
   **************************************************************************/
   FUNCTION f_set_cfgform(
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pccfgform IN VARCHAR2,
      psproduc IN NUMBER,
      pcidcfg IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF pcempres IS NULL
         OR pcform IS NULL
         OR pcmodo IS NULL
         OR pccfgform IS NULL
         OR psproduc IS NULL
         OR pcidcfg IS NULL THEN
         RETURN 107839;
      END IF;

      BEGIN
         INSERT INTO cfg_form
                     (cempres, cform, cmodo, ccfgform, sproduc, cidcfg)
              VALUES (pcempres, pcform, pcmodo, pccfgform, psproduc, pcidcfg);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 108959;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9904146;
   END f_set_cfgform;

   /**************************************************************************
     Inserta un nuevo registro en la tabla cfg_form_property. Si existe, lo actualiza
     param in pcempres : Codigo de la empresa
     param in pcidcfg  : ID de la cfg
     param in pcform   : Nombre de la pantalla
     param in pcitem   : Item
     param in pcprpty  : Codigo de la propiedad
     param in pcvalue  : Valor de la propiedad
   **************************************************************************/
   FUNCTION f_set_cfgformproperty(
      pcempres IN NUMBER,
      pcidcfg IN NUMBER,
      pcform IN VARCHAR2,
      pcitem IN VARCHAR2,
      pcprpty IN NUMBER,
      pcvalue IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF pcempres IS NULL
         OR pcidcfg IS NULL
         OR pcform IS NULL
         OR pcitem IS NULL
         OR pcprpty IS NULL
         OR pcvalue IS NULL THEN
         RETURN 107839;
      END IF;

      BEGIN
         INSERT INTO cfg_form_property
                     (cempres, cidcfg, cform, citem, cprpty, cvalue)
              VALUES (pcempres, pcidcfg, pcform, pcitem, pcprpty, pcvalue);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE cfg_form_property
               SET cvalue = pcvalue
             WHERE cempres = pcempres
               AND cidcfg = pcidcfg
               AND cform = pcform
               AND citem = pcitem
               AND cprpty = pcprpty;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9904145;
   END f_set_cfgformproperty;

   /**************************************************************************
     Borra un registro en la tabla cfg_form_property.
     param in pcempres : Codigo de la empresa
     param in pcidcfg  : ID de la cfg
     param in pcform   : Nombre de la pantalla
     param in pcitem   : Item
     param in pcprpty  : Codigo de la propiedad
   **************************************************************************/
   FUNCTION f_del_cfgformproperty(
      pcempres IN NUMBER,
      pcidcfg IN NUMBER,
      pcform IN VARCHAR2,
      pcitem IN VARCHAR2,
      pcprpty IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF pcempres IS NULL
         OR pcidcfg IS NULL
         OR pcform IS NULL
         OR pcitem IS NULL
         OR pcprpty IS NULL THEN
         RETURN 107839;
      END IF;

      DELETE      cfg_form_property
            WHERE cempres = pcempres
              AND cidcfg = pcidcfg
              AND cform = pcform
              AND citem = pcitem
              AND cprpty = pcprpty;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9904145;
   END f_del_cfgformproperty;

   /**************************************************************************
     Recupera los registros de configuracion de cfg_form_property
     param in pcempres : Codigo de la empresa
     param in pcform   : Nombre de la pantalla
     param in pcmodo   : Modo
     param in pccfgform: Perfil
     param in psproduc : Producto
   **************************************************************************/
   FUNCTION f_get_cfgformproperty(
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pccfgform IN VARCHAR2,
      psproduc IN NUMBER)
      RETURN VARCHAR2 IS
      vquery         VARCHAR2(4000);
   BEGIN
      vquery :=
         'SELECT cfp.cempres, cf.cform, cf.cmodo, cf.ccfgform, cf.sproduc, cfp.cidcfg, cfp.cform,
       cfp.citem, cfp.cprpty, FF_DESVALORFIJO (550,pac_md_common.f_get_cxtidioma(),cfp.cprpty) tcprpty, cfp.cvalue
  FROM cfg_form_property cfp, cfg_form cf
 WHERE cf.cidcfg = cfp.cidcfg
   AND cf.cempres = cfp.cempres
   AND cf.cform = cfp.cform';

      IF pcempres IS NOT NULL THEN
         vquery := vquery || ' AND cf.cempres = ' || pcempres;
      END IF;

      IF pcform IS NOT NULL THEN
         vquery := vquery || ' AND cf.cform = ''' || pcform || '''';
      END IF;

      IF pcmodo IS NOT NULL THEN
         vquery := vquery || ' AND cf.cmodo = ''' || pcmodo || '''';
      END IF;

      IF pccfgform IS NOT NULL THEN
         vquery := vquery || ' AND cf.ccfgform = ''' || pccfgform || '''';
      END IF;

      IF psproduc IS NOT NULL THEN
         vquery := vquery || ' AND cf.sproduc = ' || psproduc;
      END IF;

      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_cfgformproperty;

   /**************************************************************************
     Recupera los perfiles
     param in pcempres : Codigo de la empresa
   **************************************************************************/
   FUNCTION f_get_ccfgform(pcempres IN NUMBER)
      RETURN VARCHAR2 IS
      vquery         VARCHAR2(4000);
   BEGIN
      IF pcempres IS NULL THEN
         RETURN NULL;
      END IF;

      vquery :=
         'SELECT   ccc.ccfgform, ccc.tcfgform tdesc
    FROM cfg_cod_cfgform_det ccc
   WHERE ccc.cempres = '
         || pcempres
         || ' and ccc.cidioma = pac_md_common.f_get_cxtidioma() GROUP BY ccc.ccfgform, ccc.tcfgform
ORDER BY ccfgform';
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_ccfgform;

   /**************************************************************************
     Recupera los modos
     param in pcempres : Codigo de la empresa
     param in psproduc : Producto
   **************************************************************************/
   FUNCTION f_get_codmodo(pcempres IN NUMBER, psproduc IN NUMBER)
      RETURN VARCHAR2 IS
      vquery         VARCHAR2(4000);
   BEGIN
      IF pcempres IS NULL
         OR psproduc IS NULL THEN
         RETURN NULL;
      END IF;

      vquery :=
         'SELECT   ccm.cmodo, ccm.tmodo
    FROM cfg_cod_modo ccm, cfg_form cf
   WHERE ccm.cmodo = cf.cmodo
     AND cf.sproduc = '
         || psproduc || ' AND cf.cempres = ' || pcempres
         || ' GROUP BY ccm.cmodo, ccm.tmodo
ORDER BY cmodo';
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_codmodo;

   /**************************************************************************
     Recupera los formularios
     param in pcempres : Codigo de la empresa
     param in psproduc : Producto
     param in pcmodo   : Modo
   **************************************************************************/
   FUNCTION f_get_codform(pcempres IN NUMBER, psproduc IN NUMBER, pcmodo IN VARCHAR2)
      RETURN VARCHAR2 IS
      vquery         VARCHAR2(4000);
   BEGIN
      IF pcempres IS NULL
         OR psproduc IS NULL
         OR pcmodo IS NULL THEN
         RETURN NULL;
      END IF;

      vquery :=
         'SELECT   ccf.cform, ccf.tform
    FROM cfg_form cf, cfg_cod_form ccf
   WHERE cf.cform = ccf.cform
     AND cf.sproduc = '
         || psproduc || ' AND cf.cmodo = ''' || pcmodo || ''' AND cf.cempres = ' || pcempres
         || ' GROUP BY ccf.cform, ccf.tform
ORDER BY ccf.cform';
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_codform;

/**************************************************************************
  Recupera los modos
**************************************************************************/
   FUNCTION f_get_codmodo_n
      RETURN VARCHAR2 IS
      vquery         VARCHAR2(4000);
   BEGIN
      vquery :=
         'SELECT   ccm.cmodo, ccm.tmodo
    FROM cfg_cod_modo ccm
GROUP BY ccm.cmodo, ccm.tmodo
ORDER BY cmodo';
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_codmodo_n;

/**************************************************************************
  Recupera los formularios
**************************************************************************/
   FUNCTION f_get_codform_n
      RETURN VARCHAR2 IS
      vquery         VARCHAR2(4000);
   BEGIN
      vquery :=
         'SELECT   ccf.cform, ccf.tform
    FROM cfg_cod_form ccf
 GROUP BY ccf.cform, ccf.tform
ORDER BY ccf.cform';
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_codform_n;

   /**************************************************************************
     Recupera los productos
     param in pcempres : Codigo de la empresa
   **************************************************************************/
   FUNCTION f_get_productos(pcempres IN NUMBER)
      RETURN VARCHAR2 IS
      vquery         VARCHAR2(4000);
   BEGIN
      IF pcempres IS NULL THEN
         RETURN NULL;
      END IF;

      vquery :=
         ' select sproduc, ttitulo from'
         || ' (select 0 sproduc, f_axis_literales(100934,pac_md_common.f_get_cxtidioma()) ttitulo from dual union '
         || ' select p.sproduc, t.ttitulo' || ' from productos p, titulopro t, codiram cr'
         || ' where p.CRAMO = t.CRAMO and' || ' p.CCOLECT = t.CCOLECT and'
         || ' cr.cramo = p.cramo and' || ' cr.cempres = ' || pcempres || ' and'
         || ' p.CMODALI = t.CMODALI and' || ' p.CTIPSEG = t.ctipseg and'
         || ' t.CIDIOMA = pac_md_common.f_get_cxtidioma()) order by decode(sproduc,0,''aaa''||ttitulo,ttitulo)';
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_productos;

   /**************************************************************************
     Recupera la cebecera de la CFG
     param in pcidcfg : Codigo de la configuracion
   **************************************************************************/
   FUNCTION f_get_cabcfgform(
      pcidcfg IN NUMBER,
      pcempres IN NUMBER,
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pccfgform IN VARCHAR2,
      psproduc IN NUMBER)
      RETURN VARCHAR2 IS
      vquery         VARCHAR2(4000);
   BEGIN
      IF pcidcfg IS NULL THEN
         RETURN NULL;
      END IF;

      vquery :=
         ' SELECT cf.cempres, e.tempres, cf.cform, ccf.tform, cf.cmodo, ccm.tmodo, cf.ccfgform, ccc.tdesc, '
         || ' cf.sproduc, p.ttitulo, cf.cidcfg ' || ' FROM cfg_form cf, '
         || ' cfg_cod_cfgform ccc, ' || ' cfg_cod_modo ccm, ' || ' cfg_cod_form ccf, '
         || ' empresas e, '
         || ' (SELECT 0 sproduc, f_axis_literales(100934, pac_md_common.f_get_cxtidioma()) ttitulo '
         || ' FROM DUAL ' || ' UNION ' || ' SELECT p.sproduc, t.ttitulo '
         || ' FROM productos p, titulopro t ' || ' WHERE p.cramo = t.cramo '
         || ' AND p.ccolect = t.ccolect ' || ' AND p.cmodali = t.cmodali '
         || ' AND p.ctipseg = t.ctipseg '
         || ' AND t.cidioma = pac_md_common.f_get_cxtidioma()) p ' || ' WHERE cf.cidcfg = '
         || pcidcfg || ' AND cf.cempres = ' || pcempres || ' AND cf.cform = ''' || pcform
         || ''' AND cf.cmodo = ''' || pcmodo || ''' AND cf.ccfgform = ''' || pccfgform
         || ''' AND cf.sproduc = ' || psproduc || ' AND ccc.ccfgform = cf.ccfgform '
         || ' AND ccm.cmodo = cf.cmodo ' || ' AND cf.cform = ccf.cform '
         || ' AND p.sproduc = cf.sproduc ' || ' AND e.cempres = cf.cempres ';
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_get_cabcfgform;
END pac_mntuser;

/

  GRANT EXECUTE ON "AXIS"."PAC_MNTUSER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MNTUSER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MNTUSER" TO "PROGRAMADORESCSI";
