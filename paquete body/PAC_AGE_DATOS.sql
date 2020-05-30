--------------------------------------------------------
--  DDL for Package Body PAC_AGE_DATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_AGE_DATOS" AS
/******************************************************************************
   NOMBRE:       PAC_AGE_DATOS
   PROPÓSITO: Funciones para gestionar Más datos de agentes

   REVISIONES:
   Ver        Fecha        Autor       Descripción
   ---------  ----------  ---------  ------------------------------------
   1.0        13/03/2012  MDS        1. Creación del package.

******************************************************************************/

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Banco
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_banco(
      pcagente IN age_bancos.cagente%TYPE,
      pctipbanco IN age_bancos.ctipbanco%TYPE,
      errores OUT t_ob_error)
      RETURN NUMBER IS
      verr           ob_error;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      BEGIN
         DELETE FROM age_bancos
               WHERE cagente = pcagente
                 AND ctipbanco = pctipbanco;
      EXCEPTION
         WHEN OTHERS THEN
            errores.EXTEND;
            verr := ob_error.instanciar(9903415,
                                        f_axis_literales(9903415,
                                                         pac_md_common.f_get_cxtidioma())
                                        || '  ' || SQLERRM);
            errores(1) := verr;
            RETURN 9903415;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 1, 'OTHERS : ', SQLERRM);
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(9903415,
                                     f_axis_literales(9903415,
                                                      pac_md_common.f_get_cxtidioma())
                                     || '  ' || SQLERRM);
         errores(1) := verr;
         RETURN 9903415;
   END f_del_banco;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Banco
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_banco(
      pcagente IN age_bancos.cagente%TYPE,
      pctipbanco IN age_bancos.ctipbanco%TYPE,
      pctipbanco_orig IN age_bancos.ctipbanco%TYPE,
      errores OUT t_ob_error)
      RETURN NUMBER IS
      verr           ob_error;
      vnumerr        NUMBER;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      IF pctipbanco_orig IS NOT NULL THEN
         vnumerr := f_del_banco(pcagente, pctipbanco_orig, errores);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;
      END IF;

      INSERT INTO age_bancos
                  (cagente, ctipbanco)
           VALUES (pcagente, pctipbanco);

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 1,
                     'f_set_banco. Error Imprevisto insertando datos', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(108468, SQLERRM);
         errores(1) := verr;
         RETURN 108468;
      WHEN DUP_VAL_ON_INDEX THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 2,
                     'f_set_banco. Registro duplicado insertando datos', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(108959, SQLERRM);
         errores(1) := verr;
         RETURN 108959;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 3,
                     'f_set_banco. Error Imprevisto insertando datos', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(108468, SQLERRM);
         errores(1) := verr;
         RETURN 108468;
   END f_set_banco;

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_entidadaseg(
      pcagente IN age_entidadesaseg.cagente%TYPE,
      pctipentidadaseg IN age_entidadesaseg.ctipentidadaseg%TYPE,
      errores OUT t_ob_error)
      RETURN NUMBER IS
      verr           ob_error;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      BEGIN
         DELETE FROM age_entidadesaseg
               WHERE cagente = pcagente
                 AND ctipentidadaseg = pctipentidadaseg;
      EXCEPTION
         WHEN OTHERS THEN
            errores.EXTEND;
            verr := ob_error.instanciar(9903416,
                                        f_axis_literales(9903416,
                                                         pac_md_common.f_get_cxtidioma())
                                        || '  ' || SQLERRM);
            errores(1) := verr;
            RETURN 9903416;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 1, 'OTHERS : ', SQLERRM);
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(9903416,
                                     f_axis_literales(9903416,
                                                      pac_md_common.f_get_cxtidioma())
                                     || '  ' || SQLERRM);
         errores(1) := verr;
         RETURN 9903416;
   END f_del_entidadaseg;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_entidadaseg(
      pcagente IN age_entidadesaseg.cagente%TYPE,
      pctipentidadaseg IN age_entidadesaseg.ctipentidadaseg%TYPE,
      pctipentidadaseg_orig IN age_entidadesaseg.ctipentidadaseg%TYPE,
      errores OUT t_ob_error)
      RETURN NUMBER IS
      verr           ob_error;
      vnumerr        NUMBER;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      IF pctipentidadaseg_orig IS NOT NULL THEN
         vnumerr := f_del_entidadaseg(pcagente, pctipentidadaseg_orig, errores);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;
      END IF;

      INSERT INTO age_entidadesaseg
                  (cagente, ctipentidadaseg)
           VALUES (pcagente, pctipentidadaseg);

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 1,
                     'f_set_entidadaseg. Error Imprevisto insertando datos', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(108468, SQLERRM);
         errores(1) := verr;
         RETURN 108468;
      WHEN DUP_VAL_ON_INDEX THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 2,
                     'f_set_entidadaseg. Registro duplicado insertando datos', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(108959, SQLERRM);
         errores(1) := verr;
         RETURN 108959;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 3,
                     'f_set_entidadaseg. Error Imprevisto insertando datos', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(108468, SQLERRM);
         errores(1) := verr;
         RETURN 108468;
   END f_set_entidadaseg;

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Asociación
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_asociacion(
      pcagente IN age_asociaciones.cagente%TYPE,
      pctipasociacion IN age_asociaciones.ctipasociacion%TYPE,
      errores OUT t_ob_error)
      RETURN NUMBER IS
      verr           ob_error;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      BEGIN
         DELETE FROM age_asociaciones
               WHERE cagente = pcagente
                 AND ctipasociacion = pctipasociacion;
      EXCEPTION
         WHEN OTHERS THEN
            errores.EXTEND;
            verr := ob_error.instanciar(9903417,
                                        f_axis_literales(9903417,
                                                         pac_md_common.f_get_cxtidioma())
                                        || '  ' || SQLERRM);
            errores(1) := verr;
            RETURN 9903417;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 1, 'OTHERS : ', SQLERRM);
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(9903417,
                                     f_axis_literales(9903417,
                                                      pac_md_common.f_get_cxtidioma())
                                     || '  ' || SQLERRM);
         errores(1) := verr;
         RETURN 9903417;
   END f_del_asociacion;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Asociación
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_asociacion(
      pcagente IN age_asociaciones.cagente%TYPE,
      pctipasociacion IN age_asociaciones.ctipasociacion%TYPE,
      pnumcolegiado IN age_asociaciones.numcolegiado%TYPE,
      pctipasociacion_orig IN age_asociaciones.ctipasociacion%TYPE,
      errores OUT t_ob_error)
      RETURN NUMBER IS
      verr           ob_error;
      vnumerr        NUMBER;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      IF pctipasociacion_orig IS NOT NULL THEN
         vnumerr := f_del_referencia(pcagente, pctipasociacion_orig, errores);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;
      END IF;

      BEGIN
         INSERT INTO age_asociaciones
                     (cagente, ctipasociacion, numcolegiado)
              VALUES (pcagente, pctipasociacion, pnumcolegiado);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE age_asociaciones
               SET numcolegiado = pnumcolegiado
             WHERE cagente = pcagente
               AND ctipasociacion = pctipasociacion;
      END;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 1,
                     'f_set_asociacion. Error Imprevisto insertando datos', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(108468, SQLERRM);
         errores(1) := verr;
         RETURN 108468;
      WHEN DUP_VAL_ON_INDEX THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 2,
                     'f_set_asociacion. Registro duplicado insertando datos', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(108959, SQLERRM);
         errores(1) := verr;
         RETURN 108959;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 3,
                     'f_set_asociacion. Error Imprevisto insertando datos', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(108468, SQLERRM);
         errores(1) := verr;
         RETURN 108468;
   END f_set_asociacion;

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Otra referencia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_referencia(
      pcagente IN age_referencias.cagente%TYPE,
      pnordreferencia IN age_referencias.nordreferencia%TYPE,
      errores OUT t_ob_error)
      RETURN NUMBER IS
      verr           ob_error;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      BEGIN
         DELETE FROM age_referencias
               WHERE cagente = pcagente
                 AND nordreferencia = pnordreferencia;
      EXCEPTION
         WHEN OTHERS THEN
            errores.EXTEND;
            verr := ob_error.instanciar(9903418,
                                        f_axis_literales(9903418,
                                                         pac_md_common.f_get_cxtidioma())
                                        || '  ' || SQLERRM);
            errores(1) := verr;
            RETURN 9903418;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 1, 'OTHERS : ', SQLERRM);
         errores.DELETE;
         errores.EXTEND;
         verr := ob_error.instanciar(9903418,
                                     f_axis_literales(9903418,
                                                      pac_md_common.f_get_cxtidioma())
                                     || '  ' || SQLERRM);
         errores(1) := verr;
         RETURN 9903418;
   END f_del_referencia;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Otra referencia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_referencia(
      pcagente IN age_referencias.cagente%TYPE,
      pnordreferencia IN age_referencias.nordreferencia%TYPE,
      ptreferencia IN age_referencias.treferencia%TYPE,
      errores OUT t_ob_error)
      RETURN NUMBER IS
      verr           ob_error;
      vnumerr        NUMBER;
      vnordreferencia age_referencias.nordreferencia%TYPE;
   BEGIN
      errores := t_ob_error();
      errores.DELETE;

      IF pnordreferencia IS NOT NULL THEN
         vnumerr := f_del_referencia(pcagente, pnordreferencia, errores);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;

         vnordreferencia := pnordreferencia;
      ELSE
         SELECT NVL(MAX(nordreferencia), 0) + 1
           INTO vnordreferencia
           FROM age_referencias
          WHERE cagente = pcagente;
      END IF;

      INSERT INTO age_referencias
                  (cagente, nordreferencia, treferencia)
           VALUES (pcagente, vnordreferencia, ptreferencia);

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 1,
                     'f_set_referencia. Error Imprevisto insertando datos', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(108468, SQLERRM);
         errores(1) := verr;
         RETURN 108468;
      WHEN DUP_VAL_ON_INDEX THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 2,
                     'f_set_referencia. Registro duplicado insertando datos', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(108959, SQLERRM);
         errores(1) := verr;
         RETURN 108959;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGE_DATOS', 3,
                     'f_set_referencia. Error Imprevisto insertando datos', SQLERRM);
         errores.EXTEND;
         verr := ob_error.instanciar(108468, SQLERRM);
         errores(1) := verr;
         RETURN 108468;
   END f_set_referencia;
END pac_age_datos;

/

  GRANT EXECUTE ON "AXIS"."PAC_AGE_DATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AGE_DATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AGE_DATOS" TO "PROGRAMADORESCSI";
